import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart';

void main() {
  testWidgets('Login screen renders expected actions', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmBuzzApp());

    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Forgot your PIN?'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);
  });
}
