import 'package:flutter/foundation.dart';
import 'package:flutter_tencent_bugly/flutter_tencent_bugly.dart';
import 'package:flutter_tencent_bugly/src/log_level.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTencentBuglyPlatform with MockPlatformInterfaceMixin implements FlutterTencentBuglyPlatform {
  @override
  Future<String?> getPlatformVersion() => Future<String>.value('42');

  @override
  Future<bool> init({
    FlutterTencentBuglyConfig? config,
    FlutterTencentBuglyAndroidConfig? android,
    FlutterTencentBuglyIOSConfig? ios,
  }) => Future<bool>.value(false);

  @override
  Future<void> setUserId(String value) => Future<void>.value();

  @override
  Future<void> setUserTag(int value) => Future<void>.value();

  @override
  Future<void> setDeviceID(String value) => Future<void>.value();

  @override
  Future<void> setDeviceModel(String value) => Future<void>.value();

  @override
  Future<void> setChannel(String value) => Future<void>.value();

  @override
  Future<void> setVersion(String value) => Future<void>.value();

  @override
  Future<void> setPackageName(String value) => Future<void>.value();

  @override
  Future<void> putUserData({required String key, required String value}) => Future<void>.value();

  @override
  Future<void> postException({
    required dynamic message,
    required dynamic detail,
    dynamic type,
    Map<String, dynamic>? extra,
  }) => Future<void>.value();

  @override
  Future<void> log({required String tag, required String message, LogLevel level = .INFO}) => Future<void>.value();

  @override
  void runGuarded<T>(
    ValueGetter<T> body, {
    FlutterExceptionHandler? onException,
    String? filterPattern,
    bool reportInDebugMode = false,
  }) {}
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
