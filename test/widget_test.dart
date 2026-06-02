import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinLitApp(isRegistered: false));
    expect(find.text('FinLit India'), findsWidgets);
  });
}
