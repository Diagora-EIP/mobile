import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/profile/profile_view.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  late String _newPassword = "";
  late String _newPasswordConfirm = "";
  dynamic userData;

  final ApiService _api = ApiService.getInstance();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Your Password"),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Enter Your New Password"),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) => _newPassword = value!,
              ),
              const SizedBox(height: 20),
              const Text("Confirm Your New Password"),
              TextFormField(
                decoration:
                    const InputDecoration(
                  labelText: 'Confirm New Password',
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your new password';
                  }
                  return null;
                },
                onSaved: (value) => _newPasswordConfirm = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _newPassword == _newPasswordConfirm) {
                    _formKey.currentState!.save();
                    bool returnValue = await _api.resetPasswordWithToken(_newPasswordConfirm);
                    if (returnValue) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileView(),
                        ),
                        (route) => false,
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot change the password'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
