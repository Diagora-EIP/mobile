import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_core/firebase_core.dart';

import './login_test.dart' as login;
import './register_test.dart' as register;

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Configure the default Firebase app
    await Firebase.initializeApp();
  });
  login.main();
  register.main();
}
