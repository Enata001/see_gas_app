// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:see_gas_app/utils/extensions.dart';
// import 'package:see_gas_app/utils/navigation.dart';
// import '../utils/constants.dart';
//
// part 'device_provider.g.dart';
//
// class DeviceNotifier extends ChangeNotifier {
//   final BluetoothDevice device;
//   DeviceNotifier(this.device);
//
//   BluetoothCharacteristic? userDetailsCharacteristic;
//   BluetoothCharacteristic? wifiCredentialsCharacteristic;
//   BluetoothCharacteristic? wifiNetworksCharacteristic;
//
//   List<String> networks = [];
//   String ssid = "";
//   bool isFirst = true;
//   bool isScanning = false;
//   bool isCurrentlyConnected = false;
//   bool isConnecting = false;
//   String initialResult = "";
//
//   Future<void> connectToDevice() async {
//     bool isConnected = false;
//     Navigation().loading();
//     try {
//       await device.connect(timeout: const Duration(seconds: 20));
//       isConnected = true;
//       isCurrentlyConnected = true;
//       notifyListeners();
//     } catch (e) {
//       Navigation.close();
//       Navigation().messenger(
//         title: "Error",
//         color: const Color(0xFFC20D00),
//         icon: CupertinoIcons.clear_circled_solid,
//         description: 'Failed to connect to device',
//       );
//     }
//     if (isConnected) {
//       await discoverServices();
//     }
//   }
//
//   Future<void> discoverServices() async {
//     await device.requestMtu(512);
//     List<BluetoothService> services = await device.discoverServices();
//
//     for (var service in services) {
//       if (service.uuid.toString() == Constants.serviceUUID) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.uuid.toString() == Constants.networkCharacteristicUUID) {
//             wifiNetworksCharacteristic = characteristic;
//             await wifiNetworksCharacteristic?.setNotifyValue(true);
//             isScanning = true;
//             notifyListeners();
//
//             wifiNetworksCharacteristic?.lastValueStream.listen((value) {
//               String networksString = utf8.decode(value);
//               networks = networksString.split('\n').where((s) => s.isNotEmpty).toList();
//               isScanning = false;
//               notifyListeners();
//             });
//           } else if (characteristic.uuid.toString() == Constants.userCharacteristicUUID) {
//             userDetailsCharacteristic = characteristic;
//           } else if (characteristic.uuid.toString() == Constants.wifiCharacteristicUUID) {
//             wifiCredentialsCharacteristic = characteristic;
//           }
//         }
//       }
//     }
//     Navigation.close();
//   }
//
//   void sendDeviceDetails(String name, String location, String contact) async {
//     String userDetails = "$name,$location,$contact";
//     await userDetailsCharacteristic!.write(userDetails.codeUnits);
//     if (!isFirst) return;
//     isFirst = false;
//     notifyListeners();
//     Navigation.close();
//   }
//
//   void sendWiFiCredentials(String ssid, String password) async {
//     try {
//       wifiCredentialsCharacteristic?.lastValueStream.drain();
//       await wifiCredentialsCharacteristic!.setNotifyValue(true);
//       String wifiCredentials = "$ssid,$password";
//       await wifiCredentialsCharacteristic!.write(wifiCredentials.codeUnits);
//
//       wifiCredentialsCharacteristic!.onValueReceived.listen((value) async {
//         String result = String.fromCharCodes(value);
//         if (result == "success" && result != initialResult) {
//           initialResult = "success";
//           await device.disconnect().whenComplete(() {
//             Navigation.close();
//             Navigation().messenger(
//               title: "Success",
//               color: CupertinoColors.systemGreen,
//               icon: CupertinoIcons.check_mark_circled_solid,
//               description: 'Connected to device',
//             );
//             Navigation.skipTo(Navigation.home);
//           });
//         } else if (result == "failure" && result != initialResult) {
//           initialResult = "failure";
//           Navigation.close();
//           isConnecting = !isConnecting;
//           notifyListeners();
//         }
//       });
//     } on Exception {
//       Navigation.close();
//       Navigation().messenger(
//         title: "Error",
//         color: CupertinoColors.systemRed,
//         icon: CupertinoIcons.clear_circled_solid,
//         description: 'Failed to send Wi-Fi credentials',
//       );
//     }
//   }
// }
//
// @riverpod
// ChangeNotifierProvider<DeviceNotifier> deviceNotifierProvider(BluetoothDevice device) {
//   return ChangeNotifierProvider((ref) => DeviceNotifier(device));
// }
