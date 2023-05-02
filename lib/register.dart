import 'package:flutter/material.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'package:logger/logger.dart';
import 'get_token.dart';

/// Takes [String] [name], [String] [email], [String] [password] as input and returns an output value if the register is true or false.
///
/// The [name], [email], [password] parameter are required and cannot be null.
/// The output value will be true if the register works.
/// If [response.statusCode] is not 200 or 201, this function will return false.
Future<bool> registerUser(String name, String email, String password) async {
  final Logger logger = Logger();

  final url = Uri.parse('http://localhost:3000/user/register');
  try {
    final response = await http.post(
      url,
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
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      logger.i(responseData);
      await runToken(responseData["token"]);
      return true;
    } else {
      logger.e('Register failed with status code ${response.statusCode}');
      return false;
    }
  } catch (e) {
    logger.e('${e.toString()}  : Serveur unreachable');
    return false;
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _email, _password;

  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                  'assets/images/diagora.png',
                  width: 200,
                  height: 200,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
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
                    bool returnValue =
                        await registerUser(_name, _email, _password);
                    if (returnValue) {
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Register failed'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
