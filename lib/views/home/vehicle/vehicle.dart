import 'package:diagora/views/settings/others/choose_vehicle.dart';
import 'package:diagora/views/settings/others/new_document.dart';
import 'package:diagora/views/settings/others/view_documents.dart';
import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';
import 'package:intl/intl.dart';

class VehicleView extends StatefulWidget {
  const VehicleView({Key? key}) : super(key: key);

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> with WidgetsBindingObserver {
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
        title: const Text('Page Véhicule'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildNavigationButton("Choisir un vehicule", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChooseVehicleView(),
                ),
              );
            }),
            _buildNavigationButton("Enregistrer un Documents", () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const NewDocument()));
            }),
            _buildNavigationButton("Voir mes Documents", () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewDocuments()));
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
