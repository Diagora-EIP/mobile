import 'dart:math';

import 'package:flutter/material.dart';

import 'package:diagora/views/stats/delivery_hours.dart';

class Statistiques extends StatefulWidget {
  const Statistiques({super.key});

  @override
  State<Statistiques> createState() => _StatistiquesState();
}

class Stat {
  List<int> hoursOfDays;
  List<double> randomValues;
  final String name;
  final String description;

  Stat({required this.hoursOfDays, required this.randomValues, required this.name, required this.description});
}

class _StatistiquesState extends State<Statistiques> {
  List<Stat> stats = [
    Stat(
      hoursOfDays: List.generate(24, (index) => index),
      randomValues: List.generate(24, (index) => Random().nextDouble()),
      name: "Delivery Hours",
      description: "This is the delivery hours",
    ),
    Stat(
        hoursOfDays: List.generate(24, (index) => index),
        randomValues: List.generate(24, (index) => Random().nextDouble()),
        name: "Km/h travelled",
        description: "This is the km/h travelled"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: stats.length, // Only one item in the grid
                  itemBuilder: (BuildContext context, int index) {
                    Stat currentStat = stats[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryHours(
                              statValue: currentStat,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 100.0, // Adjust the width as needed
                        height: 100.0, // Adjust the height as needed
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor, // Adjust the color as needed
                          // border color to black
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Text(
                            currentStat.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
