import 'package:flutter_test/flutter_test.dart';

import './login_test.dart' as login;
import './register_test.dart' as register;

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  login.main();
  register.main();
}
