import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/features/authentication/entities/auth_result.dart';

import '../models/device_info_model.dart';
import '../models/user_model.dart';
import '../providers/auth_state_notifier.dart';
import '../utils/firebase_fields.dart';

class FirestoreMethods {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  Future<bool> storeUserInfo(
      {required UserModel user, required List<String> provider}) async {
    try {
      final userInfo =
          await _store.collection(FirebaseFields.users).doc(user.userId).get();

      if (userInfo.exists) {
        await _store.collection(FirebaseFields.users).doc(user.userId).update(
              user.toMap(),
            );
      } else {
        await _store.collection(FirebaseFields.users).doc(user.userId).set(
            {...user.toMap(), 'providerData': FieldValue.arrayUnion(provider)},
            SetOptions(merge: true));
      }
      return true;
    } on Exception {
      return false;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUser(
      {required String email}) async {
    final result = await _store
        .collection(FirebaseFields.users)
        .where(
          FirebaseFields.email,
          isEqualTo: email,
        )
        .get();

    return result;
  }

  Future<List<String>> getProviderData({required String email}) async {
    try {
      final result = await getUser(email: email);
      if (result.docs.isNotEmpty) {
        final userDoc = result.docs.first.data();

        final List<String> providerData =
            List<String>.from(userDoc['providerData'] ?? []);
        print(providerData);
        return providerData;
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting provider data: $e");
      return []; // Return an empty list in case of an error
    }
  }

  Future<void> updateUserProviderData(
      String userId, List<String> providerData) async {
    try {
      await _store.collection('users').doc(userId).update({
        'providerData': providerData,
      });
    } catch (e) {
      print("Error updating provider data: $e");
    }
  }

  Future<void> updateUserData(UserModel user) async {
    try {
      await _store.collection('users').doc(user.userId).update(user.toMap());
    } catch (e) {
      print("Error updating provider data: $e");
    }
  }

  Future<List<DeviceInfo>> getUserDevices(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final deviceIds = List<String>.from(userDoc.data()?['devices'] ?? []);

      final devices = await Future.wait(deviceIds.map((id) async {
        final deviceDoc = await FirebaseFirestore.instance
            .collection('devices')
            .doc(id)
            .get();
        if (deviceDoc.exists) {
          return DeviceInfo.fromJson(deviceDoc.data()!);
        } else {
          return null;
        }
      }));
      return devices
          .whereType<DeviceInfo>()
          .toList(); // Returns List<DeviceInfo>
    } catch (e) {
      print('Error fetching user devices: $e');
      return [];
    }
  }

  Stream<List<DeviceInfo>> getDevices(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      try {
        if (userDoc.exists && userDoc.data()!.containsKey('devices')) {
          final deviceIds = List<String>.from(userDoc['devices'] ?? []);
          if (deviceIds.isEmpty) {
            return [];
          }
          final devices = await Future.wait(
            deviceIds.map((id) async {
              final device = await getDeviceInfo(id);
              return device;
            }).toList(),
          );
          return devices
              .where((device) => device != null)
              .cast<DeviceInfo>()
              .toList();
        } else {
          return [];
        }
      } catch (e) {
        print('Error fetching devices: $e');
        return [];
      }
    });
  }

  Future<DeviceInfo?> getDeviceInfo(String deviceId) async {
    final doc = await FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId)
        .get();
    if (doc.exists) {
      return DeviceInfo(
        id: doc['id'],
        name: doc['name'],
        location: doc['location'],
      );
    }
    return null;
  }

  Future<void> uploadDeviceInfo(DeviceInfo deviceInfo, String userId) async {
    try {
      await _store
          .collection('devices')
          .doc(deviceInfo.id)
          .set(deviceInfo.toJson());

      await _store.collection('users').doc(userId).update({
        'devices': FieldValue.arrayUnion([deviceInfo.id]),
      });

      print(
          'Device info uploaded and user\'s device list updated successfully.');
    } catch (e) {
      print('Error uploading device info: $e');
    }
  }

  Future<AuthResult> deleteDevice(Ref ref, String deviceId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _store.collection('users').doc(userId).update({
        'devices': FieldValue.arrayRemove([deviceId])
      });
      await _store.collection('devices').doc(deviceId).delete();
      return AuthResult.success;
    } on Exception catch (e) {
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }
}
