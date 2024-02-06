import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/home/calendar/new_delivery.dart';

import 'dart:math';
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final ApiService _api = ApiService.getInstance();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime today = DateTime.now();
  List<dynamic> scheduleList = [];
  bool deliveryToday = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _onDaySelected(today, today);
  }

  // Needs to have the same parameters as the function onDaySelected [DateTime day, DateTime focusDay]
  void _onDaySelected(DateTime day, DateTime focusDay) {
    setState(() {
      isLoading = true;
    });

    DateTime chosenStart =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 1);
    DateTime chosenEnd =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 23);
    Future<String> allTodaysValues = _api.getSchedule(chosenStart, chosenEnd);

    allTodaysValues.then((value) {
      setState(() {
        isLoading = false;
      });
      // No delivery for today
      if (value == "[]") {
        setState(() {
          deliveryToday = false;
        });
      } else {
        setState(() {
          scheduleList = json.decode(value);
          deliveryToday = true;
        });
      }
    }).catchError((error) {
      setState(() {
        deliveryToday = false;
      });
    });
    // Change the variable today to the day selected
    setState(() {
      today = focusDay;
    });
  }

  // void _shipmentOfTheDay(List<dynamic> scheduleListVal) {
  //   List<dynamic> newCalendarList = [];

  //   for (var schedule in scheduleListVal) {
  //     DateTime dateTimeBegin = DateTime.parse(schedule["order_date"]);
  //     DateTime dateTimeEnd = DateTime.parse(schedule["order_date"]);
  //     newCalendarList.add([
  //       schedule["description"],
  //       schedule["delivery_address"],
  //       DateFormat('hh:mm aaa').format(DateTime.parse(schedule["order_date"])),
  //       DateFormat('hh:mm aaa').format(schedule["order_date"])
  //     ]);
  //   }
  //   setState(() {
  //     calendarList = newCalendarList;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewDelivery(pickedDate: today),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: "en_US",
            headerStyle: const HeaderStyle(
              titleCentered: true,
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            startingDayOfWeek: StartingDayOfWeek.monday,
            focusedDay: today,
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 15),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onDaySelected: _onDaySelected,
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              "On ${DateFormat('EEEE, MMM d, yyyy').format(today)}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          CupertinoButton(
            color: Theme.of(context).primaryColor,
            onPressed: () => {
              setState(() {
                today = DateTime.now();
                _onDaySelected(today, today);
              })
            },
            child: const Text(
              "Back to Today",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : deliveryToday
                      ? MyListWidget(scheduleList: scheduleList, chosen: today)
                      : const Center(
                          child: Text(
                            "No delivery for today",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ignore: must_be_immutable
class MyListWidget extends StatelessWidget {
  final List<dynamic> scheduleList;
  DateTime chosen;

  MyListWidget({super.key, required this.scheduleList, required this.chosen});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: scheduleList.length,
      itemBuilder: (BuildContext context, int index) {
        final color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
            .withOpacity(1.0);

        return Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailsPage(
                        scheduleList: scheduleList[index], chosen: chosen),
                  ),
                );
              },
              child: ListTile(
                title: Text(scheduleList[index]["order"]["description"],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    Text(scheduleList[index]["order"]["delivery_address"]),
                leading: Container(
                  width: 5.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                trailing: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(DateFormat('hh:mm aaa').format(DateTime.parse(
                          scheduleList[index]["order"]["order_date"]))),
                    ),
                    Text(DateFormat('hh:mm aaa').format(DateTime.parse(
                        scheduleList[index]["order"]["order_date"]))),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          ],
        );
      },
    );
  }
}

Future<Map<String, double>> getCoordinates(String address) async {
  Map<String, double> locationMap = {'lat': 0.0, 'long': 0.0};
  try {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        double latitude = double.tryParse(data[0]['lat'] ?? '') ?? 0.0;
        double longitude = double.tryParse(data[0]['lon'] ?? '') ?? 0.0;

        locationMap['lat'] = latitude;
        locationMap['long'] = longitude;
        return locationMap;
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error getting coordinates: $e');
  }
  return locationMap;
}

// ignore: must_be_immutable
class ItemDetailsPage extends StatefulWidget {
  final dynamic scheduleList;
  DateTime chosen;

  ItemDetailsPage({Key? key, required this.scheduleList, required this.chosen})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  LatLng coord = LatLng(0, 0);

  Future<LatLng> fetchCoordinates(String givenAddress) async {
    final address = givenAddress;
    try {
      final coordinates = await getCoordinates(address);

      final latitude = coordinates['lat'];
      final longitude = coordinates['long'];
      return LatLng(latitude!, longitude!);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching coordinates: $e');
    }
    return LatLng(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "On ${DateFormat('EEEE, MMM d, yyyy').format(widget.chosen)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<LatLng>(
        future:
            fetchCoordinates(widget.scheduleList["order"]["delivery_address"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error fetching location',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            coord = snapshot.data!;
            const zoomLevel = 10.0; // Adjust the zoom level as desired

            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.scheduleList["order"]["description"]
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.scheduleList["order"]["delivery_address"],
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('hh:mm aaa').format(DateTime.parse(
                                widget.scheduleList["order"]["order_date"])),
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('hh:mm aaa').format(DateTime.parse(
                                widget.scheduleList["order"]["order_date"])),
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 400,
                        child: FlutterMap(
                          options: MapOptions(
                            center: coord,
                            zoom: zoomLevel,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: coord,
                                  builder: (ctx) => const Icon(
                                    Icons.place,
                                    color: Colors.black,
                                    size: 48,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
