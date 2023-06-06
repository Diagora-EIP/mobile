import 'package:flutter/material.dart';

import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Polyline> polylines = [];
  List<LatLng> coordinates = [];
  double long = 0;
  double lat = 0;
  double lastLat = 0;
  double lastLong = 0;

  @override
  void initState() {
    Random random = Random();

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
              zoom: 3.2,
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