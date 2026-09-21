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
}
