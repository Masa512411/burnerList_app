import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We need to wrap in ProviderScope for Riverpod
    await tester.pumpWidget(const ProviderScope(child: BurnerListApp()));

    // Verify that our title is present
    expect(find.text('Burner List'), findsOneWidget);
    expect(find.text('FRONT BURNER'), findsOneWidget);
    expect(find.text('BACK BURNER'), findsOneWidget);
  });
}
