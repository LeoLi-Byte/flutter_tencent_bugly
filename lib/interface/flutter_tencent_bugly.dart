library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'flutter_tencent_bugly_method_channel.dart';

part 'flutter_tencent_bugly_platform_interface.dart';

class FlutterTencentBugly {
  Future<String?> getPlatformVersion() {
    return FlutterTencentBuglyPlatform.instance.getPlatformVersion();
  }
}
