part of 'flutter_tencent_bugly.dart';

/// [MethodChannelFlutterTencentBugly.runGuarded] 的异常处理配置。
typedef _ExceptionFilter = ({FlutterExceptionHandler? onException, String? filterPattern, bool reportInDebugMode});

/// An implementation of [FlutterTencentBuglyPlatform] that uses method channels.
class MethodChannelFlutterTencentBugly extends FlutterTencentBuglyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('flutter_tencent_bugly');

  /// 全局异常捕获回调是否已安装，避免重复调用 [runGuarded] 时重复注册。
  bool _errorHandlersInstalled = false;

  /// 安装前的 [FlutterError.onError]，用于链式调用而非覆盖。
  FlutterExceptionHandler? _previousOnError;

  /// 安装前的 [PlatformDispatcher.onError]，用于链式调用而非覆盖。
  bool Function(Object, StackTrace)? _previousPlatformOnError;

  @override
  Future<String?> getPlatformVersion() async {
    final String? version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> init({
    FlutterTencentBuglyConfig? config,
    FlutterTencentBuglyAndroidConfig? android,
    FlutterTencentBuglyIOSConfig? ios,
  }) async {
    assert(
      (_isAndroid && android != null) || (_isIOS && ios != null),
      'Missing required config: pass `android` when running on Android and `ios` when running on iOS.',
    );

    /// If the operating system is not Android or iOS, return false.
    if (!_isSupportPlatform) return false;

    final Map<String, dynamic> map = <String, dynamic>{...?config?.toJson(), ...?android?.toJson(), ...?ios?.toJson()};
    final bool? result = await methodChannel.invokeMethod('init', map);
    return result ?? false;
  }

  @override
  Future<void> setUserId(String value) async {
    if (!_isSupportPlatform || value.isBlank) return;
    await methodChannel.invokeMethod('setUserId', <String, dynamic>{'value': value});
  }

  @override
  Future<void> setUserTag(String value) async {
    if (!_isSupportPlatform || value.isBlank) return;
    await methodChannel.invokeMethod('setUserTag', <String, dynamic>{'value': value});
  }

  @override
  Future<void> setDeviceID(String value) async {
    if (!_isSupportPlatform || value.isBlank) return;
    await methodChannel.invokeMethod('setDeviceID', <String, dynamic>{'value': value});
  }

  @override
  Future<void> setDeviceModel(String value) async {
    if (!_isAndroid || value.isBlank) return;
    await methodChannel.invokeMethod('setDeviceModel', <String, dynamic>{'value': value});
  }

  @override
  Future<void> setChannel(String value) async {
    if (!_isAndroid || value.isBlank) return;
    await methodChannel.invokeMethod('setChannel', <String, dynamic>{'value': value});
  }

  @override
  Future<void> setVersion(String value) async {
    if (!_isSupportPlatform || value.isBlank) return;
    await methodChannel.invokeMethod('setVersion', <String, dynamic>{'value': value});
  }

  @override
  Future<void> setPackageName(String value) async {
    if (!_isAndroid || value.isBlank) return;
    await methodChannel.invokeMethod('setPackageName', <String, dynamic>{'value': value});
  }

  @override
  Future<void> putUserData({required String key, required String value}) async {
    if (!_isSupportPlatform || key.isBlank || value.isBlank) return;
    await methodChannel.invokeMethod('putUserData', <String, dynamic>{'key': key, 'value': value});
  }

  @override
  Future<void> postException({
    required dynamic message,
    required dynamic detail,
    dynamic type,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isSupportPlatform) return;

    final Map<String, dynamic> value = <String, dynamic>{
      'message': message.toString(),
      'detail': detail.toString(),
      'type': ?type?.toString().value,
      'data': ?extra,
    };
    await methodChannel.invokeMethod('postException', value);
  }

  @override
  Future<void> log({required String tag, required String message, LogLevel level = .INFO}) async {
    if (!_isSupportPlatform) return;
    await methodChannel.invokeMethod('log', <String, dynamic>{'level': level.key, 'tag': tag, 'message': message});
  }

  @override
  void runGuarded<T>(
    ValueGetter<T> body, {
    FlutterExceptionHandler? onException,
    String? filterPattern,
    bool reportInDebugMode = false,
  }) {
    if (_isSupportPlatform) {
      final _ExceptionFilter filter = (
        onException: onException,
        filterPattern: filterPattern,
        reportInDebugMode: reportInDebugMode,
      );
      _installErrorHandlers(filter);
      runZonedGuarded<T>(body, (Object error, StackTrace stackTrace) => _handleException(error, stackTrace, filter));
    } else {
      body.call();
    }
  }

  /// 安装全局异常捕获回调，捕获框架异常与逃逸出 [Zone] 的未处理异常。
  void _installErrorHandlers(_ExceptionFilter filter) {
    if (_errorHandlersInstalled) return;
    _errorHandlersInstalled = true;

    /// Capture errors reported by the Flutter framework, chaining the
    /// previously registered handler instead of replacing it.
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final StackTrace? stack = details.stack;
      if (stack == null) {
        FlutterError.presentError(details);
      } else {
        _handleException(details.exception, stack, filter);
      }
    };

    /// Capture errors that escape the [Zone] and reach the root isolate,
    /// e.g. errors thrown from native platform channel callbacks.
    _previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
      _handleException(error, stackTrace, filter);
      return _previousPlatformOnError?.call(error, stackTrace) ?? true;
    };
  }

  /// 先执行自定义异常处理，再按条件过滤并上报异常。
  void _handleException(Object error, StackTrace stackTrace, _ExceptionFilter filter) {
    /// 自定义异常处理，可用于异常打印、双上报等定制逻辑。该字段不影响上报。
    (filter.onException ?? _previousOnError ?? FlutterError.presentError)(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );

    /// 不上报的规则判断
    final String? pattern = filter.filterPattern;
    if (!filter.reportInDebugMode || (pattern != null && RegExp(pattern).hasMatch(error.toString()))) return;
    postException(type: error.runtimeType, message: error, detail: stackTrace);
  }

  /// 判断是否是支持的平台
  bool get _isSupportPlatform => _isAndroid || _isIOS;

  /// Whether the operating system is a version of [Android](https://www.android.com/).
  final bool _isAndroid = defaultTargetPlatform == TargetPlatform.android;

  /// Whether the operating system is a version of [iOS](https://www.apple.com/ios/).
  final bool _isIOS = defaultTargetPlatform == TargetPlatform.iOS;
}
