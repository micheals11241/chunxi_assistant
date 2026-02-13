import 'package:flutter_test/flutter_test.dart';
import 'package:chunxi_assistant/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ChunxiAssistantApp());

    // Verify the app title is displayed
    expect(find.text('春禧'), findsOneWidget);
    expect(find.text('助手'), findsOneWidget);
  });
}
