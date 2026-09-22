library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tencent_bugly/src/extension_string.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../src/config.dart';
import '../src/log_level.dart';

part 'flutter_tencent_bugly_method_channel.dart';

part 'flutter_tencent_bugly_platform_interface.dart';

class FlutterTencentBugly {
  Future<String?> getPlatformVersion() {
    return FlutterTencentBuglyPlatform.instance.getPlatformVersion();
  }

  /// {@macro plugin.flutter_tencent_bugly.init}
  Future<bool> init({
    FlutterTencentBuglyConfig? config,
    FlutterTencentBuglyAndroidConfig? android,
    FlutterTencentBuglyIOSConfig? ios,
  }) => FlutterTencentBuglyPlatform.instance.init(config: config, android: android, ios: ios);

  /// {@macro plugin.flutter_tencent_bugly.setUserId}
  Future<void> setUserId(String value) => FlutterTencentBuglyPlatform.instance.setUserId(value);

  /// {@macro plugin.flutter_tencent_bugly.setUserTag}
  Future<void> setUserTag(String value) => FlutterTencentBuglyPlatform.instance.setUserTag(value);

  /// {@macro plugin.flutter_tencent_bugly.setDeviceID}
  Future<void> setDeviceID(String value) => FlutterTencentBuglyPlatform.instance.setDeviceID(value);

  /// {@macro plugin.flutter_tencent_bugly.setDeviceModel}
  Future<void> setDeviceModel(String value) => FlutterTencentBuglyPlatform.instance.setDeviceModel(value);

  /// {@macro plugin.flutter_tencent_bugly.setChannel}
  Future<void> setChannel(String value) => FlutterTencentBuglyPlatform.instance.setChannel(value);

  /// {@macro plugin.flutter_tencent_bugly.setVersion}
  Future<void> setVersion(String value) => FlutterTencentBuglyPlatform.instance.setVersion(value);

  /// {@macro plugin.flutter_tencent_bugly.setPackageName}
  Future<void> setPackageName(String value) => FlutterTencentBuglyPlatform.instance.setPackageName(value);

  /// {@macro plugin.flutter_tencent_bugly.putUserData}
  Future<void> putUserData({required String key, required String value}) =>
      FlutterTencentBuglyPlatform.instance.putUserData(key: key, value: value);

  /// {@macro plugin.flutter_tencent_bugly.postException}
  Future<void> postException({
    required String message,
    required String detail,
    String? type,
    Map<String, dynamic>? extra,
  }) => FlutterTencentBuglyPlatform.instance.postException(message: message, detail: detail, type: type, extra: extra);

  /// {@macro plugin.flutter_tencent_bugly.log}
  Future<void> log({required String tag, required String message, LogLevel level = .INFO}) =>
      FlutterTencentBuglyPlatform.instance.log(tag: tag, message: message, level: level);
}
