# flutter_tencent_bugly

[![pub package](https://img.shields.io/pub/v/flutter_tencent_bugly)](https://pub.dev/packages/flutter_tencent_bugly)
[![GitHub license](https://img.shields.io/github/license/LeoLi-Byte/flutter_tencent_bugly)](https://github.com/LeoLi-Byte/flutter_tencent_bugly/blob/main/LICENSE)

语言： 中文 | [English](README.md)

> 一个轻量级的 Flutter 插件，封装 [腾讯 Bugly](https://bugly.qq.com/v2/index)，提供
> **Dart 异常捕获、原生 Crash / ANR / 卡顿监控与运营数据分析**能力，通过简洁的静态 Dart
> API 暴露完整的原生接口，并上报数据到 Bugly 平台。

插件同时覆盖原生与 Dart 两侧的错误：Bugly 的原生 Crash / ANR / 卡顿监控按平台初始化，而
`runGuarded` 则从 Dart 侧捕获 Flutter 框架异常（`FlutterError.onError`）与未处理的异步异常
（`runZonedGuarded`）并上报到 Bugly —— 无需额外接线。

## 快速开始

### 版本约束

```yaml
  sdk: ^3.11.0
  flutter: ">=3.41.0"
```

### 第一步：创建产品，获取 App ID

1. 登录 [Bugly 平台](https://bugly.qq.com/v2/index)创建产品，接入平台分别选择 Android 与
   iOS（双端各创建一个产品，各有一个 App ID）。
2. 进入刚创建的产品，打开 右上角 **更多 → 产品设置**，记录下 **App ID**，后续初始化时使用。

> 本插件封装的是开源版 Bugly（crashreport SDK），**仅需 App ID**，无需 AppKey，也无需购买
> 流量包 —— 那是 Bugly Pro（`bugly_pro_flutter`）的计费模式，二者不要混淆。

### 第二步：添加依赖

```yaml
dependencies:
  flutter_tencent_bugly: ^1.0.0
```

```dart
import 'package:flutter_tencent_bugly/flutter_tencent_bugly.dart';
```

### 第三步：初始化并守护应用（推荐）

在 `main()` 中使用 `FlutterTencentBugly.runGuarded` 包裹整个应用，自动捕获并上报 Flutter
框架异常与未处理的异步异常，然后在其中初始化 Bugly。完整示例见 [example/lib/main.dart](example/lib/main.dart)。

### 第四步：验证接入

触发一个测试异常 —— 调用 `FlutterTencentBugly.postException` 上报一条自定义异常，或直接
抛出一个 Dart 异常（由 `runGuarded` 自动捕获），稍后到 Bugly 控制台的 **错误分析** 中查看
上报结果，确认接入成功。

## 使用方法

### 用户与设备信息

为后续的崩溃报告附加身份与设备信息：

```dart
await FlutterTencentBugly.setUserId('user_001');
await FlutterTencentBugly.setUserTag(9527);
await FlutterTencentBugly.setDeviceID('device-id');
await FlutterTencentBugly.setVersion('1.0.0');

// 仅支持 Android，其他平台为空操作
await FlutterTencentBugly.setDeviceModel('Pixel 8');
await FlutterTencentBugly.setChannel('play_store'); // iOS 请在初始化配置中设置渠道
await FlutterTencentBugly.setPackageName('com.example.demo');
```

### 自定义 Key-Value 数据

自定义数据会在发生 Crash 时随之上报：

```dart
await FlutterTencentBugly.putUserData(key: 'level', value: 'vip');
```

> 最多可以有 50 对自定义的 key-value（超过则添加失败）；key 限长 50 字节，value 限长
> 200 字节，过长截断。

### 手动上报异常

已捕获的业务异常可以显式上报：

```dart
try {
  throw const FormatException('模拟的业务异常');
} catch (e, stack) {
  await FlutterTencentBugly.postException(
    message: e,
    detail: stack,
    type: e.runtimeType,
    extra: <String, dynamic>{'page': 'demo', 'action': 'postCaughtException'},
  );
}
```

### 自定义日志

通过插件输出的日志，发生 Crash 时会随之上报：

```dart
await FlutterTencentBugly.log(
  tag: 'BuglyDemo',
  message: '一条 INFO 级别的日志',
  level: LogLevel.INFO,
);
```

> - **Android**：需在初始化时将 `FlutterTencentBuglyAndroidConfig.isLogUpload` 设为
>   `true`，日志才会上传到 Bugly 服务器。
> - **iOS**：由 `FlutterTencentBuglyIOSConfig.reportLogLevel` 控制 —— 默认
>   `BuglyLogLevelSilent (0)` 关闭日志记录；例如设置为 `BuglyLogLevelWarn (2)`，则在崩溃
>   时会上报 Warn、Error 接口打印的日志。

## 参数说明

### 方法

| 名称               | 签名                                                                                                                                   | 说明                                                                          |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `init`           | `({FlutterTencentBuglyConfig? config, FlutterTencentBuglyAndroidConfig? android, FlutterTencentBuglyIOSConfig? ios}) → Future<bool>` | 初始化 Bugly。未传入对应平台的配置时，该平台不会执行初始化                                            |
| `setUserId`      | `(String value)`                                                                                                                     | 设置用户 ID                                                                     |
| `setUserTag`     | `(int value)`                                                                                                                        | 设置用户标签                                                                      |
| `setDeviceID`    | `(String value)`                                                                                                                     | 设置设备 ID                                                                     |
| `setDeviceModel` | `(String value)`                                                                                                                     | 设置设备型号。**仅支持 Android**                                                      |
| `setChannel`     | `(String value)`                                                                                                                     | 设置渠道。**仅支持 Android** —— iOS 请通过初始化时的 `FlutterTencentBuglyConfig.channel` 配置 |
| `setVersion`     | `(String value)`                                                                                                                     | 设置版本号                                                                       |
| `setPackageName` | `(String value)`                                                                                                                     | 设置包名。**仅支持 Android**                                                        |
| `putUserData`    | `({required String key, required String value})`                                                                                     | 设置自定义 Key-Value 数据，发生 Crash 时随之上报                                           |
| `postException`  | `({required dynamic message, required dynamic detail, dynamic type, Map<String, dynamic>? extra})`                                   | 上报自定义异常                                                                     |
| `log`            | `({required String tag, required String message, LogLevel level = LogLevel.INFO})`                                                   | 输出 Bugly 日志，发生 Crash 时随之上报                                                  |
| `runGuarded`     | `<T>(ValueGetter<T> body, {FlutterExceptionHandler? onException, String? filterPattern, bool reportInDebugMode = false})`            | 等同于 `runZonedGuarded`：运行 `body` 并捕获上报框架异常与异步异常。纯 Dart 实现，不经过方法通道            |

### `FlutterTencentBuglyConfig`（公共配置）

| 名称                    | 类型        | 默认值          | 说明             |
|-----------------------|-----------|--------------|----------------|
| `isDebugMode`         | `bool`    | `kDebugMode` | SDK Debug 信息开关 |
| `isDevelopmentDevice` | `bool`    | `false`      | 是否开发设备         |
| `channel`             | `String?` | `null`       | 渠道             |
| `version`             | `String?` | `null`       | 版本号            |
| `deviceId`            | `String?` | `null`       | 设备唯一标识         |

### `FlutterTencentBuglyAndroidConfig`

| 名称                         | 类型        | 默认值     | 说明                        |
|----------------------------|-----------|---------|---------------------------|
| `appId`                    | `String`  | 必填      | 在 Bugly 平台创建产品时申请的 App ID |
| `packageName`              | `String?` | `null`  | 包名                        |
| `deviceModel`              | `String?` | `null`  | 设备型号                      |
| `reportDelay`              | `int`     | `0`     | 初始化延迟间隔，单位为秒              |
| `enableCatchAnrTrace`      | `bool`    | `false` | ANR 时是否获取系统 trace 文件      |
| `enableRecordAnrMainStack` | `bool`    | `true`  | 是否获取 ANR 过程中的主线程堆栈        |
| `isLogUpload`              | `bool`    | `true`  | 是否上传自定义日志到 Bugly          |

### `FlutterTencentBuglyIOSConfig`

| 名称                                     | 类型       | 默认值    | 说明                                                                          |
|----------------------------------------|----------|--------|-----------------------------------------------------------------------------|
| `appId`                                | `String` | 必填     | 在 Bugly 平台创建产品时申请的 App ID                                                   |
| `blockMonitorEnable`                   | `bool`   | `true` | 卡顿监控开关                                                                      |
| `blockMonitorTimeout`                  | `int`    | `3`    | 卡顿监控判断间隔，单位为秒                                                               |
| `symbolicateInProcessEnable`           | `bool`   | `true` | 进程内还原开关                                                                     |
| `unexpectedTerminatingDetectionEnable` | `bool`   | `true` | 非正常退出事件记录开关                                                                 |
| `viewControllerTrackingEnable`         | `bool`   | `true` | 页面信息记录开关                                                                    |
| `reportLogLevel`                       | `int`    | `0`    | 控制自定义日志上报（`BuglyLogLevel`）：0 Silent、1 Error、2 Warn、3 Info、4 Debug、5 Verbose |

### `LogLevel`

`ERROR (1)`、`WARN (2)`、`INFO (3)`、`DEBUG (4)`、`VERBOSE (5)` —— `key` 的值分别映射
到双端 Bugly 原生日志级别常量。

## 注意事项

- **空白参数会被忽略**：传入空白字符串参数时，本次调用不生效。
- **双端异常类别不同**：Dart 侧上报的异常在控制台归属 Flutter 异常类别，Android 与 iOS 的 类别值不同，筛选时请注意区分。
- **示例应用**：运行 [example/lib/main.dart](example/lib/main.dart) 可以体验完整 API —— 元数据设置、全部日志级别，以及各类异常的上报。

> 如果您喜欢我的项目，请点击项目右上角的 “Star”。您的支持是我最大的鼓励！ ^_^