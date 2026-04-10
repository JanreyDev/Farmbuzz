import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/app/app.dart';

void main() {
  testWidgets('Splash transitions to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      FarmBuzzApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
      ),
    );

    expect(find.text('FarmBuzz'), findsOneWidget);
    expect(find.text('Your Farm. Your Community.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Manage Your Farm'), findsOneWidget);
  });
}
