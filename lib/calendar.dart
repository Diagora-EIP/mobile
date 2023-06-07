import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:table_calendar/table_calendar.dart';

import 'dart:convert';
import 'dart:math';

/// Takes [DateTime] [begin], [end] as input and returns an output string if the api call succeed.
///
/// The[begin], [end] parameter are required and cannot be null.
/// The output value will be the shipment date if the call succeed.
/// If [response.statusCode] is not 200 or 202, this function will return "false".
Future<String> calendarValues(DateTime begin, DateTime end) async {
  final Logger logger = Logger();

  String beginTimeStamp =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(begin.toUtc());
  String endTimeStamp =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(end.toUtc());

  const id = "31";
  final link =
      "http://localhost:3000/user/$id/schedule?begin=$beginTimeStamp&end=$endTimeStamp";
  final url = Uri.parse(link);

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer Valorant-35"
      },
    );
    if (response.statusCode == 200 || response.statusCode == 202) {
      logger.i(response.body);
      return (response.body);
    } else {
      logger.e('Login failed with status code ${response.statusCode}');
      return "false";
    }
  } catch (e) {
    logger.e('${e.toString()}  : Serveur unreachable');
    return "false";
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final noShipment = "No shipment set up";
  var shipment = true;

  DateTime today = DateTime.now();
  DateTime end = DateTime.now();
  String calValue = "";
  List<dynamic> calendarList = [];
  List<dynamic> scheduleList = [];

  @override
  void initState() {
    final todayValues = DateTime.parse(today.toString());
    DateTime todayStart =
        DateTime(todayValues.year, todayValues.month, todayValues.day, 1);
    DateTime todayEnd =
        DateTime(todayValues.year, todayValues.month, todayValues.day, 23);
    Future<String> calValues = calendarValues(todayStart, todayEnd);
    calValues.then((value) {
      setState(() {
        calValue = value;
        scheduleList = json.decode(calValue);
        _shipmentOfTheDay(scheduleList);
      });
    });
    super.initState();
  }

  void _onDaySelected(DateTime day, DateTime focusDay) {
    DateTime todayStart =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 1);
    DateTime todayEnd =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 23);
    Future<String> calValues = calendarValues(todayStart, todayEnd);
    calValues.then((value) {
      setState(() {
        calValue = value;
        scheduleList = json.decode(calValue);
        _shipmentOfTheDay(scheduleList);
      });
    });
    setState(() {
      today = day;
    });
  }

  void _shipmentOfTheDay(List<dynamic> scheduleListVal) {
    List<dynamic> newCalendarList = [];

    for (var schedule in scheduleListVal) {
      DateTime dateTimeBegin = DateTime.parse(schedule["begin"]);
      DateTime dateTimeEnd = DateTime.parse(schedule["end"]);
      newCalendarList.add([
        schedule["name"],
        schedule["address"],
        DateFormat('hh:mm aaa').format(dateTimeBegin),
        DateFormat('hh:mm aaa').format(dateTimeEnd)
      ]);
    }
    setState(() {
      calendarList = newCalendarList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: "en_US",
            // locale: fr_FR',
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
          Text("On ${DateFormat('EEEE, MMM d, yyyy').format(today)}"),
          TextButton(
              onPressed: () => {
                    setState(() {
                      today = DateTime.now();
                      _onDaySelected(today, today);
                    })
                  },
              child: const Text("Back to Today")),
          Expanded(child: MyListWidget(items: calendarList, today: today)),
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
  final List<dynamic> items;
  DateTime today;

  MyListWidget({super.key, required this.items, required this.today});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
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
                    builder: (context) =>
                        ItemDetailsPage(item: items[index], today: today),
                  ),
                );
              },
              child: ListTile(
                title: Text(items[index][0],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(items[index][1]),
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
                      child: Text(items[index][2]),
                    ),
                    Text(items[index][3]),
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

// ignore: must_be_immutable
class ItemDetailsPage extends StatelessWidget {
  final Logger logger = Logger();
  final List<dynamic> item;
  DateTime today;
  LatLng coord = LatLng(0, 0);

  ItemDetailsPage({super.key, required this.item, required this.today});

  Future<LatLng> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;
        return LatLng(latitude, longitude);
      }
    } catch (e) {
      logger.e('Error getting location from address: $e');
    }
    return LatLng(0, 0); // Default location if address lookup fails
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("On ${DateFormat('EEEE, MMM d, yyyy').format(today)}"),
      ),
      body: Center(
        child: Column(children: [
          Text(item[0], style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(item[1]),
          Text(item[2]),
          Text(item[3]),
          SizedBox(
            height: 600,
            width: 400,
            child: FlutterMap(
              options: MapOptions(
                center: coord,
                zoom: 3.2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
