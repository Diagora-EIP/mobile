import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
  bool isLoading = false;
  dynamic userData;

  final ApiService _api = ApiService.getInstance();

  @override
  initState() {
    super.initState();
  }

  bool _hasANumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
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
              const Text("Enter your new password"),
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
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  if (_hasANumber(_newPassword) == false) {
                    return 'Password must contain at least one number';
                  }
                  return null;
                },
                onSaved: (value) => _newPassword = value!,
                onChanged: (value) {
                  setState(() {
                    _newPassword = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text("Confirm your new password"),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your new password';
                  }
                  if (value != _newPassword) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onSaved: (value) => _newPasswordConfirm = value!,
                onChanged: (value) {
                  setState(() {
                    _newPasswordConfirm = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                  } else {
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  bool returnValue =
                      await _api.resetPasswordWithToken(_newPasswordConfirm);

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
                },
                color: Theme.of(context).primaryColor,
                child: isLoading
                    ? const CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        color: Colors.transparent,
                      )
                    : const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
