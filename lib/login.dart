import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

/// Takes [String] [email], [String] [password] as input and returns an output value if the login is true or fasle.
///
/// The [email], [password] parameter are required and cannot be null.
/// The output value will be true if the login works.
/// If [response.statusCode] is not 200 or 201, this function will return false.
Future<bool> loginUser(String email, String password) async {
  final Logger logger = Logger();

  final url = Uri.parse('http://localhost:3000/user/login');
  try {
    final response = await http.post(
      url,
      body: json
          .encode({'email': email, 'password': password, 'remember': false}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      logger.i(responseData);
      return true;
    } else {
      logger.e('Login failed with status code ${response.statusCode}');
      return false;
    }
  } catch (e) {
    logger.e('${e.toString()}  : Serveur unreachable');
    return false;
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Logger logger = Logger();

  final _formKey = GlobalKey<FormState>();
  late String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  '../assets/images/diagora.png',
                  width: 200,
                  height: 200,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    bool returnValue = await loginUser(_email, _password);
                    if (returnValue) {
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
