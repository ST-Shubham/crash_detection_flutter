import 'package:crash_detection_and_analysis/services/cloud/cloud_data.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_exceptions.dart';
import 'package:crash_detection_and_analysis/services/cloud/cloud_storage_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCloudStorage {
  final data = FirebaseFirestore.instance.collection('CrashData');
  final prediciton = FirebaseFirestore.instance.collection('Predictions');
  final health = FirebaseFirestore.instance.collection('HealthData');

  Future<void> updateData({
    required String documentId,
    required Map<String, double> sensorData,
  }) async {
    try {
      await data.doc(documentId).update({
        accx: sensorData[accx],
        accy: sensorData[accy],
        accz: sensorData[accz],
        gyrox: sensorData[gyrox],
        gyroy: sensorData[gyroy],
        gyroz: sensorData[gyroz],
        magx: sensorData[magx],
        magy: sensorData[magy],
        magz: sensorData[magz]
      });
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> createDocumentIfNotExist({
    required String documentId,
    required Map<String, double> sensorData,
  }) async {
    DocumentReference docRef = data.doc(documentId);
    DocumentSnapshot docSnapshot = await docRef.get();
    DocumentReference predRef = prediciton.doc(documentId);
    DocumentSnapshot predSnapshot = await predRef.get();
    DocumentReference healthRef = health.doc(documentId);
    DocumentSnapshot healthSnapshot = await healthRef.get();
    if (!docSnapshot.exists) {
      await docRef.set(sensorData);
    }
    if (!predSnapshot.exists) {
      await predRef.set({
        'anom_HR': 0,
        'class_HR': 'Normal',
        'crash_prediction': 0,
        'pred_Temp': 0,
      });
    }
    if (!healthSnapshot.exists) {
      await healthRef.set({
        'Temperature': 0,
        'HeartRate': 0,
        'Pedometer': 0,
      });
    }
  }

  Future<PredictionData> getPredictions({required String documentId}) async {
    try {
      return await prediciton
          .doc(documentId)
          .get()
          .then((value) => PredictionData.fromSnapshot(value));
    } catch (_) {
      throw CouldNotGetPredictionException();
    }
  }

  Future<HealthData> getHeathData({required String documentId}) async {
    try {
      return await prediciton
          .doc(documentId)
          .get()
          .then((value) => HealthData.fromSnapshot(value));
    } catch (_) {
      throw CouldNotGetPredictionException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
