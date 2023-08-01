import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:diagora/services/api_service.dart';

import 'dart:math';
import 'dart:convert';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ApiService _api = ApiService.getInstance();
  List<Polyline> polylines = [];
  List<LatLng> coordinates = [];
  double long = 0;
  double lat = 0;
  double lastLat = 0;
  double lastLong = 0;
  double currentZoom = 3.2;
  double maxZoom = 10.0;
  DateTime today = DateTime.now();
  DateTime end = DateTime.now();
  String todayValueString = "";
  late Future<String> allTodaysTrajValues;
  List<dynamic> calendarList = [];
  List<dynamic> scheduleList = [];
  late DateTime todayDate;
  late DateTime todayStart;
  late DateTime todayEnd;
  int userId = -1;
  bool deliveryToday = true;

  @override
  void initState() {
    Random random = Random();

    todayDate = DateTime.parse(today.toString());
    todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day, 1);
    todayEnd = DateTime(todayDate.year, todayDate.month, todayDate.day, 23);
    userId = _api.user!.getUserId();
    allTodaysTrajValues = _api.mapValues(todayStart, todayEnd, userId);

    allTodaysTrajValues.then((value) {
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
    setState(() {
      for (int i = 0; i < 3; i++) {
        lastLong = 0;
        lastLat = 0;
        final color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
            .withOpacity(1.0);
        coordinates = [];
        for (int a = 0; a < 5; a++) {
          int val = 6;
          int randomLat = random.nextInt(val);
          int randomLong = random.nextInt(val);
          lat = 43.611015 + lastLat;
          long = 3.877160 + lastLong;
          lastLong = randomLong / 10;
          lastLat = randomLat / 10;
          coordinates.add(LatLng(lat, long));
        }
        polylines.add(Polyline(
          points: coordinates,
          color: color,
          strokeWidth: 2.0,
        ));
      }
    });
    super.initState();
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
        title: const Text('Map'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(51.509364, -0.128928),
              zoom: currentZoom,
              onPositionChanged: (mapPosition, boolValue) {
                if (mapPosition.zoom! > maxZoom) {
                  setState(() {
                    currentZoom = maxZoom;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolylineLayer(polylines: polylines),
              GestureDetector(
                onTap: () {
                  // Handle polyline tap
                  // ignore: avoid_print
                  print('Polyline tapped!');
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
