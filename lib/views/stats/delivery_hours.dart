import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class DeliveryHours extends StatelessWidget {
  final List<int> hoursOfDay;
  final List<double> randomValues;

  const DeliveryHours({super.key, required this.hoursOfDay, required this.randomValues});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Hours Chart'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const Text(
                'Delivery Hours Chart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.blue,
                ),
              ),
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
                          hoursOfDay.length,
                          (index) => FlSpot(hoursOfDay[index].toDouble(), randomValues[index]),
                        ),
                        isCurved: true,
                        color: [Colors.blue[400]][0],
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
