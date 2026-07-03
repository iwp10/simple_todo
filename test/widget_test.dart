import 'package:flutter_test/flutter_test.dart';

import 'package:simple_todo/app/app.dart';

void main() {
  testWidgets('App shows splash screen placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Splash screen placeholder'), findsOneWidget);
  });
}
