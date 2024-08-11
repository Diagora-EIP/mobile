import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:diagora/views/home/home.dart';
import 'package:diagora/models/role_model.dart';
import 'package:diagora/services/api_service.dart';
import 'package:diagora/views/home/calendar/new_delivery.dart';
import 'package:diagora/views/home/map/map.dart';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:permission_handler/permission_handler.dart';

import 'dart:math';
import 'dart:convert';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final ApiService _api = ApiService.getInstance();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime today = DateTime.now();
  List<dynamic> scheduleList = [];
  bool deliveryToday = true;
  bool isLoading = false;
  late DateTime focusDay = today;

  @override
  void initState() {
    super.initState();
    _onDaySelected(today, today);
  }

  // Needs to have the same parameters as the function onDaySelected [DateTime day, DateTime focusDay]
  void _onDaySelected(DateTime day, DateTime focusDay) {
    print('Selected day: $day');
    print('Focus day: $focusDay');
    if (mounted) {
      setState(() {
        this.focusDay = focusDay;
        isLoading = true;
      });
    }

    DateTime chosenStart =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 1);
    DateTime chosenEnd =
        DateTime(focusDay.year, focusDay.month, focusDay.day, 23);
    Future<String> allTodaysValues = _api.getSchedule(chosenStart, chosenEnd);

    allTodaysValues.then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // No delivery for today
      if (value == "[]") {
        if (mounted) {
          setState(() {
            deliveryToday = false;
          });
        }
      } else {
        // There is delivery for today
        if (mounted) {
          setState(() {
            scheduleList = json.decode(value);
            scheduleList.sort((a, b) {
              return a["order"]["order_date"]
                  .compareTo(b["order"]["order_date"]);
            });
            deliveryToday = true;
          });
        }
      }
    }).catchError((error) {
      setState(() {
        deliveryToday = false;
      });
    });
    // Change the variable today to the day selected
    if (mounted) {
      setState(() {
        today = focusDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          _api.role?.role == Roles.manager || _api.role?.role == Roles.admin
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewDelivery(pickedDate: today),
                      ),
                      (route) => false,
                    );
                  },
                )
              : const SizedBox(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const HomeView(),
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
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                today = DateTime.now();
                _onDaySelected(today, today);
              });
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
          //button to see the map with delivery map
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(
                    userId: _api.user!.id,
                    date: today,
                  ),
                ),
              );
            },
            child: const Text('Voir la carte des livraisons'),
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
  Map<dynamic, double> coord = {};
  mapbox.MapboxMap? mapboxMap;
  mapbox.PointAnnotationManager? pointAnnotationManager;

  String publicToken = const String.fromEnvironment("MAPBOX_PUBLIC_TOKEN");

  Future<Map<dynamic, double>> fetchCoordinates(String givenAddress) async {
    final address = givenAddress;
    try {
      final coordinates = await getCoordinates(address);
      _addMarkers(coordinates);
      Future.delayed(const Duration(milliseconds: 1000), () async {});
      return coordinates;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching coordinates: $e');
    }
    return {};
  }

  @override
  void initState() {
    super.initState();

    if (publicToken.isEmpty) {
      throw Exception(
          'Mapbox public token is required to use Mapbox maps. Please add it to your environment variables.');
    }
    fetchCoordinates(widget.scheduleList["order"]["delivery_address"]);
  }

  void _addMarkers(dynamic coordinates) async {
    if (mapboxMap != null) {
      pointAnnotationManager =
          await mapboxMap!.annotations.createPointAnnotationManager();

      final ByteData bytes =
          await rootBundle.load('assets/images/marker-icon.png');
      final Uint8List list = bytes.buffer.asUint8List();

      var option = mapbox.PointAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            coordinates['long'],
            coordinates['lat'],
          ),
        ).toJson(),
        image: list,
        iconSize: 0.10,
      );

      pointAnnotationManager?.create(option);
    }
  }

  void _onMapCreated(mapbox.MapboxMap controller) async {
    mapboxMap = controller;

    // Add markers once map is ready
    _addMarkers(coord);

    // Show user location
    mapboxMap?.location.updateSettings(mapbox.LocationComponentSettings(
      enabled: true,
      showAccuracyRing: true,
      pulsingEnabled: true,
      puckBearingEnabled: true,
    ));

    // Fly to the position
    _flyToPosition(position: mapbox.Position(coord['long']!, coord['lat']!));
  }

  void _flyToPosition({required mapbox.Position position}) async {
    mapboxMap?.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: position,
          ).toJson(),
          zoom: 10,
          bearing: 0,
          pitch: 3,
        ),
        mapbox.MapAnimationOptions(duration: 2000, startDelay: 0));
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
      body: FutureBuilder<Map<dynamic, double>>(
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
            coord = snapshot.data!; // Adjust the zoom level as desired
            return mapbox.MapWidget(
              resourceOptions: mapbox.ResourceOptions(
                accessToken: publicToken,
              ),
              onMapCreated: _onMapCreated,
            );
          }
        },
      ),
    );
  }
}
