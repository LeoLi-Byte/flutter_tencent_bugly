## 1.0.0

Initial release of `flutter_tencent_bugly`, a lightweight Flutter plugin wrapping Tencent Bugly
for exception capture and operational data analysis.

### Features

* `init` with a common config plus per-platform configs — Android / iOS are initialized
  independently, only when the corresponding config is passed.
* User and device metadata: `setUserId`, `setUserTag`, `setDeviceID`, `setVersion`,
  plus Android-only `setDeviceModel`, `setChannel` and `setPackageName`.
* `putUserData` for custom key-value data attached to crash reports.
* `postException` for reporting caught exceptions with type and extra data.
* `log` for custom logs uploaded with crash reports, with five `LogLevel`s mapped to Bugly's
  native log-level constants on both platforms.
* `runGuarded` for Dart-side global exception capture: wraps the app in `runZonedGuarded` and
  reports Flutter framework exceptions (`FlutterError.onError`) and uncaught async exceptions
  (`PlatformDispatcher.onError`). Supports a custom `onException` hook, a `filterPattern`
  exclusion regex, and `reportInDebugMode` gating. Previously registered error handlers are
  chained instead of replaced.

### Android

* Bugly `crashreport` 4.1.9.3 from Maven, minSdk 24.
* Configurable ANR monitoring (`enableCatchAnrTrace`, `enableRecordAnrMainStack`), init delay
  (`reportDelay`) and log upload (`isLogUpload`).

### iOS

* Vendored `Bugly.xcframework`, supporting both CocoaPods and Swift Package Manager.
* Configurable block monitoring (`blockMonitorEnable`, `blockMonitorTimeout`), in-process
  symbolication, abnormal-termination detection, view controller tracking and report log level
  (`reportLogLevel`).

### Miscellaneous

* Example app demonstrating the full API surface.
* Unit tests for the Dart method channel and the Android native side.