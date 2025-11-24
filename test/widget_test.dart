import 'package:flutter_test/flutter_test.dart';

import 'package:ff_pockedex/main.dart';

void main() {
  testWidgets('App should render without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const PokedexApp());
    expect(find.text('Pokedex'), findsOneWidget);
  });
}