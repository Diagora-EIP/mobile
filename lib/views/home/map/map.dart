import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

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
  List<Marker> markerCoord = [];
  List<LatLng> coordinates = [];
  List<LatLng> markerCoordinates = [];
  double long = 0;
  double lat = 0;
  double lastLat = 0;
  double lastLong = 0;
  double currentZoom = 3.2;
  double maxZoom = 10.0;
  DateTime today = DateTime.now();
  DateTime end = DateTime.now();
  String todayValueString = "";
  List<dynamic> calendarList = [];
  List<dynamic> scheduleList = [];
  late DateTime todayDate;
  late DateTime todayStart;
  late DateTime todayEnd;
  LatLng coord = LatLng(0, 0);
  int userId = -1;
  bool deliveryToday = true;

  @override
  void initState() {
    // Random random = Random();
    todayDate =
        DateTime.now(); // Use DateTime.now() to get the current date and time.
    todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day, 1);
    todayEnd = DateTime(todayDate.year, todayDate.month, todayDate.day, 23);
    userId = _api.user!
        .getUserId(); // Replace this with your actual way of getting the user ID.

    // Make sure _api.mapValues returns a Future<String>.
    Future<String> allTodaysTrajValues =
        _api.mapValues(todayStart, todayEnd, userId);

    allTodaysTrajValues.then((response) {
      List<dynamic> responseData = json.decode(response);

      // CHECK OUT LIGNE 65: dynamic traj = responseData[i]['path'][0]['path']; -> [0] MIGHT NEED TO BE IN A LOOP TO GET ALL THE TRAJ OF THE DAY AND NOT JUST THE FIRST ONE
      for (int i = 0; i < responseData.length; i++) {
        coordinates = [];
        dynamic trajId = responseData[i]['id'];
        print(trajId);
        dynamic traj = responseData[i]['path'][0]['path'];
        int len = traj.length - 1;
        for (int a = 0; a < traj.length; a++) {
          coordinates.add(LatLng(traj[a]['lat'], traj[a]['lon']));
        }
        final color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
            .withOpacity(1.0);
        coord = LatLng(traj[len]['lat'], traj[len]['lon']);
        markerCoord.add(Marker(
            width: 80.0,
            height: 80.0,
            point: coord,
            builder: (ctx) => GestureDetector(
                  onTap: () {
                    print('Marker clicked ${coord} ${trajId} !');
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 48,
                  ),
                )));
        polylines.add(Polyline(
          points: coordinates,
          color: color,
          strokeWidth: 2.0,
        ));
      }
    }).catchError((error) {
      // ignore: avoid_print
      print("error in map values: $error ");
    });

    super.initState();
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
              MarkerLayer(markers: markerCoord)
            ],
          ),
        ],
      ),
    );
  }
}
