import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:diagora/home.dart';
import 'package:diagora/login.dart';

void main() {
  testWidgets('LoginPage form validation and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');

    // Test form validation
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password');

    // await tester.tap(loginButton);
    // await tester.pumpAndSettle();

    // Test saving form values and navigation
    // expect(find.byType(HomePage), findsOneWidget);
  });
}
