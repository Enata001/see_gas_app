import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseDatabaseMethods {
  FirebaseDatabaseMethods._();
  static final _db = FirebaseDatabase.instance;

  static Stream<Map<String, dynamic>> getSensorReadings(String deviceId) {
    // final databaseRef = _db.ref().child('devices/$deviceId/readings');
    final databaseRef = _db.ref().child(deviceId);
    return databaseRef.onValue.map((event) {
      try {
        final data = event.snapshot.value;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        } else {
          return {};
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print('Error fetching sensor readings for device $deviceId: $e');
        }
        return {};
      }
    });
  }
}
