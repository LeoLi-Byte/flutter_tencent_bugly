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
}
