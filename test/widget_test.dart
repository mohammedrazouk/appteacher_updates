import 'package:flutter_test/flutter_test.dart';

import 'package:appteacher/main.dart';

void main() {
  testWidgets('App renders home screen with logo and menu cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ItqanApp());

    expect(find.text('إتقان للتعليم والتنمية'), findsOneWidget);
    expect(find.text('حساب تحقيق الخطة'), findsOneWidget);
    expect(find.text('تقييم الصفحة'), findsOneWidget);
    expect(find.text('سلالم الاختبار'), findsOneWidget);
  });
}
