import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:diagora/views/stats/stats.dart';

class DeliveryHours extends StatelessWidget {
  final Stat statValue;

  const DeliveryHours({super.key, required this.statValue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${statValue.name} Chart'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: true),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1),
                    ),
                    minX: 0,
                    maxX: 23,
                    minY: 0,
                    maxY: 1,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          statValue.hoursOfDays.length,
                          (index) => FlSpot(statValue.hoursOfDays[index].toDouble(), statValue.randomValues[index]),
                        ),
                        isCurved: true,
                        color: [Colors.blue[400]][0],
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              Text(
                statValue.description,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
