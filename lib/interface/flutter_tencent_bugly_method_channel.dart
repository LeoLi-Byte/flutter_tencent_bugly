part of 'flutter_tencent_bugly.dart';

/// An implementation of [FlutterTencentBuglyPlatform] that uses method channels.
class MethodChannelFlutterTencentBugly extends FlutterTencentBuglyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('flutter_tencent_bugly');

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
    required String message,
    required String detail,
    String? type,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isSupportPlatform) return;

    final Map<String, dynamic> value = <String, dynamic>{
      'message': message,
      'detail': detail,
      'type': ?type,
      'data': ?extra,
    };
    await methodChannel.invokeMethod('postException', value);
  }

  @override
  Future<void> log({required String tag, required String message, LogLevel level = .INFO}) async {
    if (!_isSupportPlatform) return;
    await methodChannel.invokeMethod('log', <String, dynamic>{'level': level.key, 'tag': tag, 'message': message});
  }

  /// 判断是否是支持的平台
  bool get _isSupportPlatform => _isAndroid || _isIOS;

  /// Whether the operating system is a version of [Android](https://www.android.com/).
  final bool _isAndroid = defaultTargetPlatform == TargetPlatform.android;

  /// Whether the operating system is a version of [iOS](https://www.apple.com/ios/).
  final bool _isIOS = defaultTargetPlatform == TargetPlatform.iOS;
}
