import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class PredictionData {
  final int heartRateAnomility;
  final int crashPrediction;
  final String classifiedHeartRate;
  final int feverPrediction;

  const PredictionData({
    required this.heartRateAnomility,
    required this.crashPrediction,
    required this.classifiedHeartRate,
    required this.feverPrediction,
  });

  PredictionData.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : heartRateAnomility = snapshot.data()?[heartAnomilityFieldName],
        crashPrediction = snapshot.data()?[crashPredictionFieldName],
        classifiedHeartRate = snapshot.data()?[heartClassifierFieldName],
        feverPrediction = snapshot.data()?[tempreatureClassfication];
}

@immutable
class HealthData {
  final heartRate;
  final pedoMeter;
  final temprature;

  const HealthData(
      {required this.heartRate,
      required this.pedoMeter,
      required this.temprature});

  HealthData.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : heartRate = snapshot.data()?[heartRateFieldName] ?? 90,
        pedoMeter = snapshot.data()?[stepsFieldName],
        temprature = snapshot.data()?[temperaturFieldName] ?? 36;
}
