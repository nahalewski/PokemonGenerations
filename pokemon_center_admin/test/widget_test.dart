import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_center/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App loads dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PokemonCenterApp(),
      ),
    );

    // Verify that we are on the dashboard
    expect(find.text('POKEMON CENTER'), findsOneWidget);
  });
}
