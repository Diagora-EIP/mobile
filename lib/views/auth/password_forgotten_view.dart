import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/auth/login_view.dart';

class PasswordForgottenView extends StatefulWidget {
  const PasswordForgottenView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PasswordForgottenViewState createState() => _PasswordForgottenViewState();
}

class _PasswordForgottenViewState extends State<PasswordForgottenView> {
  final Logger logger = Logger();

  final _formKey = GlobalKey<FormState>();
  late String _email;

  final ApiService _api = ApiService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password forgotten'),
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
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    bool returnValue = await _api.passwordForgotten(_email);
                    if (returnValue) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckEmail(),
                          ),
                          ((route) => false));
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email not known'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckEmail extends StatefulWidget {
  const CheckEmail({super.key});

  @override
  State<CheckEmail> createState() => _CheckEmailState();
}

class _CheckEmailState extends State<CheckEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check your email'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 70.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'assets/images/diagora.png',
                width: 200,
                height: 200,
              ),
            ),
            const Text(
              'An email has been sent to you.\n\nPlease check your email and follow the instructions.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Padding(padding: EdgeInsets.only(top: 50.0)),
            ElevatedButton(
                onPressed: () => {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      )
                    },
                child: const Text('Back to login',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
