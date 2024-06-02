import 'package:flutter/material.dart';

import 'package:diagora/views/home/map/map.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/home/calendar/calendar.dart';

import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final ApiService _api = ApiService.getInstance();
  dynamic userData;
  String username = '';
  String formattedBegin = '';
  late DateTime todayDate;
  late DateTime todayStart;
  late DateTime todayEnd;

  late Future<int> getNbDeliveryToday;
  int nbDeliveryToday = 0;

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

    todayDate = DateTime.now();
    todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day, 1);
    todayEnd = DateTime(todayDate.year, todayDate.month, todayDate.day, 23);

    DateFormat outputFormat = DateFormat('dd.MM.yyyy');
    formattedBegin = outputFormat.format(todayDate);

    fetchNbDeliveryToday();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) fetchNbDeliveryToday();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchNbDeliveryToday();
  }

  void fetchNbDeliveryToday() async {
    int nbDeliv = await _api.nbDeliveryToday(todayStart, todayEnd);

    if (nbDeliv == -1) {
      nbDeliv = 0;
    }
    if (mounted) {
      setState(() {
        nbDeliveryToday = nbDeliv;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/diagora.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 10),
            Text(
              "Hello $username !",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarView(),
                ),
                (route) => false,
              );
            }),
            _buildNavigationButton("Map", () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MapPage(userId: userData['user_id'])));
            }),
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
