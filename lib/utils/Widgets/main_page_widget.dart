// reusable_widgets.dart

import 'package:crash_detection_and_analysis/services/cloud/cloud_data.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class MyReusableWidgets {
  static Widget mainScreen(
      HealthData healthData, PredictionData predictionData) {
    return Column(
      children: [
        Text(
          'Heart Rate: ${healthData.heartRate}',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          predictionData.classifiedHeartRate,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 20,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Temperature: ${healthData.temprature} °C',
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 40),
        ),
        PieChart(dataMap: {
          'Steps': healthData.pedoMeter.toDouble(),
          'Left': (10000 - healthData.pedoMeter).toDouble(),
        })
      ],
    );
  }
}
