import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex/main.dart';
import 'package:pokedex/data/graphql/graphql_client.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final clientNotifier = GraphQLService.initClient();

    await tester.pumpWidget(MyApp(clientNotifier: clientNotifier));

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
