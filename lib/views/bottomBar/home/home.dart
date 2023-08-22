import 'package:flutter/material.dart';
import 'package:diagora/views/bottomBar/map/map.dart';
import 'package:diagora/views/bottomBar/profile/profile.dart';
import 'package:diagora/views/bottomBar/order/order_view.dart';
import 'package:diagora/views/bottomBar/calendar/calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
