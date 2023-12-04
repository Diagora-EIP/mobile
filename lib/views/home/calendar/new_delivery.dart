import 'package:flutter/material.dart';

import 'package:diagora/services/api_service.dart';


class NewDelivery extends StatefulWidget {
  const NewDelivery({super.key});

  @override
  State<NewDelivery> createState() => _NewDeliveryState();
}

class _NewDeliveryState extends State<NewDelivery> {
  // final ApiService _api = ApiService.getInstance();

  final name = TextEditingController();
  final address = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    name.dispose();
    address.dispose();
    super.dispose();
  }

  void submit() {
    // _api.addDelveryAutomatique(31, name.text, address.text).then((value) {
    //   if (value) {
    //     Navigator.pop(context);
    //   }
    // });
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
              padding: const EdgeInsets.all(50.0),
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
            // submit button
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: ElevatedButton(
                onPressed: () {
                  submit();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Submit')
              ),
            ),
          ],
        ),
      ),
    );
  }
}
