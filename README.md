# flutter_tencent_bugly

[![pub package](https://img.shields.io/pub/v/flutter_tencent_bugly)](https://pub.dev/packages/flutter_tencent_bugly)
[![GitHub license](https://img.shields.io/github/license/LeoLi-Byte/flutter_tencent_bugly)](https://github.com/LeoLi-Byte/flutter_tencent_bugly/blob/main/LICENSE)

Language: [中文](README-ZH.md) | English

> A lightweight Flutter plugin wrapping [Tencent Bugly](https://bugly.qq.com/v2/index), providing
> **Dart exception capture, native crash / ANR / block monitoring and operational data analysis**,
> with the full native API surface exposed through a simple static Dart API and data reported to
> the Bugly console.

It covers both native and Dart-side errors: Bugly's native crash / ANR / block monitoring is
initialized per platform, while `runGuarded` captures Flutter framework exceptions
(`FlutterError.onError`) and uncaught asynchronous exceptions (`runZonedGuarded`) from the Dart
side and reports them to Bugly — no extra wiring required.

## Getting started

### Version constraints

```yaml
  sdk: ^3.11.0
  flutter: ">=3.41.0"
```

### Step 1: Create products and get your AppIDs

1. Sign in to the [Bugly console](https://bugly.qq.com/v2/index) and create a product for each
   platform (one for Android, one for iOS — each gets its own AppID).
2. Open the product you just created, go to **更多 → 产品设置** in the upper right corner, and
   record the **App ID** for the initialization below.

> This plugin wraps the open-source Bugly (the `crashreport` SDK): **only an AppID is needed** —
> no AppKey, and no traffic package to purchase. Those belong to Bugly Pro (`bugly_pro_flutter`),
> a different, paid offering; don't confuse the two.

### Step 2: Add the dependency

```yaml
dependencies:
  flutter_tencent_bugly: ^1.0.0
```

```dart
import 'package:flutter_tencent_bugly/flutter_tencent_bugly.dart';
```

### Step 3: Initialize and guard the app (recommended)

In `main()`, wrap the entire app with `FlutterTencentBugly.runGuarded` so that Flutter framework
exceptions and unhandled async exceptions are captured and reported automatically, then initialize
Bugly inside it. See [example/lib/main.dart](example/lib/main.dart) for the complete example.

### Step 4: Verify the integration

Trigger a test exception — report one with `FlutterTencentBugly.postException`, or simply throw a
Dart exception (captured automatically by `runGuarded`) — then check the **错误分析** in the
Bugly console a moment later to confirm the report arrived.

## Usage

### User and device metadata

Attach identity and device information to subsequent crash reports:

```dart
await FlutterTencentBugly.setUserId('user_001');
await FlutterTencentBugly.setUserTag(9527);
await FlutterTencentBugly.setDeviceID('device-id');
await FlutterTencentBugly.setVersion('1.0.0');

// Android-only; these are no-ops on other platforms.
await FlutterTencentBugly.setDeviceModel('Pixel 8');
await FlutterTencentBugly.setChannel('play_store'); // on iOS, set the channel in init config instead
await FlutterTencentBugly.setPackageName('com.example.demo');
```

### Custom key-value data

Custom data is attached to crash reports when a crash occurs:

```dart
await FlutterTencentBugly.putUserData(key: 'level', value: 'vip');
```

> At most 50 key-value pairs (extras are dropped). Keys are truncated to 50 bytes and values to
> 200 bytes.

### Report exceptions manually

Caught business exceptions can be reported explicitly:

```dart
try {
  throw const FormatException('simulated business exception');
} catch (e, stack) {
  await FlutterTencentBugly.postException(
    message: e,
    detail: stack,
    type: e.runtimeType,
    extra: <String, dynamic>{'page': 'demo', 'action': 'postCaughtException'},
  );
}
```

### Custom logs

Logs printed through the plugin are uploaded to Bugly together with crash reports:

```dart
await FlutterTencentBugly.log(
  tag: 'BuglyDemo',
  message: 'an INFO level log',
  level: LogLevel.INFO,
);
```

> - **Android**: set `isLogUpload` to `true` in `FlutterTencentBuglyAndroidConfig` for logs to be
>   uploaded to the Bugly server.
> - **iOS**: controlled by `reportLogLevel` in `FlutterTencentBuglyIOSConfig` — the default
>   `BuglyLogLevelSilent (0)` disables log recording; set e.g. `BuglyLogLevelWarn (2)` to upload
>   Warn / Error logs on crash.

## Parameters

### Methods

| Name             | Signature                                                                                                                            | Description                                                                                                                                             |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `init`           | `({FlutterTencentBuglyConfig? config, FlutterTencentBuglyAndroidConfig? android, FlutterTencentBuglyIOSConfig? ios}) → Future<bool>` | Initializes Bugly. A platform is only initialized when its config is passed.                                                                            |
| `setUserId`      | `(String value)`                                                                                                                     | Sets the user ID.                                                                                                                                       |
| `setUserTag`     | `(int value)`                                                                                                                        | Sets the user tag.                                                                                                                                      |
| `setDeviceID`    | `(String value)`                                                                                                                     | Sets the device ID.                                                                                                                                     |
| `setDeviceModel` | `(String value)`                                                                                                                     | Sets the device model. **Android only.**                                                                                                                |
| `setChannel`     | `(String value)`                                                                                                                     | Sets the channel. **Android only** — on iOS, configure it via `FlutterTencentBuglyConfig.channel` at init.                                              |
| `setVersion`     | `(String value)`                                                                                                                     | Sets the app version.                                                                                                                                   |
| `setPackageName` | `(String value)`                                                                                                                     | Sets the package name. **Android only.**                                                                                                                |
| `putUserData`    | `({required String key, required String value})`                                                                                     | Sets custom key-value data, uploaded with crash reports.                                                                                                |
| `postException`  | `({required dynamic message, required dynamic detail, dynamic type, Map<String, dynamic>? extra})`                                   | Reports a custom exception.                                                                                                                             |
| `log`            | `({required String tag, required String message, LogLevel level = LogLevel.INFO})`                                                   | Prints a Bugly log, uploaded with crash reports.                                                                                                        |
| `runGuarded`     | `<T>(ValueGetter<T> body, {FlutterExceptionHandler? onException, String? filterPattern, bool reportInDebugMode = false})`            | Equivalent to `runZonedGuarded`: runs `body` while capturing and reporting framework and async exceptions. Pure Dart; never crosses the method channel. |

### `FlutterTencentBuglyConfig` (common)

| Name                  | Type      | Default       | Description                        |
|-----------------------|-----------|---------------|------------------------------------|
| `isDebugMode`         | `bool`    | `kDebugMode`  | SDK debug information switch.      |
| `isDevelopmentDevice` | `bool`    | `false`       | Marks the device as a dev device.  |
| `channel`             | `String?` | `null`        | Channel.                           |
| `version`             | `String?` | `null`        | App version.                       |
| `deviceId`            | `String?` | `null`        | Unique device identifier.          |

### `FlutterTencentBuglyAndroidConfig`

| Name                      | Type      | Default    | Description                                              |
|---------------------------|-----------|------------|----------------------------------------------------------|
| `appId`                   | `String`  | required   | The AppID registered on the Bugly console.               |
| `packageName`             | `String?` | `null`     | Package name.                                            |
| `deviceModel`             | `String?` | `null`     | Device model.                                            |
| `reportDelay`             | `int`     | `0`        | Init delay interval, in seconds.                         |
| `enableCatchAnrTrace`     | `bool`    | `false`    | Whether to capture the system trace file on ANR.         |
| `enableRecordAnrMainStack`| `bool`    | `true`     | Whether to record the main-thread stack during ANR.      |
| `isLogUpload`             | `bool`    | `true`     | Whether to upload custom logs to Bugly.                  |

### `FlutterTencentBuglyIOSConfig`

| Name                                  | Type     | Default  | Description                                                                                                  |
|---------------------------------------|----------|----------|--------------------------------------------------------------------------------------------------------------|
| `appId`                               | `String` | required | The AppID registered on the Bugly console.                                                                   |
| `blockMonitorEnable`                  | `bool`   | `true`   | Block (UI hang) monitoring switch.                                                                           |
| `blockMonitorTimeout`                 | `int`    | `3`      | Block detection threshold, in seconds.                                                                       |
| `symbolicateInProcessEnable`          | `bool`   | `true`   | In-process symbolication switch.                                                                             |
| `unexpectedTerminatingDetectionEnable`| `bool`   | `true`   | Abnormal-termination event recording switch.                                                                 |
| `viewControllerTrackingEnable`        | `bool`   | `true`   | View controller tracking switch.                                                                             |
| `reportLogLevel`                      | `int`    | `0`      | Controls custom log reporting (`BuglyLogLevel`): 0 Silent, 1 Error, 2 Warn, 3 Info, 4 Debug, 5 Verbose.      |

### `LogLevel`

`ERROR (1)`, `WARN (2)`, `INFO (3)`, `DEBUG (4)`, `VERBOSE (5)` — the `key` ints map to Bugly's
native log-level constants on both platforms.

## Notes

- **Blank arguments are ignored**: calls with a blank string argument have no effect.
- **Exception categories differ per platform**: exceptions reported from Dart are filed under
  Bugly's Flutter-exception category, whose value differs between Android and iOS — filter the
  console accordingly.
- **Example app**: run [example/lib/main.dart](example/lib/main.dart) to exercise the full
  API — metadata setters, all log levels, and every kind of exception reporting.

> If you like my project, please click "Star" in the upper right corner of the project. Your
> support is my biggest encouragement! ^_^