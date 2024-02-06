import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/auth/register_view.dart';
import 'package:diagora/views/loading/loading_view.dart';
import 'package:diagora/views/auth/password_forgotten_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final Logger logger = Logger();

  final _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool isLoading = false;

  final ApiService _api = ApiService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                  const Padding(padding: EdgeInsets.only(top: 25.0)),
                  CupertinoButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        setState(() {
                          isLoading = true;
                        });

                        bool returnValue = await _api.login(_email, _password);
                        if (returnValue) {
                          await _api.fetchRoles();
                          // ignore: use_build_context_synchronously
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoadingView(),
                            ),
                            (route) => false,
                          );
                        } else {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login failed'),
                            ),
                          );
                        }
                      }
                    },
                    color: Theme.of(context).primaryColor,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            color: Colors.transparent,
                          )
                        : const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordForgottenView(),
                        ),
                      );
                    },
                    child: const Text('Forgot your password?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterView(),
                        ),
                      );
                    },
                    child: const Text('Don\'t have an account yet? Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
