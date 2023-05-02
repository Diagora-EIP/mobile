import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:diagora/login.dart';

void main() {
  group('loginUser', () {
    test('returns true for successful login', () async {
      final client = MockClient((request) async {
        return http.Response('{"token": "some_token"}', 200);
      });

      final bool result = await loginUser('test@example.com', 'password');

      expect(result, isTrue);
    });

    test('returns false for failed login', () async {
      final client = MockClient((request) async {
        return http.Response('{"message": "Invalid credentials"}', 401);
      });

      final bool result = await loginUser('test@example.com', 'password');

      expect(result, isFalse);
    });
  });
}
