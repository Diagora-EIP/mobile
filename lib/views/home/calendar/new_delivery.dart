import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:diagora/services/api_service.dart';

class NewDelivery extends StatefulWidget {
  const NewDelivery({super.key});

  @override
  State<NewDelivery> createState() => _NewDeliveryState();
}

class _NewDeliveryState extends State<NewDelivery> {
  final ApiService _api = ApiService.getInstance();

  final name = TextEditingController();
  final address = TextEditingController();
  late DateTime chosenDate;
  DateTime today = DateTime.now();

  @override
  void dispose() {
    name.dispose();
    address.dispose();
    super.dispose();
  }

  void submit() {
    _api.addDelveryAutomatique(name.text, address.text, chosenDate, today).then((value) {
      if (value) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Delivery'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/images/diagora.png',
                width: 200,
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: name,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: address,
                decoration: const InputDecoration(
                  icon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("When do you want to be delivered ?"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.calendar_today,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 350,
                    child: CupertinoDatePicker(
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (DateTime newdate) {
                        setState(() {
                          chosenDate = newdate;
                        });
                      },
                      use24hFormat: true,
                      maximumDate: DateTime.now().add(const Duration(days: 30)),
                      minimumYear: 2010,
                      maximumYear: 2025,
                      minuteInterval: 1,
                      mode: CupertinoDatePickerMode.dateAndTime,
                    ),
                  ),
                ],
              ),
            ),
            // submit button
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: ElevatedButton(
                  onPressed: () {
                    if (name.text.isEmpty || address.text.isEmpty) {
                      // show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cannot add delivery'),
                        ),
                      );
                      return;
                    }
                    submit();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Submit')),
            ),
          ],
        ),
      ),
    );
  }
}
