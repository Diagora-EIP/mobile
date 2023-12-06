import 'package:diagora/components/vehicules.dart';
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
  late DateTime todayDate;
  late DateTime todayStart;
  late DateTime todayEnd;

  late Future<int> getNbDeliveryToday;
  late int nbDeliveryToday;

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  void initState() {
    userData = _api.user?.toJson();
    username = capitalizeFirstLetter(userData['name']);

    todayDate = DateTime.now();
    todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day, 1);
    todayEnd = DateTime(todayDate.year, todayDate.month, todayDate.day, 23);

    DateFormat outputFormat = DateFormat('MM/dd/yyyy');
    formattedBegin = outputFormat.format(todayDate);

    super.initState();
  }

  Future<int> fetchNbDeliveryToday() async {
    int nbDeliv = await _api.nbDeliveryToday(todayStart, todayEnd, userData['user_id']);
    if (nbDeliv == -1) {
      nbDeliv = 0;
    }
    return nbDeliv;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder<int>(
        future: fetchNbDeliveryToday(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            int nbDeliveryToday = snapshot.data ?? 0;
            return Column(
              children: [
                Image.asset(
                  'assets/images/diagora.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  "Hello $username !",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Today $formattedBegin, you have $nbDeliveryToday delivery.",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                _buildNavigationButton("Calendar", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CalendarPage()));
                }),
                _buildNavigationButton("Map", () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapPage(userId: userData['user_id'])));
                }),
                _buildNavigationButton("Orders", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderView()));
                }),
                _buildNavigationButton("Vehicules", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehiculesComponent(
                        userId: userData['user_id'],
                        pageTitle: 'Vehicules',
                      ),
                    ),
                  );
                }),
              ],
            );
          }
        },
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
