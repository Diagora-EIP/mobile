import 'package:flutter/material.dart';

import 'package:diagora/views/home/map/map.dart';
import 'package:diagora/views/home/profile/profile.dart';
import 'package:diagora/views/home/order/order_view.dart';
import 'package:diagora/views/home/calendar/calendar.dart';

import 'package:diagora/views/auth/register_view.dart';

import 'package:diagora/services/api_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ApiService _api = ApiService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavigationButton("Calendar", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage()));
            }),
            _buildNavigationButton("Map", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MapPage()));
            }),
            _buildNavigationButton("Profile", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            }),
            _buildNavigationButton("Orders", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderView()));
            }),
            _buildNavigationButton("Logout", () {
              _api.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterView()));
            }),
            // _buildNavigationButton("Parameters", () {
            //   Navigator.push(context, MaterialPageRoute(builder: (context) => const ParametersPage()));
            // }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward),
                const SizedBox(width: 16),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
