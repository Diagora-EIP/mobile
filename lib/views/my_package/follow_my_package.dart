import 'package:flutter/material.dart';

// import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:diagora/views/my_package/my_package.dart';
import 'package:diagora/views/home/calendar/calendar.dart';

class FollowMyPackage extends StatefulWidget {
  final Package item;

  const FollowMyPackage({Key? key, required this.item}) : super(key: key);

  @override
  State<FollowMyPackage> createState() => _FollowMyPackageState();
}

class _FollowMyPackageState extends State<FollowMyPackage> {
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
        title: const Text('Follow My Package'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                widget.item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.blue, // Adjust the color as needed
                ),
              ),
              Text(
                widget.item.address,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16.0,
                  color: Colors.grey, // Adjust the color as needed
                ),
              ),
              Text(
                "Date: ${widget.item.date}",
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              FutureBuilder<LatLng>(
                future: fetchCoordinates(widget.item.address),
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
                            const SizedBox(height: 8),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 3 / 5,
                              child: FlutterMap(
                                options: MapOptions(
                                  center: coord,
                                  zoom: zoomLevel,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            ],
          ),
        ),
      ),
    );
  }
}
