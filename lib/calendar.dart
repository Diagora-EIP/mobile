import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'get_token.dart';

Future<String> calendarValues(DateTime begin, DateTime end) async {
  final Logger logger = Logger();

  String beginTimeStamp =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(begin.toUtc());
  String endTimeStamp =
      DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(end.toUtc());

  const id = "31";
  final link =
      "http://localhost:3000/schedule/$id?begin=$beginTimeStamp&end=$endTimeStamp";
  final url = Uri.parse(link);

  String? token = await getToken();

  logger.i(token);

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
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
  late CalendarController _calendarController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final noShipment = "No shipment set up";
  var shipment = true;

  DateTime today = DateTime.now();
  DateTime end = DateTime.now();
  String text = "";
  String calValue = "";
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
    String newText = "";

    for (var schedule in scheduleListVal) {
      newText += schedule["name"] + "\n";
      DateTime dateTimeBegin = DateTime.parse(schedule["begin"]);
      DateTime dateTimeEnd = DateTime.parse(schedule["end"]);
      newText +=
          "Begin: ${DateFormat('EEEE, MMM d, yyyy, hh:mm aaa').format(dateTimeBegin)}\n";
      newText +=
          "End:  ${DateFormat('EEEE, MMM d, yyyy hh:mm aaa').format(dateTimeEnd)}\n";
      newText += "Address: ${schedule["address"]}}\n\n";
    }
    setState(() {
      text = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Calendar'),
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
          Text(text)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}
