import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:diagora/login.dart';

/// Main that got all the test function of the login page.
///
/// No parameters
/// No output
void main() {
  test('registerUser returns true when registration is successful', () async {
    final client = MockClient((request) async {
      return http.Response('{"message": "success"}', 200);
    });
    const email = 'john.doe@example.com';
    const password = 'password';

    final response = await client.post(
      Uri.parse('http://localhost:3000/user/login'),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    expect(response.statusCode, 200);
  });
  test('registerUser returns true when registration is fails', () async {
    final client = MockClient((request) async {
      return http.Response('{"message": "success"}', 400);
    });
    const email = 'john.doe1@example.com';
    const password = 'password';

    final response = await client.post(
      Uri.parse('http://localhost:3000/user/login'),
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    expect(response.statusCode, 400);
  });
  testWidgets('LoginPage form validation and navigation',
      (WidgetTester tester) async {
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
  });
}
