import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

    permissionsData = _api.role?.toJson();
    permissions = permissionsData['name'] ?? 'user';
  }

  void _showImageSourcePicker() {
    showCupertinoModalPopup(
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

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 45, left: 14),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _showImageSourcePicker,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .primaryColor, // Set the border color to blue
                          width: 2.0, // Set the border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(_capitalizeFirstLetter(permissions),
                          style: const TextStyle(
                              color: Color.fromARGB(255, 76, 76, 76))),
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 14, bottom: 14)),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue, // Set the border color to blue
                        width: 2.0, // Set the border width
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text("Account Information",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(
                height: 20,
                color: Color.fromARGB(255, 76, 76, 76),
              ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.person),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 10,
                    title: Row(
                      children: [
                        const Text('Name ',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(username,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 10,
                    title: Row(
                      children: [
                        const Text('Email ',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(email,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 10,
                    title: Row(
                      children: [
                        const Text('Permissions ',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(_capitalizeFirstLetter(permissions),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.work),
                    minLeadingWidth: 0,
                    horizontalTitleGap: 10,
                    title: Row(
                      children: [
                        const Text('Company ',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(_capitalizeFirstLetter("company"),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                color: Theme.of(context).primaryColor,
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
      ),
    );
  }
}

class ImageSourcePicker extends StatelessWidget {
  final Function(ImageSource) onImageSourceSelected;

  const ImageSourcePicker({Key? key, required this.onImageSourceSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text(
        'Select Image Source',
        textAlign: TextAlign.center,
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            onImageSourceSelected(ImageSource.gallery);
            Navigator.of(context).pop();
          },
          child: const Text('Gallery'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            onImageSourceSelected(ImageSource.camera);
            Navigator.of(context).pop();
          },
          child: const Text('Camera'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'),
      ),
    );
  }
}
