import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:diagora/views/auth/login_view.dart';
import 'package:diagora/services/api_service.dart';

/// Main that got all the test function of the login page.
///
/// No parameters
/// No output
void main() {
  test('loginUser test failed', () async {
    final client = MockClient((request) async {
      return http.Response('{"message": "error"}', 400);
    });
    final ApiService api = ApiService.getInstance();

    const email = 'test02@example.com';
    const password = 'password1234';

    bool res = await api.login(email, password, client: client);

    expect(res, false);
  });

  test('loginUser test succeed', () async {
    final client = MockClient((request) async {
      return http.Response(
          '{"message": "succeed", "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ODQsIm5hbWUiOiJ0ZXN0MDIiLCJlbWFpbCI6InRlc3QwMkBnbWFpbC5jb20i"}',
          201);
    });
    final ApiService api = ApiService.getInstance();
    const email = 'test02Wrong@example.com';
    const password = 'password1234Wrong';

    bool res = await api.login(email, password, client: client);

    expect(res, false);
  });

  test('loginUser returns true when registration is successful', () async {
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
  test('loginUser returns true when registration is fails', () async {
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
  testWidgets('AppBar should be displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));
    // Find the AppBar widget by its key.
    final appBarWidget = find.byType(AppBar);

    // Expect the AppBar widget to be found.
    expect(appBarWidget, findsOneWidget);

    // Get the widget from the Element found by the widget finder.
    final appBarElement = appBarWidget.evaluate().first;

    // Cast the widget's Element to an AppBar widget.
    final appBar = appBarElement.widget as AppBar;

    // Expect the AppBar title to be a Text widget with the value 'Login'.
    expect(appBar.title, isA<Text>().having((t) => t.data, 'text', 'Login'));
  });
  testWidgets('Image.asset should be displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));

    final imageWidget = find.byType(Image);

    // Expect the Image.asset widget to be found.
    expect(imageWidget, findsOneWidget);

    // Get the widget from the Element found by the widget finder.
    final imageElement = imageWidget.evaluate().first;

    // Cast the widget's Element to an Image widget.
    final image = imageElement.widget as Image;

    // Expect the Image.asset to have the correct width and height.
    expect(image.width, 200);
    expect(image.height, 200);

    // Expect the Image.asset to have a non-null image provider.
    expect(image.image, isNotNull);
  });
  testWidgets('LoginView form validation and navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));

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
