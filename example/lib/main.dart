import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tencent_bugly/flutter_tencent_bugly.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 替换为在 Bugly 平台申请的 AppID
const String _androidAppId = '8507a6053d';
const String _iosAppId = '56585da812';

void main() {
  /// 使用 [FlutterTencentBugly.runGuarded] 包裹整个应用，自动捕获并上报
  /// Flutter 框架异常（FlutterError.onError）与未处理的异步异常（Zone）。
  FlutterTencentBugly.runGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      /// 初始化 Bugly，传入哪个平台的配置就初始化哪个平台
      final bool success = await FlutterTencentBugly.init(
        config: const FlutterTencentBuglyConfig(
          channel: 'demo',
          version: '1.0.0',
          isDebugMode: true,
          isDevelopmentDevice: true,
        ),
        android: const FlutterTencentBuglyAndroidConfig(appId: _androidAppId, reportDelay: 10),
        ios: const FlutterTencentBuglyIOSConfig(appId: _iosAppId, reportLogLevel: 2),
      );
      debugPrint('Bugly 初始化${success ? '成功' : '失败'}');

      runApp(const BuglyExampleApp());
    },
    onException: (FlutterErrorDetails details) {
      /// 自定义异常处理（不影响上报），可用于日志打印、双上报等定制逻辑
      FlutterError.presentError(details);
    },

    /// 命中该正则的异常不上报
    filterPattern: 'IgnoreMe',

    /// Demo 中开启调试模式上报，生产环境建议保持默认 false
    reportInDebugMode: true,
  );
}

class BuglyExampleApp extends StatelessWidget {
  const BuglyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bugly Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const BuglyHomePage(),
    );
  }
}

class BuglyHomePage extends StatefulWidget {
  const BuglyHomePage({super.key});

  @override
  State<BuglyHomePage> createState() => _BuglyHomePageState();
}

class _BuglyHomePageState extends State<BuglyHomePage> {
  String _platformVersion = '获取中…';
  String _appVersion = '获取中…';
  final List<String> _logs = <String>[];

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    String version;
    try {
      version = await FlutterTencentBugly().getPlatformVersion() ?? 'Unknown';
    } catch (_) {
      version = '获取失败';
    }
    if (!mounted) return;
    setState(() => _platformVersion = version);

    final PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  void _addLog(String message) {
    if (!mounted) return;
    final String time = DateTime.now().toString().substring(11, 19);
    setState(() => _logs.insert(0, '[$time] $message'));
  }

  /// 执行一个插件调用并记录结果
  Future<void> _run(String label, Future<void> Function() action) async {
    try {
      await action();
      _addLog('✅ $label');
    } catch (e) {
      _addLog('❌ $label：$e');
    }
  }

  /// 手动捕获并上报一个业务异常
  Future<void> _postCaughtException() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bugly Example')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('平台版本'),
                    subtitle: Text(_platformVersion),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('应用版本'),
                    subtitle: Text(_appVersion),
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: '用户信息',
                  children: <Widget>[
                    _ActionButton(
                      label: '设置用户ID',
                      onPressed: () => _run('设置用户ID', () => FlutterTencentBugly.setUserId('demo_user_001')),
                    ),
                    _ActionButton(
                      label: '设置用户标签',
                      onPressed: () => _run('设置用户标签', () => FlutterTencentBugly.setUserTag(9527)),
                    ),
                    _ActionButton(
                      label: '设置自定义数据',
                      onPressed: () =>
                          _run('设置自定义数据', () => FlutterTencentBugly.putUserData(key: 'level', value: 'vip')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: '设备信息',
                  children: <Widget>[
                    _ActionButton(
                      label: '设置设备ID',
                      onPressed: () => _run('设置设备ID', () => FlutterTencentBugly.setDeviceID('demo-device-id')),
                    ),
                    _ActionButton(
                      label: '设置设备型号 (Android)',
                      onPressed: () => _run('设置设备型号', () => FlutterTencentBugly.setDeviceModel('Pixel 8')),
                    ),
                    _ActionButton(
                      label: '设置版本号',
                      onPressed: () => _run('设置版本号', () => FlutterTencentBugly.setVersion(_appVersion)),
                    ),
                    _ActionButton(
                      label: '设置渠道 (Android)',
                      onPressed: () => _run('设置渠道', () => FlutterTencentBugly.setChannel('play_store')),
                    ),
                    _ActionButton(
                      label: '设置包名 (Android)',
                      onPressed: () => _run('设置包名', () => FlutterTencentBugly.setPackageName('com.example.demo')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: '日志（Crash 时随之上报）',
                  children: <Widget>[
                    for (final LogLevel level in LogLevel.values)
                      _ActionButton(
                        label: level.name,
                        onPressed: () => _run(
                          '输出 ${level.name} 日志',
                          () => FlutterTencentBugly.log(
                            tag: 'BuglyDemo',
                            message: '这是一条 ${level.name} 级别的日志',
                            level: level,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: '异常上报',
                  children: <Widget>[
                    _ActionButton(label: '上报已捕获异常', onPressed: () => _run('上报已捕获异常', _postCaughtException)),
                    _ActionButton(
                      label: '上报自定义异常',
                      onPressed: () => _run(
                        '上报自定义异常',
                        () => FlutterTencentBugly.postException(
                          message: '自定义异常信息',
                          detail: '自定义异常堆栈/详情',
                          type: 'CustomError',
                          extra: <String, dynamic>{'key': 'value'},
                        ),
                      ),
                    ),
                    _ActionButton(
                      label: '抛出同步异常',
                      onPressed: () {
                        _addLog('💥 抛出同步异常（由 FlutterError.onError 捕获上报）');
                        throw StateError('这是一个同步异常，用于测试框架异常捕获');
                      },
                    ),
                    _ActionButton(
                      label: '抛出异步异常',
                      onPressed: () {
                        _addLog('💥 抛出异步异常（由 runZonedGuarded 捕获上报）');
                        unawaited(
                          Future<void>.delayed(
                            const Duration(milliseconds: 300),
                            () => throw StateError('这是一个未处理的异步异常'),
                          ),
                        );
                      },
                    ),
                    _ActionButton(
                      label: '抛出被过滤异常',
                      onPressed: () {
                        _addLog('🚫 抛出 IgnoreMe 异常（命中 filterPattern，不上报）');
                        throw StateError('IgnoreMe: 该异常会被 filterPattern 过滤');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 160,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: _logs.isEmpty
                ? const Center(child: Text('操作日志'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (BuildContext context, int index) =>
                        Text(_logs[index], style: Theme.of(context).textTheme.bodySmall),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 分组标题 + 按钮区域
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

/// 统一风格的操作按钮
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(onPressed: onPressed, child: Text(label));
  }
}
