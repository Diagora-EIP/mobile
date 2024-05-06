import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'dart:async';

import 'package:background_location/background_location.dart';

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
  final Logger _logger = Logger();
  final List<Map<String, dynamic>> _deliveryStatus = [];
  final List<String> _vehicles = [];
  dynamic allVehicles;
  dynamic myVehicleData;

  mapbox.MapboxMap? mapboxMap;
  mapbox.PointAnnotationManager? pointAnnotationManager;
  mapbox.PolylineAnnotationManager? polylineAnnotationManager;

  bool isDeliveryStarted = false;
  bool anyDeliveryToday = false;

  late DateTime currentDate;

  void _getVehicles() async {
    allVehicles = await _api.getAllUserVehicles();

    for (var vehicule in allVehicles) {
      _vehicles.add(vehicule['name']);
    }

    myVehicleData = await _api.getUserVehicle(widget.userId);

    if (myVehicleData.toString() != "[]") {
      print(myVehicleData[0]['name']);
    }
  }

  void _fetch() async {
    var date = currentDate;
    var dateStart = DateTime(date.year, date.month, date.day, 0, 0, 1);
    var dateEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);
    String valuesData = await _api.mapItinenaries(dateStart, dateEnd);

    pointAnnotationManager?.deleteAll();
    polylineAnnotationManager?.deleteAll();

    if (valuesData == "false") {
      setState(() {
        anyDeliveryToday = false;
      });
      return;
    }
    setState(() {
      anyDeliveryToday = true;
    });
    dynamic itinerary = json.decode(valuesData);
    if (itinerary["path"] != null &&
        itinerary["path"]["points"] != null &&
        itinerary["path"]["points"].length > 0) {
      _addMarkers(itinerary["path"]["points"]);
    }
    if (itinerary["stop_point"] != null &&
        itinerary["stop_point"]["road"] != null &&
        itinerary["stop_point"]["road"].length > 0) {
      _addRoads(itinerary["stop_point"]["road"]);
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

      final ByteData bytes =
          await rootBundle.load('assets/images/marker-icon.png');
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
          iconSize: 0.10,
        ));
        _deliveryStatus.add({
          'lat': point['x'],
          'long': point['y'],
          'isDelivered': false,
          'address': point['address'],
        });
      }
      pointAnnotationManager?.createMulti(options);
    });
  }

  void _addRoads(dynamic pointsArray) {
    mapboxMap?.annotations.createPolylineAnnotationManager().then((value) {
      polylineAnnotationManager = value;

      List<mapbox.Position> positions = [];
      for (var point in pointsArray) {
        double x = point["x"];
        double y = point["y"];
        positions.add(mapbox.Position(x, y));
      }

      var option = mapbox.PolylineAnnotationOptions(
        geometry: mapbox.LineString(coordinates: positions).toJson(),
        lineColor: Colors.blue.value,
        lineWidth: 4,
      );
      polylineAnnotationManager?.create(option);
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

  void launchAppleMaps(
      double latitude, double longitude, String address) async {
    try {
      MapsLauncher.launchCoordinates(latitude, longitude, address);
    } catch (e) {
      _logger.e('Error: $e');
    }
  }

  void launchWaze(double latitude, double longitude, String address) async {
    String encodedAddress = Uri.encodeComponent(address);
    var url = 'waze://?q=$encodedAddress';
    Uri uri = Uri.parse(url);

    try {
      await launchUrl(uri);
    } catch (e) {
      _logger.e('Error: $e');
    }
  }

  void launchGoogleMaps(
      double latitude, double longitude, String address) async {
    var url = 'https://www.google.com/maps/search/?api=1&query=$address';
    Uri uri = Uri.parse(url);

    try {
      await launchUrl(uri);
    } catch (e) {
      _logger.e('Error: $e');
    }
  }

  Map<String, dynamic> _nextDeliveryPosition() {
    for (var i = 0; i < _deliveryStatus.length; i++) {
      if (!_deliveryStatus[i]['isDelivered']) {
        return {
          'latitude': _deliveryStatus[i]['lat'],
          'longitude': _deliveryStatus[i]['long'],
          'address': _deliveryStatus[i]['address'],
        };
      }
    }
    return {};
  }

  void _chooseGps(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Choose Navigation App'),
          actions: <Widget>[
            Platform.isIOS
                ? CupertinoActionSheetAction(
                    onPressed: () {
                      // Open Apple Maps
                      // Add your Apple Maps integration logic here
                      Map<String, dynamic> nextPosition =
                          _nextDeliveryPosition();
                      launchAppleMaps(nextPosition['latitude'],
                          nextPosition['longitude'], nextPosition['address']);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apple Maps'),
                  )
                : const SizedBox(),
            CupertinoActionSheetAction(
              onPressed: () {
                // Open Google Maps
                // Add your Google Maps integration logic here
                Map<String, dynamic> nextPosition = _nextDeliveryPosition();
                launchGoogleMaps(nextPosition['latitude'],
                    nextPosition['longitude'], nextPosition['address']);
                Navigator.of(context).pop();
              },
              child: const Text('Google Maps'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                // Open Waze
                // Add your Waze integration logic here
                Map<String, dynamic> nextPosition = _nextDeliveryPosition();
                launchWaze(nextPosition['latitude'], nextPosition['longitude'],
                    nextPosition['address']);
                Navigator.of(context).pop();
              },
              child: const Text('Waze'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Timer? locationUpdateTimer;
  int lastTick = -1;

  void startLocationUpdates() {
    locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      BackgroundLocation.getLocationUpdates((location) {
        if (locationUpdateTimer?.tick == lastTick) {
          return;
        }
        _api.registerPosition(location);
        lastTick = locationUpdateTimer!.tick;
      });
    });
  }

  void _startDelivery(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Start Delivery'),
          content: const Text('Do you want to start delivery?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                BackgroundLocation.stopLocationService();
                BackgroundLocation.startLocationService();

                startLocationUpdates();

                setState(() {
                  isDeliveryStarted = true;
                });
                if (myVehicleData.toString() == "[]") {
                  choseVehicule();
                } else {
                  _chooseGps(context);
                }
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void _stopDelivery(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Stop Delivery'),
          content: const Text('Do you want to stop the delivery?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                BackgroundLocation.stopLocationService();
                setState(() {
                  isDeliveryStarted = false;
                });
              },
              child: const Text('Stop'),
            ),
          ],
        );
      },
    );
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
                width: 500,
                child: CupertinoDatePicker(
                  initialDateTime: currentDate,
                  onDateTimeChanged: (DateTime newdate) {
                    setState(() {
                      currentDate = newdate;
                    });
                  },
                  use24hFormat: true,
                  maximumDate: DateTime(2030, 12, 30),
                  minimumYear: 2010,
                  maximumYear: 2030,
                  minuteInterval: 1,
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              const SizedBox(height: 15),
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

  void connectVehicleToUser(int choosenVehicle) async {
    await _api.connectVehicleToUser(widget.userId, choosenVehicle);

    _api.getUserVehicle(widget.userId).then((value) {
      myVehicleData = value;
    });
  }

  int getChoosenVehicleIndex(String choosenVehicle) {
    for (var vehicle in allVehicles) {
      if (vehicle['name'] == choosenVehicle) {
        return vehicle['vehicle_id'];
      }
    }
    return -1;
  }

  void choseVehicule() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Choose a vehicule'),
          actions: _vehicles
              .map(
                (String vehicule) => CupertinoActionSheetAction(
                  onPressed: () {
                    connectVehicleToUser(getChoosenVehicleIndex(vehicule));
                    Navigator.of(context).pop();
                    _chooseGps(context);
                  },
                  child: Text(vehicule),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
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
    _getVehicles();
  }

  @override
  void dispose() {
    super.dispose();
    BackgroundLocation.stopLocationService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Map'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('dd.MM.yyyy').format(currentDate),
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
      body: Stack(children: [
        mapbox.MapWidget(
          key: const ValueKey("mapWidget"),
          resourceOptions: mapbox.ResourceOptions(accessToken: publicToken),
          onMapCreated: _onMapCreated,
        ),
        Align(
          alignment: Alignment.topRight,
          child: CupertinoButton(
            padding: const EdgeInsets.only(top: 60.0, right: 16.0),
            onPressed: () {
              _flyToPosition();
            },
            child: const Icon(
              Icons.gps_fixed,
              color: Colors.blue,
            ),
          ),
        ),
        anyDeliveryToday
            ? isDeliveryStarted
                ? Positioned(
                    bottom: 16,
                    left: MediaQuery.of(context).size.width / 2 - 60.0,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: FloatingActionButton(
                            onPressed: () {
                              _stopDelivery(context);
                            },
                            backgroundColor: Colors.red,
                            child: const Icon(Icons.local_shipping),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            _chooseGps(context);
                          },
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.map),
                        ),
                      ],
                    ),
                  )
                : Positioned(
                    bottom: 16.0,
                    left: MediaQuery.of(context).size.width / 2 - 30.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        _startDelivery(context);
                      },
                      child: const Icon(Icons.local_shipping),
                    ),
                  )
            : Positioned(
                bottom: 16.0,
                left: MediaQuery.of(context).size.width / 2 - 50.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('No delivery today',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
      ]),
    );
  }
}
