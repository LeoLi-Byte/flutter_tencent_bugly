# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`flutter_tencent_bugly` is a lightweight Flutter plugin wrapping Tencent Bugly for exception capture and operational data analysis. The Bugly SDK is integrated on both platforms and the full API surface is implemented: `init`, user/device metadata setters, `putUserData`, `postException`, `log`, and `runGuarded` (Dart-side global exception capture).

- Android package: `org.leoli.plugin.flutter_tencent_bugly` (Kotlin DSL build, minSdk 24, compileSdk 36, Java 17, AGP 8.11.1, Kotlin 2.2.20). Bugly comes from Maven: `com.tencent.bugly:crashreport:4.1.9.3`. `android/proguard-rules.pro` keeps `com.tencent.bugly.**` as a consumer ProGuard file.
- iOS: Swift, minimum iOS 15.0, distributed both as a CocoaPods podspec (`ios/flutter_tencent_bugly.podspec`) and a SwiftPM package (`ios/flutter_tencent_bugly/Package.swift`) — keep both in sync when adding source files or resources. Bugly is a vendored static `Bugly.xcframework` (SwiftPM `binaryTarget` / podspec `vendored_frameworks`, linking `SystemConfiguration`, `Security`, `c++`, `z`).
  - **`-ObjC` is mandatory** (podspec `OTHER_LDFLAGS` / Package.swift `unsafeFlags` — never remove either). Bugly's category-only object files (e.g. `BLYTrace+Log.o`) export no referenced symbols, so without `-ObjC` the linker drops them and calls like `+[BLYTrace logTrace:immediately:]` crash at runtime with `unrecognized selector` (seen in `postException`'s persist path). Host apps that already link WeChat/Tencent SDKs often carry `-ObjC` from those pods and mask this — the plugin must declare it itself.
- Requires Dart SDK ^3.11.0 / Flutter >=3.41.0.

## Common Commands

```bash
flutter pub get                  # install dependencies
flutter analyze                  # static analysis (strict lints, see below)
dart format .                    # format (page width 120, enforced in analysis_options.yaml)
flutter test                     # run all Dart unit tests
flutter test test/flutter_tencent_bugly_method_channel_test.dart   # single test file

# Android native unit tests (Kotlin, JUnit5 + Mockito):
cd android && ./gradlew test     # or use example/android/gradlew with the plugin as included build

# Run the example app (manual verification of native integration):
cd example && flutter run

# iOS podspec validation before publishing:
pod lib lint ios/flutter_tencent_bugly.podspec
```

## Architecture

Standard Flutter plugin layered architecture; every new plugin capability must touch each layer:

1. **Public Dart API** — `lib/interface/flutter_tencent_bugly.dart`: `FlutterTencentBugly` exposes **static** methods that delegate to the platform interface. This file uses `part`/`part of` to compose the three Dart files in `lib/interface/` — preserve this pattern (no direct imports between them).
2. **Platform interface** — `lib/interface/flutter_tencent_bugly_platform_interface.dart`: abstract `FlutterTencentBuglyPlatform` extending `PlatformInterface` with token verification. New methods must be added here (throwing `UnimplementedError`) before implementing. Doc comments live here as `{@template}` blocks referenced from the public API via `{@macro}`.
3. **Method channel implementation** — `lib/interface/flutter_tencent_bugly_method_channel.dart`: `MethodChannelFlutterTencentBugly`, channel name `flutter_tencent_bugly`. This layer also **gates platform-specific methods** (e.g. `setDeviceModel`/`setChannel`/`setPackageName` are Android-only and no-op elsewhere) and **silently drops blank string arguments** — the native side re-validates rather than trusting the channel.
4. **Android** — `android/src/main/kotlin/org/leoli/plugin/flutter_tencent_bugly/FlutterTencentBuglyPlugin.kt`: `FlutterPlugin` + `MethodCallHandler` with a `when` on `call.method`.
5. **iOS** — `ios/flutter_tencent_bugly/Sources/flutter_tencent_bugly/FlutterTencentBuglyPlugin.swift`: `FlutterPlugin` with a `switch` on `call.method`. There is a second target, **`Sources/BuglyLogBridge/`** (Objective-C), because Bugly's `BLYLog*` macros are not callable from Swift; the Swift file imports it conditionally (`#if canImport(BuglyLogBridge)`) since it's a separate module under SwiftPM but same-module under CocoaPods.

Method names **and argument keys** must match exactly across the Dart channel call, the Kotlin `when`, and the Swift `switch`.

### Supporting Dart code (`lib/src/`)

- `config.dart` — three config classes serialized to `Map<String, dynamic>` and merged into one `init` payload: `FlutterTencentBuglyConfig` (common), `FlutterTencentBuglyAndroidConfig`, `FlutterTencentBuglyIOSConfig` (per-platform init options; a platform is only initialized when its config is passed). Note the Dart 3 dot-shorthand / `?`-key syntax (`'key': ?value.value`) used for nullable entries — match this style.
- `log_level.dart` — `LogLevel` enum whose `key` ints (1–5) map to Bugly's native log-level constants on both platforms.
- `extension_string.dart` — `String?` extensions (`isBlank`, `value`) used throughout for the blank-dropping behavior.

### `runGuarded` is pure Dart

`runGuarded` never crosses the method channel: it wraps the app in `runZonedGuarded` and installs `FlutterError.onError` + `PlatformDispatcher.onError` **once** (guarded by `_errorHandlersInstalled`), chaining any previously registered handlers instead of replacing them. Caught exceptions go through the optional user `onException` hook, then `filterPattern`/`reportInDebugMode` gating, then `postException`. Crash category constants differ per platform (Android `8` = Flutter exception, iOS `5`) — don't "unify" them without checking Bugly's category semantics.

## Lint and Style

`analysis_options.yaml` is derived from the flutter/flutter repo's ruleset and is much stricter than the default: `strict-casts`, `strict-inference`, `always_specify_types`, `always_declare_return_types`, `prefer_single_quotes`, `require_trailing_commas`, `directives_ordering`, `unawaited_futures`, and formatter page width 120. Run `flutter analyze` and `dart format .` before considering Dart work done.

## Release Process

`.github/workflows/release.yml` triggers on pushing a version tag matching `[0-9]+.[0-9]+.[0-9]+*`. It extracts the section of `CHANGELOG.md` headed `## <version>` into the GitHub Release notes. So when releasing: bump `version` in `pubspec.yaml` (and the podspec), add a matching `## x.y.z` section to `CHANGELOG.md`, then push the tag.