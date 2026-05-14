import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart';

void main() {
  testWidgets('Login screen renders expected actions', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmBuzzApp());

    expect(find.text('Log into FarmBuzz'), findsOneWidget);
    expect(find.text('Forgot PIN?'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);
  });
}
