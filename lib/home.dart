import 'package:flutter/material.dart';
import 'package:diagora/views/home/order/order_view.dart';

import 'package:diagora/map.dart';
import 'package:diagora/profile.dart';
import 'package:diagora/calendar.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/auth/register_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Home'), automaticallyImplyLeading: false),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 30),
            ),
            child: const Text('Calendar'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 30),
            ),
            child: const Text('Map'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 30),
            ),
            child: const Text('Profile'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 30),
            ),
            child: const Text('Commandes'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _api.logout();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterView()),
                  (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.all(20),
              textStyle: const TextStyle(fontSize: 30),
            ),
            child: const Text('logout'),
          ),
        ],
      ),
    );
  }
}
