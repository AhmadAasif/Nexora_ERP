import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_erp/main.dart';

void main() {
  testWidgets('NEXORA dashboard loads', (WidgetTester tester) async {
    await tester.pumpWidget(const NexoraApp());

    expect(find.text('NEXORA'), findsOneWidget);
    expect(find.text('Good morning, Ahmad 👋'), findsOneWidget);
    expect(find.text('Revenue overview'), findsOneWidget);
  });
}
