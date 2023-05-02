import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Future runToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}
