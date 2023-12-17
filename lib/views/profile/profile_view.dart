import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/profile/change_password.dart';

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

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

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
    permissions = permissionsData['permissions'] ?? 'user';
  }

  void _showImageSourcePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageSourcePicker(
          onImageSourceSelected: (source) {
            _pickImage(source);
          },
        );
      },
    );
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
            GestureDetector(
              onTap: _showImageSourcePicker,
              child: CircleAvatar(
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
            ),
            const SizedBox(height: 24),
            ProfileInfos(itemName: "Username", itemValue: username),
            ProfileInfos(itemName: "Email", itemValue: email),
            ProfileInfos(itemName: "Permissions", itemValue: permissions),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePassword()));
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfos extends StatefulWidget {
  final String itemName;
  final String itemValue;

  const ProfileInfos({super.key, required this.itemName, required this.itemValue});

  @override
  State<ProfileInfos> createState() => _ProfileInfosState();
}

class _ProfileInfosState extends State<ProfileInfos> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        FractionallySizedBox(
          widthFactor: 2 / 3,
          child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(widget.itemName, style: const TextStyle(fontSize: 16, color: Colors.white))),
        ),
        const SizedBox(height: 8),
        Text(
          widget.itemValue,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ImageSourcePicker extends StatelessWidget {
  final Function(ImageSource) onImageSourceSelected;

  const ImageSourcePicker({super.key, required this.onImageSourceSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Select Image Source',
        textAlign: TextAlign.center,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              onImageSourceSelected(ImageSource.gallery);
              Navigator.of(context).pop();
            },
            child: const Text('Gallery'),
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: () {
              onImageSourceSelected(ImageSource.camera);
              Navigator.of(context).pop();
            },
            child: const Text('Camera'),
          ),
        ],
      ),
    );
  }
}
