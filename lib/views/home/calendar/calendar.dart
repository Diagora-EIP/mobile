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
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final ApiService _api = ApiService.getInstance();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime today = DateTime.now();
  bool isLoading = false;
  late DateTime focusDay = today;
  Map<DateTime, List<dynamic>> ordersByDay = {};
  Set<DateTime> daysWithOrders = {};

  @override
  void initState() {
    super.initState();
    // Charger les commandes pour le mois actuel
    _fetchOrdersForMonth(today);
  }

  Future<void> _fetchOrdersForMonth(DateTime month) async {
    setState(() {
      isLoading = true;
    });

    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    try {
      String response = await _api.getSchedule(firstDayOfMonth, lastDayOfMonth);
      setState(() {
        ordersByDay.clear();
        daysWithOrders.clear();
        List<dynamic> orders = json.decode(response);

        for (var order in orders) {
          DateTime orderDate = DateTime.parse(order["order"]["order_date"]);

          // Normalisez la date pour exclure l'heure
          DateTime key =
              DateTime(orderDate.year, orderDate.month, orderDate.day);

          if (ordersByDay.containsKey(key)) {
            ordersByDay[key]!.add(order);
          } else {
            ordersByDay[key] = [order];
          }
          daysWithOrders.add(key);
        }
        isLoading = false; // Arrête le chargement ici
        _onDaySelected(today, today);
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Arrête le chargement en cas d'erreur
      });
      print("Exception occurred: $e");
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      this.focusDay = focusedDay;
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                today = DateTime.now();
                _fetchOrdersForMonth(today);
                // _onDaySelected(today, today);
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewDelivery(pickedDate: today),
            ),
          );
        },
        child: const Icon(Icons.add),
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
            focusedDay: focusDay,
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
            onPageChanged: (focusedDay) {
              setState(() {
                this.focusDay = focusedDay;
              });
              _fetchOrdersForMonth(focusedDay);
            },
            eventLoader: (day) {
              // Normalisez la date de la même manière
              DateTime normalizedDay = DateTime(day.year, day.month, day.day);
              return ordersByDay[normalizedDay] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
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
            child: ordersByDay[today]?.isNotEmpty ?? false
                ? MyListWidget(
                    scheduleList: ordersByDay[today]!,
                    chosen: today,
                  )
                : const Center(
                    child: Text(
                      "No delivery for today",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

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

// The rest of your code for fetching coordinates and displaying map markers remains unchanged.

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
