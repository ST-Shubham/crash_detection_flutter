// reusable_widgets.dart

import 'package:crash_detection_and_analysis/services/cloud/cloud_data.dart';
import 'package:flutter/material.dart';

class MyReusableWidgets {
  static Widget mainScreen(
      HealthData healthData, PredictionData predictionData) {
    return Column(
      children: [
        Text(
            'Heart Rate: ${healthData.heartRate} ${predictionData.classifiedHeartRate}'),
      ],
    );
  }
}
