import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
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
  LatLng markerCoordinates = LatLng(0, 0);
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
  int userId = -1;
  dynamic userData;
  bool deliveryToday = true;

  void _showMarkerInfo(String address, String begin, String end) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delivery Info'),
          content: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                const TextSpan(
                  text: 'Address: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '$address \n'),
                const TextSpan(
                  text: 'Start Time: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '$begin\n'),
                const TextSpan(
                  text: 'End Time: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: end),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    todayDate = DateTime.now();
    todayStart = DateTime(todayDate.year, todayDate.month, todayDate.day, 1);
    todayEnd = DateTime(todayDate.year, todayDate.month, todayDate.day, 23);
    userData = _api.user?.toJson();
    userId = userData['user_id'];
    Future<String> allTodaysTrajValues =
        _api.mapValues(todayStart, todayEnd, userId);

    allTodaysTrajValues.then((response) {
      if (response == 'false') {
        return;
      }
      List<dynamic> responseData = json.decode(response);

      for (int i = 0; i < responseData.length; i++) {
        coordinates = [];
        dynamic traj = responseData[i]['path'][0]['path'];
        print("path: ");
        print(responseData[i]['path'].length);

        dynamic stopPoints = responseData[i]['stop_point'];
        for (int a = 0; a < traj.length; a++) {
          coordinates.add(LatLng(traj[a]['lat'], traj[a]['lon']));
        }
        print("stops: ");
        print(stopPoints.length);
        for (int a = 0; a < stopPoints.length; a++) {
          // Get lat/long of the stop point
          String lat = stopPoints[a]['lat'];
          String long = stopPoints[a]['long'];
          // Change lat/long to double
          double doubleLat = double.parse(lat);
          double doubleLong = double.parse(long);
          // Create LatLong type
          markerCoordinates = LatLng(doubleLat, doubleLong);
          // Get address
          String address = stopPoints[a]['autocompleteAdress'];
          // Get time of the delivery (start/end)
          DateTime begining = DateTime.parse(stopPoints[a]['begin']);
          DateTime ending = DateTime.parse(stopPoints[a]['end']);
          // Formatize the date
          DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');
          String formattedBegin = outputFormat.format(begining);
          String formattedEnd = outputFormat.format(ending);
          // Create a marker
          markerCoord.add(Marker(
              width: 80.0,
              height: 80.0,
              point: markerCoordinates,
              builder: (ctx) => GestureDetector(
                    onTap: () {
                      _showMarkerInfo(address, formattedBegin, formattedEnd);
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.black,
                      size: 48,
                    ),
                  )));
        }
        final color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
            .withOpacity(1.0);
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
