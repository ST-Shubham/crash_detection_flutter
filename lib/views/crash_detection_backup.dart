import 'dart:async';
import 'package:crash_detection_and_analysis/constants/routes.dart';
import 'package:crash_detection_and_analysis/services/auth/auth_service.dart';
import 'package:crash_detection_and_analysis/services/auth/auth_user.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_data.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_queries.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_storage_constants.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/crash_dialog.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/logout_dialog.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/show_error_dialog.dart';
import 'package:crash_detection_and_analysis/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum MenuActions { logout }

class GyroscopeDataCollector extends StatefulWidget {
  const GyroscopeDataCollector({super.key});

  @override
  State<GyroscopeDataCollector> createState() => _GyroscopeDataCollectorState();
}

class _GyroscopeDataCollectorState extends State<GyroscopeDataCollector> {
  late final FirebaseCloudStorage _service;
  late Future<HealthData> healthDataFuture;
  bool shouldSendMessage = false;
  late Future<PredictionData> predictionDataFuture;
  GyroscopeEvent? _gyroscopeData;
  AccelerometerEvent? _accelerometerData;
  MagnetometerEvent? _magnetometerData;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;
  AuthUser user = AuthService.firebase().currentUser!;
  late Timer timer;
  bool shouldSyncCloud = true;
  @override
  void initState() {
    _service = FirebaseCloudStorage();
    super.initState();
    predictionDataFuture = _service.getPredictions(documentId: user.id);
    healthDataFuture = _service.getHeathData(documentId: 'Template');

    // Initialize the gyroscope subscription
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeData = event;
      });
    });
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerData = event;
      });
    });
    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometerData = event;
      });
    });
    late Map<String, double> sensorData;

    _service.createDocumentIfNotExist(
      documentId: user.id,
      sensorData: {
        accx: _accelerometerData?.x ?? 0,
        accy: _accelerometerData?.y ?? 0,
        accz: _accelerometerData?.z ?? 0,
        magx: _magnetometerData?.x ?? 0,
        magy: _magnetometerData?.y ?? 0,
        magz: _magnetometerData?.z ?? 0,
        gyrox: _gyroscopeData?.x ?? 0,
        gyroy: _gyroscopeData?.y ?? 0,
        gyroz: _gyroscopeData?.z ?? 0,
      },
    );

    Timer.periodic(const Duration(seconds: 100), (Timer timer) async {
      sensorData = {
        accx: _accelerometerData?.x ?? 0,
        accy: _accelerometerData?.y ?? 0,
        accz: _accelerometerData?.z ?? 0,
        magx: _magnetometerData?.x ?? 0,
        magy: _magnetometerData?.y ?? 0,
        magz: _magnetometerData?.z ?? 0,
        gyrox: _gyroscopeData?.x ?? 0,
        gyroy: _gyroscopeData?.y ?? 0,
        gyroz: _gyroscopeData?.z ?? 0,
      };
      await _service.updateData(documentId: user.id, sensorData: sensorData);
    });
    timer = Timer.periodic(const Duration(seconds: 40), (Timer t) {
      if (shouldSyncCloud) {
        _service.getPredictions(documentId: user.id).then((data) {
          setState(() {
            predictionDataFuture = Future.value(data);
          });
        });
        _service.getHeathData(documentId: 'Template').then((data) {
          setState(() {
            healthDataFuture = Future.value(data);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancel the gyroscope subscription when the widget
    //is disposed
    _gyroscopeSubscription.cancel();
    _accelerometerSubscription.cancel();
    _magnetometerSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crash Detection - Health Analysis'),
        actions: [
          PopupMenuButton<MenuActions>(
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    if (!mounted) {
                      return;
                    }
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuActions>(
                  value: MenuActions.logout,
                  child: Text("Logout"),
                ),
              ];
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<Object>>(
              future: Future.wait([predictionDataFuture, healthDataFuture]),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  showErrorDialog(context, 'Unable to Fetch Data');
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  PredictionData predictionData =
                      snapshot.data![0] as PredictionData;
                  HealthData healthData = snapshot.data![1] as HealthData;
                  if (predictionData.crashPrediction == 1) {
                    shouldSyncCloud = false;
                  }
                  if (predictionData.heartRateAnomility == 1) {
                    shouldSyncCloud = false;
                  }
                  return Column(
                    children: [
                      Text(
                        'Heart Rate: ${healthData.heartRate} ${predictionData.classifiedHeartRate}',
                      ),
                      Text(
                          'Temprerature: ${healthData.temprature} ${predictionData.feverPrediction}')
                    ],
                  );
                } else {
                  return const Column();
                }
                // } else {
                //   return const LoadingView();
                // }
              },
            ),
          ],
        ),
      ),
    );
  }
}
