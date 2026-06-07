import 'package:flutter_test/flutter_test.dart';

import 'package:tcg_app/main.dart';

void main() {
  testWidgets('shows the TCG home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('TCG App'), findsOneWidget);
  });
}
