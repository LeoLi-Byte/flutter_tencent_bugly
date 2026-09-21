import 'package:flutter_tencent_bugly/flutter_tencent_bugly.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTencentBuglyPlatform with MockPlatformInterfaceMixin implements FlutterTencentBuglyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future<String>.value('42');
}

void main() {
  final FlutterTencentBuglyPlatform initialPlatform = FlutterTencentBuglyPlatform.instance;

  test('$MethodChannelFlutterTencentBugly is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTencentBugly>());
  });

  test('getPlatformVersion', () async {
    final FlutterTencentBugly flutterTencentBuglyPlugin = FlutterTencentBugly();
    final MockFlutterTencentBuglyPlatform fakePlatform = MockFlutterTencentBuglyPlatform();
    FlutterTencentBuglyPlatform.instance = fakePlatform;

    expect(await flutterTencentBuglyPlugin.getPlatformVersion(), '42');
  });
}
