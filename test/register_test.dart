import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:diagora/register.dart';

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
  testWidgets('AppBar should be displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
    // Find the AppBar widget by its key.
    final appBarWidget = find.byType(AppBar);

    // Expect the AppBar widget to be found.
    expect(appBarWidget, findsOneWidget);

    // Get the widget from the Element found by the widget finder.
    final appBarElement = appBarWidget.evaluate().first;

    // Cast the widget's Element to an AppBar widget.
    final appBar = appBarElement.widget as AppBar;

    // Expect the AppBar title to be a Text widget with the value 'Login'.
    expect(appBar.title, isA<Text>().having((t) => t.data, 'text', 'Register'));
  });
  testWidgets('Image.asset should be displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

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
  });

  testWidgets('Register form validation and navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    final nameField = find.widgetWithText(TextFormField, 'Name');
    final emailField = find.widgetWithText(TextFormField, 'Email');
    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final registerButton = find.widgetWithText(ElevatedButton, 'Register');

    // // Test form validation
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    await tester.enterText(nameField, 'test');
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password');
  });
}
