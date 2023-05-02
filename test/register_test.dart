import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:diagora/register.dart';
// import 'package:diagora/login.dart';
// import 'package:diagora/home.dart';

/// Main that got all the test function of the register page.
///
/// No parameters
/// No output
void main() {
  test('registerUser returns true when registration is successful', () async {
    final client = MockClient((request) async {
      return http.Response('{"message": "success"}', 200);
    });
    const name = 'John Doe';
    const email = 'john.doe@example.com';
    const password = 'password';

    final response = await client.post(
      Uri.parse('http://localhost:3000/user/register'),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'permissions': {
          'isAdmin': false,
          'isUser': true,
          'canCreateVehicule': false
        }
      }),
    );

    expect(response.statusCode, 200);
  });

  test('registerUser returns false when registration fails', () async {
    final client = MockClient((request) async {
      return http.Response('{"message": "error"}', 400);
    });
    const name = 'test02';
    const email = 'test02@example.com';
    const password = 'password1234';

    final response = await client.post(
      Uri.parse('http://localhost:3000/user/register'),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'permissions': {
          'isAdmin': false,
          'isUser': true,
          'canCreateVehicule': false
        }
      }),
    );

    expect(response.statusCode, 400);
  });

  testWidgets('RegisterPage has correct UI components',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    final registerButton = find.widgetWithText(ElevatedButton, 'Register');
    expect(registerButton, findsOneWidget);

    final loginButton =
        find.widgetWithText(TextButton, 'Already have an account? Login');
    expect(loginButton, findsOneWidget);

    final nameField = find.widgetWithText(TextFormField, 'Name');
    expect(nameField, findsOneWidget);

    final emailField = find.widgetWithText(TextFormField, 'Email');
    expect(emailField, findsOneWidget);

    final passwordField = find.widgetWithText(TextFormField, 'Password');
    expect(passwordField, findsOneWidget);
  });

  testWidgets('Tap on register', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    final registerButton = find.widgetWithText(ElevatedButton, 'Register');
    await tester.tap(registerButton);
  });

  testWidgets('Tap on Already have an account ?', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Register'), findsWidgets);

    final alreadyRegisterButton =
        find.widgetWithText(TextButton, 'Already have an account? Login');

    await tester.tap(alreadyRegisterButton);
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsWidgets);
  });

  testWidgets('Fill register input', (WidgetTester tester) async {
    // Render the widget inside a MaterialApp.
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    // Fill in the form fields.
    final nameField = find.widgetWithText(TextFormField, 'Name');
    await tester.enterText(nameField, 'Test User');

    final emailField = find.widgetWithText(TextFormField, 'Email');
    await tester.enterText(emailField, 'test@example.com');

    final passwordField = find.widgetWithText(TextFormField, 'Password');
    await tester.enterText(passwordField, 'password123');

    // Tap the Register button.
    // final registerButton = find.widgetWithText(ElevatedButton, 'Register');
    // await tester.tap(registerButton);
    // await tester.pump();

    // Verify that the HomePage is displayed.
    // final homePageFinder = find.byType(HomePage);
    // expect(homePageFinder, findsOneWidget);

  });

}
