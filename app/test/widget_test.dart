import 'package:flutter_test/flutter_test.dart';

import 'package:app/app/app.dart';

void main() {
  testWidgets('Splash transitions to home', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmBuzzApp());

    expect(find.text('FarmBuzz'), findsOneWidget);
    expect(find.text('Connect. Breed. Compete.'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('Connect. Breed. Compete.'), findsOneWidget);
  });
}
