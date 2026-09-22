part of 'flutter_tencent_bugly.dart';

abstract class FlutterTencentBuglyPlatform extends PlatformInterface {
  /// Constructs a FlutterTencentBuglyPlatform.
  FlutterTencentBuglyPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTencentBuglyPlatform _instance = MethodChannelFlutterTencentBugly();

  /// The default instance of [FlutterTencentBuglyPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTencentBugly].
  static FlutterTencentBuglyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTencentBuglyPlatform] when
  /// they register themselves.
  static set instance(FlutterTencentBuglyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.init}
  /// 初始化腾讯 Bugly。
  ///
  /// [config] 为双端通用的公共配置项。
  ///
  /// [android] 与 [ios] 分别为 Android、iOS 平台的专属配置项，
  /// 未传入对应平台的配置时，该平台不会执行初始化。
  /// {@endtemplate}
  Future<bool> init({
    FlutterTencentBuglyConfig? config,
    FlutterTencentBuglyAndroidConfig? android,
    FlutterTencentBuglyIOSConfig? ios,
  }) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.setUserId}
  /// 设置用户ID
  /// {@endtemplate}
  Future<void> setUserId(String value) {
    throw UnimplementedError('setUserId() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.setUserTag}
  /// 设置标签
  /// {@endtemplate}
  Future<void> setUserTag(String value) {
    throw UnimplementedError('setUserTag() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.setDeviceID}
  /// 设置设备ID
  /// {@endtemplate}
  Future<void> setDeviceID(String value) {
    throw UnimplementedError('setDeviceID() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.setDeviceModel}
  /// 设置设备型号
  ///
  /// 仅支持Android
  /// {@endtemplate}
  Future<void> setDeviceModel(String value) {
    throw UnimplementedError('setDeviceModel() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.setChannel}
  /// 设置渠道
  ///
  /// 仅支持Android，iOS 仅支持初始化时配置
  /// {@endtemplate}
  Future<void> setChannel(String value) {
    throw UnimplementedError('setChannel() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.setVersion}
  /// 设置版本号
  /// {@endtemplate}
  Future<void> setVersion(String value) {
    throw UnimplementedError('setVersion() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.setPackageName}
  /// 设置包名
  ///
  /// 仅支持Android
  /// {@endtemplate}
  Future<void> setPackageName(String value) {
    throw UnimplementedError('setPackageName() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.putUserData}
  /// 设置自定义的 Key-Value 数据，发生 Crash 时随之上报
  ///
  /// 最多可以有50对自定义的key-value（超过则添加失败）
  ///
  /// key限长50字节，value限长200字节，过长截断；
  /// {@endtemplate}
  Future<void> putUserData({required String key, required String value}) {
    throw UnimplementedError('putUserData() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.postException}
  /// 上报自定义异常
  /// {@endtemplate}
  Future<void> postException({
    required String message,
    required String detail,
    String? type,
    Map<String, dynamic>? extra,
  }) {
    throw UnimplementedError('postException() has not been implemented.');
  }

  /// {@template plugin.flutter_tencent_bugly.log}
  /// 输出 Bugly 日志，发生 Crash 时随之上报
  ///
  /// Android:
  ///   需初始化时将 [FlutterTencentBuglyAndroidConfig.isLogUpload] 设为 true，日志才会上传到 Bugly 服务器。
  ///
  /// iOS:
  ///   上报级别由 [FlutterTencentBuglyIOSConfig.reportLogLevel] 控制
  /// {@endtemplate}
  Future<void> log({required String tag, required String message, LogLevel level = .INFO}) {
    throw UnimplementedError('log() has not been implemented.');
  }
}
