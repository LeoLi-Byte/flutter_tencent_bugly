// Basic widget test for the Bugly example app.

import 'package:flutter_tencent_bugly_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Renders all demo sections', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const BuglyExampleApp());
    await tester.pump();

    // Verify the page sections are present, scrolling the lazily-built
    // list until the last one becomes visible.
    expect(find.text('平台版本'), findsOneWidget);
    expect(find.text('应用版本'), findsOneWidget);
    expect(find.text('用户信息'), findsOneWidget);
    expect(find.text('设备信息'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('日志（Crash 时随之上报）'), 200);
    expect(find.text('日志（Crash 时随之上报）'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('异常上报'), 200);
    expect(find.text('异常上报'), findsOneWidget);
  });
}
