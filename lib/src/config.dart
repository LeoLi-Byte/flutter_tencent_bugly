/// @Describe: 配置项
///
/// @Author: LiWeNHuI
/// @Date: 2026/9/22

library;

import 'package:flutter/foundation.dart';

import 'extension_string.dart';

abstract class FlutterTencentBuglyBaseConfig {
  const FlutterTencentBuglyBaseConfig({required this.appId});

  /// 注册产品时申请的 AppID
  final String appId;

  /// 参数
  Map<String, dynamic> toJson() => <String, dynamic>{'appId': appId};
}

/// Android 配置项
class FlutterTencentBuglyAndroidConfig extends FlutterTencentBuglyBaseConfig {
  const FlutterTencentBuglyAndroidConfig({
    required super.appId,
    this.packageName,
    this.deviceModel,
    this.reportDelay = 0,
    this.enableCatchAnrTrace = false,
    this.enableRecordAnrMainStack = true,
    this.isLogUpload = true,
  });

  /// 包名
  final String? packageName;

  /// 设备型号
  final String? deviceModel;

  /// 初始化延迟间隔，单位为秒
  final int reportDelay;

  /// 设置 ANR 时是否获取系统trace文件，默认关闭
  final bool enableCatchAnrTrace;

  /// 设置是否获取ANR过程中的主线程堆栈，默认开启
  final bool enableRecordAnrMainStack;

  /// 设置是否上传自定义日志到bugly，默认开启
  final bool isLogUpload;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    ...super.toJson(),
    'packageName': ?packageName.value,
    'deviceModel': ?deviceModel.value,
    'reportDelay': reportDelay,
    'enableCatchAnrTrace': enableCatchAnrTrace,
    'enableRecordAnrMainStack': enableRecordAnrMainStack,
    'isLogUpload': isLogUpload,
  };
}

/// iOS 配置项
class FlutterTencentBuglyIOSConfig extends FlutterTencentBuglyBaseConfig {
  const FlutterTencentBuglyIOSConfig({
    required super.appId,
    this.blockMonitorEnable = true,
    this.blockMonitorTimeout = 3,
    this.symbolicateInProcessEnable = true,
    this.unexpectedTerminatingDetectionEnable = true,
    this.viewControllerTrackingEnable = true,
    this.reportLogLevel = 0,
  });

  /// 卡顿监控开关，默认开启
  final bool blockMonitorEnable;

  /// 卡顿监控判断间隔，单位为秒
  final int blockMonitorTimeout;

  /// 进程内还原开关，默认开启
  final bool symbolicateInProcessEnable;

  /// 非正常退出事件记录开关，默认开启
  final bool unexpectedTerminatingDetectionEnable;

  /// 页面信息记录开关，默认开启
  final bool viewControllerTrackingEnable;

  /// 控制自定义日志上报，默认值为 BuglyLogLevelSilent，即关闭日志记录功能。
  /// 如果设置为 BuglyLogLevelWarn，则在崩溃时会上报Warn、Error接口打印的日志
  ///
  /// typedef NS_ENUM(NSUInteger, BuglyLogLevel) {
  ///     BuglyLogLevelSilent  = 0,
  ///     BuglyLogLevelError   = 1,
  ///     BuglyLogLevelWarn    = 2,
  ///     BuglyLogLevelInfo    = 3,
  ///     BuglyLogLevelDebug   = 4,
  ///     BuglyLogLevelVerbose = 5,
  /// };
  final int reportLogLevel;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    ...super.toJson(),
    'blockMonitorEnable': blockMonitorEnable,
    'blockMonitorTimeout': blockMonitorTimeout,
    'symbolicateInProcessEnable': symbolicateInProcessEnable,
    'unexpectedTerminatingDetectionEnable': unexpectedTerminatingDetectionEnable,
    'viewControllerTrackingEnable': viewControllerTrackingEnable,
    'reportLogLevel': reportLogLevel,
  };
}

/// 公共配置项
class FlutterTencentBuglyConfig {
  const FlutterTencentBuglyConfig({
    this.isDebugMode = kDebugMode,
    this.isDevelopmentDevice = false,
    this.channel,
    this.version,
    this.deviceId,
  });

  /// SDK Debug信息开关, 默认关闭
  final bool isDebugMode;

  /// 是否开发设备, 默认关闭
  final bool isDevelopmentDevice;

  /// 渠道
  final String? channel;

  /// 版本号
  final String? version;

  /// 设备唯一标识
  final String? deviceId;

  /// 参数
  Map<String, dynamic> toJson() => <String, dynamic>{
    'isDebugMode': isDebugMode,
    'isDevelopmentDevice': isDevelopmentDevice,
    'channel': ?channel.value,
    'version': ?version.value,
    'deviceId': ?deviceId.value,
  };
}
