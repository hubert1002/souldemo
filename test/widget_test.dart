import 'package:flutter_test/flutter_test.dart';

import 'package:xingyu/main.dart';

void main() {
  testWidgets('星语首页可以正常渲染', (WidgetTester tester) async {
    await tester.pumpWidget(const XingyuApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('晚上好，星野 ✦'), findsOneWidget);
    expect(find.text('星球'), findsOneWidget);
    expect(find.text('广场'), findsOneWidget);
    expect(find.text('消息'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
