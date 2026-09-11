import 'package:flutter_test/flutter_test.dart';
import 'package:rong/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const RongApp());
    expect(find.text('RONG'), findsOneWidget);
  });
}
