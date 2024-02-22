import 'dart:math';

import 'package:flutter/material.dart';

import 'package:diagora/views/stats/stats_values.dart';

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

  Stat(
      {required this.hoursOfDays,
      required this.randomValues,
      required this.name,
      required this.description});
}

class _StatistiquesState extends State<Statistiques> {
  List<Stat> stats = [
    Stat(
      hoursOfDays: List.generate(24, (index) => index),
      randomValues: List.generate(24, (index) => Random().nextDouble()),
      name: "Best hours to do deliveries",
      description:
          "This is the best hours to do deliveries.\nOn the x axis you have the hours of the day and on the y axis you have the number of deliveries",
    ),
    Stat(
        hoursOfDays: List.generate(24, (index) => index),
        randomValues: List.generate(24, (index) => Random().nextDouble()),
        name: "Km/h travelled",
        description:
            "This is the km/h travelled.\nOn the x axis you have the hours of the day and on the y axis you have the km/h travelled"),
    Stat(
        hoursOfDays: List.generate(24, (index) => index),
        randomValues: List.generate(24, (index) => Random().nextDouble()),
        name: "Average fuel consumption",
        description:
            "This is the Average fuel consumption.\nOn the x axis you have the hours of the day and on the y axis you have the km/h travelled"),
    Stat(
        hoursOfDays: List.generate(24, (index) => index),
        randomValues: List.generate(24, (index) => Random().nextDouble()),
        name: "Fuel consumption of one delivery",
        description:
            "This is the fuel consumption of one delivery.\nOn the x axis you have the hours of the day and on the y axis you have the km/h travelled"),
    Stat(
        hoursOfDays: List.generate(24, (index) => index),
        randomValues: List.generate(24, (index) => Random().nextDouble()),
        name: "Km done for one delivery",
        description:
            "This is Km done for one delivery.\nOn the x axis you have the hours of the day and on the y axis you have the km/h travelled"),
  ];

  @override
  Widget build(BuildContext context) {
    bool isScreenHorizontal =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
              left: isScreenHorizontal ? 50 : 0.0,
              right: isScreenHorizontal ? 50 : 0.0),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isScreenHorizontal ? 4 : 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: stats.length,
                    itemBuilder: (BuildContext context, int index) {
                      Stat currentStat = stats[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatValue(
                                statValue: currentStat,
                              ),
                            ),
                          );
                        },
                        child: Container(
                            width: isScreenHorizontal
                                ? 50
                                : 100.0, // Adjust the width as needed
                            height: isScreenHorizontal
                                ? 50
                                : 100.0, // Adjust the height as needed
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  currentStat.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            )),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
