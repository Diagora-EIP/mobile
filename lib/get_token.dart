import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Takes no parameters and returns a String [token].
///
/// No parameters
/// The output value will be the token of the session
/// If (token == null), this function will return null.
Future<String?> getToken() async {
  final Logger logger = Logger();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  if (token == null) {
    logger.e("Error token no here");
    return (null);
  }
  return (token);
}

/// Takes [String] [token] as input and returns nothing.
///
/// The [token] parameter is required and cannot be null.
/// No output
/// No error cases
Future runToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}
