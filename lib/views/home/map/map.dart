import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import 'package:diagora/services/api_service.dart';

class MapPage extends StatefulWidget {
  final int userId;
  const MapPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final ApiService _api = ApiService.getInstance();
  String publicToken = const String.fromEnvironment("MAPBOX_PUBLIC_TOKEN");

  mapbox.MapboxMap? mapboxMap;
  mapbox.PointAnnotationManager? pointAnnotationManager;

  late DateTime currentDate;

  void _fetch() async {
    var date = currentDate;
    var dateStart = DateTime(date.year, date.month, date.day, 0, 0, 1);
    var dateEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    String valuesData = await _api.mapItinenaries(dateStart, dateEnd);
    if (valuesData == "false") return;
    dynamic itinerary = json.decode(valuesData);
    if (itinerary["path"]["points"] != null && itinerary["path"]["points"].length > 0) {
      _addMarkers(itinerary["path"]["points"]);
    }
  }

  void _flyToPosition({mapbox.Position? position}) async {
    if (position == null) {
      var currentPosition = await Geolocator.getCurrentPosition();
      position =
          mapbox.Position(currentPosition.longitude, currentPosition.latitude);
    }
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

  void _addMarkers(dynamic pointsArray) {
    mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;

      final ByteData bytes = await rootBundle.load('assets/images/marker-icon.png');
      final Uint8List list = bytes.buffer.asUint8List();

      var options = <mapbox.PointAnnotationOptions>[];
      for (dynamic point in pointsArray) {
        options.add(mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              point['x'],
              point['y'],
            ),
          ).toJson(),
          image: list,
          iconSize: 0.15,
        ));
      }
      pointAnnotationManager?.createMulti(options);
    });
  }

  void _onMapCreated(mapbox.MapboxMap controller) async {
    mapboxMap = controller;
    // Show user location
    mapboxMap?.location.updateSettings(mapbox.LocationComponentSettings(
      enabled: true,
      showAccuracyRing: true,
      pulsingEnabled: true,
      puckBearingEnabled: true,
    ));
    // Fly to user location
    Future.delayed(const Duration(milliseconds: 100), () async {
      _flyToPosition();
    });
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 100,
                width: 350,
                child: CupertinoDatePicker(
                  initialDateTime: currentDate,
                  onDateTimeChanged: (DateTime newdate) {
                    setState(() {
                      currentDate = newdate;
                    });
                  },
                  use24hFormat: true,
                  maximumDate: DateTime.now().add(const Duration(days: 30)),
                  minimumYear: 2010,
                  maximumYear: 2025,
                  minuteInterval: 1,
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _fetch();
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (publicToken.isEmpty) {
      Navigator.pop(context);
      throw Exception("MAPBOX_PUBLIC_TOKEN is not set");
    }
    Permission.locationWhenInUse.request();
    currentDate = DateTime.now();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('MM/dd/yyyy').format(currentDate),
              style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.white),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDialog(context),
          ),
        ],
      ),
      body: mapbox.MapWidget(
        key: const ValueKey("mapWidget"),
        resourceOptions: mapbox.ResourceOptions(accessToken: publicToken),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
