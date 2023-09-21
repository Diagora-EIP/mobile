import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/home/profile/change_password.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ApiService _api = ApiService.getInstance();

  final String profilePictureUrl1 = 'assets/images/PdP.jpeg';
  int userId = -1;
  String username = '';
  String email = '';
  String permissions = '';
  dynamic permissionsData;
  dynamic userData;
  File? _image;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  void initState() {
    super.initState();
    userData = _api.user?.toJson();
    userId = userData['user_id'];
    username = capitalizeFirstLetter(userData['name']);
    email = userData['email'];

    permissionsData = _api.permissions?.toJson();
    permissions = permissionsData['permissions'] ?? 'null';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null
                  ? const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Change Profile Picture'),
            ),
            const SizedBox(height: 16),
            Text(
              'Username: $username',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Permissions: $permissions',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePassword()));
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
