import 'package:flutter/material.dart';

import 'package:diagora/views/home/map/map.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/home/order/order_view.dart';
import 'package:diagora/views/home/calendar/calendar.dart';

import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ApiService _api = ApiService.getInstance();
  dynamic userData;
  String username = '';
  String formattedBegin = '';
  late DateTime today;

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
    username = capitalizeFirstLetter(userData['name']);
    today = DateTime.now();
    DateFormat outputFormat = DateFormat('MM/dd/yyyy');
    formattedBegin = outputFormat.format(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Image.asset(
            'assets/images/diagora.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20), // Add space before the first Text widget
          Text(
            "Hello $username !",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(
              height:
                  10), // Add more space between the second Text widget and buttons
          Text(
            "Today $formattedBegin, you have 0 delivery.",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
              height:
                  20), // Add more space between the second Text widget and buttons
          _buildNavigationButton("Calendar", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CalendarPage()));
          }),
          _buildNavigationButton("Map", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MapPage()));
          }),
          _buildNavigationButton("Orders", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const OrderView()));
          }),
        ],
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
