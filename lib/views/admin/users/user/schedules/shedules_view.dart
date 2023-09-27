import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:diagora/services/api_service.dart';

import 'dart:math';
import 'dart:convert';

class SchedulesView extends StatefulWidget {
  final int userId;

  const SchedulesView(
    this.userId, {
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  SchedulesViewState createState() => SchedulesViewState();
}

class SchedulesViewState extends State<SchedulesView> {
  final ApiService _api = ApiService.getInstance();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime today = DateTime.now();
  DateTime end = DateTime.now();

  List<dynamic> calendarList = [];
  List<dynamic> scheduleList = [];

  late DateTime todayDate;
  late DateTime todayStart;
  late DateTime todayEnd;

  String todayValueString = "";
  late Future<String> allTodaysValues;

  bool deliveryToday = true;
  int userId = -1;

  final TextEditingController _dateBeginController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();

  @override
  void initState() {
    super.initState();
    todayDate = DateTime.parse(today.toString());
    todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day, 1);
    todayEnd = DateTime(todayDate.year, todayDate.month, todayDate.day, 23);
    userId = widget.userId;
    allTodaysValues = _api.calendarValues(todayStart, todayEnd, userId);
    allTodaysValues.then((value) {
      print(value);
      setState(() {
        todayValueString = value;
        deliveryToday = true;
        scheduleList = json.decode(todayValueString);
        _shipmentOfTheDay(scheduleList);
      });
    }).catchError((error) {
      setState(() {
        deliveryToday = false;
      });
    });
  }

  void _onDaySelected(DateTime day, DateTime focusDay) {
    DateTime todayStart =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 1);
    DateTime todayEnd =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 23);
    Future<String> allTodaysValues =
        _api.calendarValues(todayStart, todayEnd, userId);
    allTodaysValues.then((value) {
      if (mounted) {
        setState(() {
          todayValueString = value;
          deliveryToday = true;
          scheduleList = json.decode(todayValueString);
          _shipmentOfTheDay(scheduleList);
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          deliveryToday = false;
        });
      }
    });
    if (mounted) {
      setState(() {
        today = day;
      });
    }
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

  void openModalSchedule({schedule}) async {
    String action = schedule == null ? 'Add' : 'Edit';
    var scheduleData = {
      "name": schedule == null ? "" : schedule["name"],
      "address": schedule == null ? "" : schedule["address"],
      "begin": schedule == null ? "" : schedule["begin"],
      "end": schedule == null ? "" : schedule["end"],
    };
    if (scheduleData["begin"] == "") {
      _dateBeginController.text = DateFormat('dd/MM/yyyy hh:mm aaa').format(new DateTime.now());
    } else {
      _dateBeginController.text = DateFormat('dd/MM/yyyy hh:mm aaa').format(DateTime.parse(scheduleData["begin"]));
    }
    if (scheduleData["end"] == "") {
      _dateEndController.text = DateFormat('dd/MM/yyyy hh:mm aaa').format(new DateTime.now());
    } else {
      _dateEndController.text = DateFormat('dd/MM/yyyy hh:mm aaa').format(DateTime.parse(scheduleData["end"]));
    }
    if (schedule != null) {
      scheduleData["schedule_id"] = schedule["schedule_id"];
    }
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: scheduleData["name"],
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      onChanged: (value) {
                        scheduleData["name"] = value;
                      },
                    ),
                    TextFormField(
                      initialValue: scheduleData["address"],
                      decoration: const InputDecoration(
                        labelText: 'Address',
                      ),
                      onChanged: (value) {
                        scheduleData["address"] = value;
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateBeginController,
                            onTap: () =>
                                selectDateTime(context, "begin", scheduleData),
                            decoration: const InputDecoration(
                              labelText: "Begin",
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateEndController,
                            onTap: () =>
                                selectDateTime(context, "end", scheduleData),
                            decoration: const InputDecoration(
                              labelText: "End",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Submit btn
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await submitSchedule(scheduleData);
                      Navigator.pop(context);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text(action),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void selectDateTime(BuildContext context, String field,
      Map<String, dynamic> scheduleData) async {
    DateTime begin = scheduleData["begin"] != ""
        ? DateTime.parse(scheduleData["begin"])
        : DateTime.now();
    DateTime end = scheduleData["end"] != ""
        ? DateTime.parse(scheduleData["end"])
        : DateTime.now();
    final DateTime? pickedDate = await DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      currentTime: field == "begin" ? begin : end,
      locale: LocaleType.en,
    );
    if (pickedDate != null) {
      if (field == "begin") {
        if (mounted) {
          setState(() {
            scheduleData["begin"] = pickedDate.toString();
            _dateBeginController.text =
                DateFormat('dd/MM/yyyy hh:mm aaa').format(pickedDate);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            scheduleData["end"] = pickedDate.toString();
            _dateEndController.text =
                DateFormat('dd/MM/yyyy hh:mm aaa').format(pickedDate);
          });
        }
      }
    }
  }

  Future<void> submitSchedule(Map<String, dynamic> scheduleData) async {
    bool returned = false;
    if (scheduleData["schedule_id"] == null) {
      returned = await _api.addUserSchedule(userId, scheduleData);
    } else {
      // returned = await _api.editUserSchedule(userId, scheduleData);
    }
    if (!returned) {
      throw Exception('Error while adding schedule');
    }
    setState(() {
      today = DateTime.now();
      _onDaySelected(today, today);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        // On right, add a + button to add a new schedule
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => openModalSchedule(),
          ),
        ],
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
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              "On ${DateFormat('EEEE, MMM d, yyyy').format(today)}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => {
              setState(() {
                today = DateTime.now();
                _onDaySelected(today, today);
              })
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                "Back to Today",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: deliveryToday
                ? MyListWidget(items: calendarList, today: today)
                : const Text("No delivery for today"),
          )
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
  final List<dynamic> item;
  DateTime today;

  ItemDetailsPage({Key? key, required this.item, required this.today})
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
          "On ${DateFormat('EEEE, MMM d, yyyy').format(widget.today)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<LatLng>(
        future: fetchCoordinates(widget.item[1]),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.item[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item[1],
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.item[2],
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
                          widget.item[3],
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
            );
          }
        },
      ),
    );
  }
}
