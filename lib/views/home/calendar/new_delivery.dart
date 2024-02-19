import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/home/calendar/calendar.dart';

class NewDelivery extends StatefulWidget {
  final DateTime pickedDate;
  const NewDelivery({super.key, required this.pickedDate});

  @override
  State<NewDelivery> createState() => _NewDeliveryState();
}

class _NewDeliveryState extends State<NewDelivery> {
  final ApiService _api = ApiService.getInstance();

  final name = TextEditingController();
  final address = TextEditingController();
  late DateTime chosenDate;
  bool isLoading = false;

  @override
  void dispose() {
    name.dispose();
    address.dispose();
    super.dispose();
  }

  void submit() {
    setState(() {
      isLoading = true;
    });
    _api
        .addDelveryAutomatique(name.text, address.text, chosenDate)
        .then((value) {
      setState(() {
        isLoading = false;
      });
      if (value) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CalendarView(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const Offset begin = Offset(-1.0, 0.0);
              const Offset end = Offset(0.0, 0.0);
              var curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    chosenDate = widget.pickedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const CalendarView(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const Offset begin = Offset(-1.0, 0.0);
                  const Offset end = Offset(0.0, 0.0);
                  var curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
              (route) => false,
            );
          },
        ),
        title: const Text('New Delivery'),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        width: 350,
                        child: CupertinoDatePicker(
                          initialDateTime: chosenDate,
                          onDateTimeChanged: (DateTime newdate) {
                            setState(() {
                              chosenDate = newdate;
                            });
                          },
                          use24hFormat: true,
                          maximumDate:
                              DateTime.now().add(const Duration(days: 30)),
                          minimumYear: 2010,
                          maximumYear: 2025,
                          minuteInterval: 1,
                          mode: CupertinoDatePickerMode.dateAndTime,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const CircularProgressIndicator()
              else
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: CupertinoButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (name.text.isEmpty || address.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cannot add delivery'),
                            ),
                          );
                          return;
                        }
                        submit();
                      },
                      child: const Text('Submit')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
