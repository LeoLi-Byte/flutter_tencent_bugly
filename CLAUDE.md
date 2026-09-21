# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`flutter_tencent_bugly` is a lightweight Flutter **federated-style plugin** wrapping Tencent Bugly for exception capture and operational data analysis. It is in early scaffolding state (v0.0.1): the full plugin plumbing (Dart API, method channel, platform interface, Android Kotlin and iOS Swift handlers) exists, but only the template `getPlatformVersion` method is implemented. The actual Bugly SDK integration is still to be built — note `android/proguard-rules.pro` already keeps `com.tencent.bugly.**` and an iOS `PrivacyInfo.xcprivacy` placeholder is in place.

- Android package: `org.leoli.plugin.flutter_tencent_bugly` (Kotlin, minSdk 24, compileSdk 36, Java 17, AGP 8.11.1, Kotlin 2.2.20)
- iOS: Swift, minimum iOS 15.0, distributed both as a CocoaPods podspec (`ios/flutter_tencent_bugly.podspec`) and a SwiftPM package (`ios/flutter_tencent_bugly/Package.swift`) — keep both in sync when adding source files or resources.
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

1. **Public Dart API** — `lib/interface/flutter_tencent_bugly.dart`: `FlutterTencentBugly` class delegates to the platform interface. This file uses `part`/`part of` to compose the three Dart files in `lib/interface/` — preserve this pattern (no direct imports between them).
2. **Platform interface** — `lib/interface/flutter_tencent_bugly_platform_interface.dart`: abstract `FlutterTencentBuglyPlatform` extending `PlatformInterface` with token verification. New methods must be added here (throwing `UnimplementedError`) before implementing.
3. **Method channel implementation** — `lib/interface/flutter_tencent_bugly_method_channel.dart`: `MethodChannelFlutterTencentBugly`, channel name `flutter_tencent_bugly`.
4. **Android** — `android/src/main/kotlin/org/leoli/plugin/flutter_tencent_bugly/FlutterTencentBuglyPlugin.kt`: `FlutterPlugin` + `MethodCallHandler`.
5. **iOS** — `ios/flutter_tencent_bugly/Sources/flutter_tencent_bugly/FlutterTencentBuglyPlugin.swift`: `FlutterPlugin` with a `switch` on `call.method`.

Method names must match exactly across the Dart channel call, the Kotlin `if/when`, and the Swift `switch`.

## Lint and Style

`analysis_options.yaml` is derived from the flutter/flutter repo's ruleset and is much stricter than the default: `strict-casts`, `strict-inference`, `always_specify_types`, `always_declare_return_types`, `prefer_single_quotes`, `require_trailing_commas`, `directives_ordering`, `unawaited_futures`, and formatter page width 120. Run `flutter analyze` and `dart format .` before considering Dart work done.

## Release Process

`.github/workflows/release.yml` triggers on pushing a version tag matching `[0-9]+.[0-9]+.[0-9]+*`. It extracts the section of `CHANGELOG.md` headed `## <version>` into the GitHub Release notes. So when releasing: bump `version` in `pubspec.yaml` (and the podspec), add a matching `## x.y.z` section to `CHANGELOG.md`, then push the tag.