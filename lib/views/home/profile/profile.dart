import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/home/profile/change_password.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _api = ApiService.getInstance();

  final String profilePictureUrl1 = 'assets/images/PdP.jpeg';
  int userId = -1;
  String username = '';
  String email = '';
  String permissions = '';
  dynamic permissionsData;
  dynamic userData;

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
              radius: 50,
              // backgroundImage: CachedNetworkImageProvider(profilePictureUrl),
              backgroundImage: AssetImage(profilePictureUrl1),
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
