import 'dart:async';
import 'package:crash_detection_and_analysis/constants/routes.dart';
import 'package:crash_detection_and_analysis/services/auth/auth_service.dart';
import 'package:crash_detection_and_analysis/services/auth/auth_user.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_data.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_queries.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_storage_constants.dart';
import 'package:crash_detection_and_analysis/utils/Widgets/main_page_widget.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/crash_dialog.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/heart_anom_dialog.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/logout_dialog.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/show_error_dialog.dart';
// import 'package:crash_detection_and_analysis/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
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
  late String messageResult;
  late Future<PredictionData> predictionDataFuture;
  GyroscopeEvent? _gyroscopeData;
  bool shouldSyncData = true;
  bool shouldSendMessage = false;
  AccelerometerEvent? _accelerometerData;
  MagnetometerEvent? _magnetometerData;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;
  AuthUser user = AuthService.firebase().currentUser!;
  late Timer timer;
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
    timer = Timer.periodic(const Duration(seconds: 100), (Timer t) {
      if (shouldSyncData) {
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
    timer.cancel();

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
                  final shouldLogOut = await showCrashDialog(context);
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
                // return const CircularProgressIndicator();
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  PredictionData predictionData =
                      snapshot.data![0] as PredictionData;
                  HealthData healthData = snapshot.data![1] as HealthData;
                  if (predictionData.crashPrediction == 1) {
                    shouldSyncData = false;
                    // return FutureBuilder<bool?>(
                    //   future: showLogOutDialog(context),
                    //   builder: (context, snapshot) {
                    //     if (snapshot.connectionState ==
                    //         ConnectionState.waiting) {
                    //       return CircularProgressIndicator();
                    //     } else if (snapshot.hasError) {
                    //       return Text('Error: ${snapshot.error}');
                    //     } else {
                    //       // Handle the result of the dialog
                    //       final result = snapshot.data;
                    //       if (result == true) {
                    //         return Text('User pressed Ok');
                    //       } else {
                    //         return Text('User didn\'t press Ok');
                    //       }
                    //     }
                    //   },
                    // );
                    // //   builder: (context, snapshot) {

                    //         // FutureBuilder(
                    //         //   future: sendSMS(
                    //         //       message: 'A crash was detected ',
                    //         //       recipients: ['6261943187', '8982725988']),
                    //         //   builder: (context, snapshot) {
                    //         //     if (snapshot.hasError) {
                    //         //       return const Center(
                    //         //         child: Text('GG Bro'),
                    //         //       );
                    //         //     } else if (snapshot.hasData) {
                    //         //       return Container();
                    //         //     } else {
                    //         //       return const CircularProgressIndicator();
                    //         //     }
                    //         //   },
                    //         // );
                    //       } else {
                    //         shouldSyncData = true;
                    //         return MyReusableWidgets.mainScreen(
                    //             healthData, predictionData);
                    //       }
                    //     } else {
                    //       return const CircularProgressIndicator();
                    //     }
                    //   },;
                  } else if (predictionData.heartRateAnomility == 1) {
                    shouldSyncData = false;
                    FutureBuilder(
                      future: showHeartAnomilityDialog(context),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == true) {
                            return FutureBuilder(
                              future: sendSMS(
                                  message: 'A Heart Rate Anomility',
                                  recipients: ['6261943187', '8982725988']),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                    child: Text('GG Bro'),
                                  );
                                } else if (snapshot.hasData) {
                                  return Container();
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            );
                          } else {
                            shouldSyncData = true;
                            return MyReusableWidgets.mainScreen(
                                healthData, predictionData);
                          }
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    );
                  }
                  return MyReusableWidgets.mainScreen(
                      healthData, predictionData);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
