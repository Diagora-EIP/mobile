import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';

class ChooseVehicleView extends StatefulWidget {
  const ChooseVehicleView({super.key});

  @override
  State<ChooseVehicleView> createState() => _ChooseVehicleViewState();
}

class _ChooseVehicleViewState extends State<ChooseVehicleView> {
  final ApiService _api = ApiService.getInstance();
  dynamic userId;
  dynamic myVehicleData;
  dynamic allVehicles;
  bool isChecked = false;
  late List<bool> checkedStates;
  bool loading = true;
  final List<String> _vehicles = [];

  @override
  initState() {
    super.initState();

    userId = _api.user?.toJson()['user_id'];

    _api.getUserVehicle(userId).then((value) {
      myVehicleData = value;

      _api.getAllUserVehicles().then((value) {
        allVehicles = value;
        for (var vehicle in value) {
          _vehicles.add(vehicle['name']);
        }
        checkedStates = List.filled(_vehicles.length, false);
        checkVehicle();
        setState(() {
          loading = false;
        });
      });
    });
  }

  void checkVehicle() {
    for (var vehicle in myVehicleData) {
      for (var i = 0; i < _vehicles.length; i++) {
        if (_vehicles[i] == vehicle['name']) {
          checkedStates[i] = true;
        } else {
          checkedStates[i] = false;
        }
      }
    }
  }

  int getChoosenVehicleIndex(String choosenVehicle) {
    for (var vehicle in allVehicles) {
      if (vehicle['name'] == choosenVehicle) {
        return vehicle['vehicle_id'];
      }
    }
    return -1;
  }

  void connectVehicleToUser(int choosenVehicle) async {
    if (myVehicleData.length > 0 &&
        choosenVehicle != myVehicleData[0]['vehicle_id']) {
      await _api.connectVehicleToUser(userId, myVehicleData[0]['vehicle_id']);
    }

    await _api.connectVehicleToUser(userId, choosenVehicle);

    _api.getUserVehicle(userId).then((value) {
      myVehicleData = value;
      checkVehicle();
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Choose vehicle'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0, right: 8.0, left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              title: Text(_vehicles[index]),
                              value: checkedStates[index],
                              onChanged: (bool? newValue) {
                                setState(() {
                                  loading = true;
                                });
                                connectVehicleToUser(
                                    getChoosenVehicleIndex(_vehicles[index]));
                                setState(() {
                                  checkedStates[index] = newValue!;
                                });
                              },
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
