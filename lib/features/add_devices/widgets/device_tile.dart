import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:see_gas_app/services/firebase_firestore_methods.dart';
import 'package:see_gas_app/utils/dimensions.dart';
import 'package:see_gas_app/utils/extensions.dart';

import '../../../common_widgets/c_elevated_button.dart';
import '../../../common_widgets/c_text_field.dart';
import '../../../common_widgets/contact_widget.dart';
import '../../../models/device_info_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation.dart';

class DeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final int rssi;

  const DeviceTile({
    super.key,
    required this.device,
    required this.rssi,
  });

  @override
  State<DeviceTile> createState() => _DeviceTileState();

  static TextStyle _computeStyle(int rssi) {
    final Map<int, Color> rssiRanges = {
      -35: Colors.greenAccent[700]!,
      -45: Colors.lightGreen,
      -55: Colors.lime[600]!,
      -65: Colors.amber,
      -75: Colors.deepOrangeAccent,
      -85: Colors.redAccent,
    };

    for (var range in rssiRanges.entries) {
      if (rssi >= range.key) {
        return TextStyle(color: range.value.withOpacity(0.8));
      }
    }
    return TextStyle(color: Colors.redAccent.withOpacity(0.8));
  }
}

class _DeviceTileState extends State<DeviceTile> {
  BluetoothCharacteristic? userDetailsCharacteristic;
  BluetoothCharacteristic? wifiCredentialsCharacteristic;
  BluetoothCharacteristic? wifiNetworksCharacteristic;

  List<String> networks = [];
  String ssid = "";
  static final _deviceDetailsFormKey = GlobalKey<FormState>();
  static final _wifiCredentialsFormKey = GlobalKey<FormState>();
  bool isFirst = true;
  bool isScanning = false;
  bool isCurrentlyConnected = false;
  bool isConnecting = false;
  String initialResult = "";
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String remoteId = "";
  String phoneNumber = "";

  Future<void> _connectToDevice() async {
    bool isConnected = false;
    Navigation().loading();
    try {
      await widget.device.connect(timeout: const Duration(seconds: 20));
      isConnected = true;
      isCurrentlyConnected = true;
    } catch (e) {
      Navigation.close();
      Navigation().messenger(
        title: "Error",
        color: const Color(0xFFC20D00),
        icon: CupertinoIcons.clear_circled_solid,
        description: 'Failed to connect to device',
      );
    }
    if (isConnected) {
      await _discoverServices();
    }
  }

  Future<void> _discoverServices() async {
    await widget.device.requestMtu(512);
    List<BluetoothService> services = await widget.device.discoverServices();
    remoteId = widget.device.remoteId.str;
    for (var service in services) {
      if (service.uuid.toString() == Constants.serviceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              Constants.networkCharacteristicUUID) {
            wifiNetworksCharacteristic = characteristic;
            await wifiNetworksCharacteristic?.setNotifyValue(true);
            setState(() {
              isScanning = true; // Set scanning to true
            });
            wifiNetworksCharacteristic?.lastValueStream.listen((value) {
              if (mounted) {
                String networksString = utf8.decode(value);
                setState(() {
                  networks = networksString
                      .split('\n')
                      .where((s) => s.isNotEmpty)
                      .toList();
                  if (kDebugMode) {
                    print("Received networks: $networks");
                  } // Debugging log
                  isScanning = false;
                });
              }
            });
          } else if (characteristic.uuid.toString() ==
              Constants.userCharacteristicUUID) {
            userDetailsCharacteristic = characteristic;
          } else if (characteristic.uuid.toString() ==
              Constants.wifiCharacteristicUUID) {
            wifiCredentialsCharacteristic = characteristic;
          }
        }
      }
    }
    Navigation.close();
    showBottomSheet(isFirst);
  }

  Future<void> sendDeviceDetails(
      String name, String location, String contact) async {
    String userDetails = "$name,$location,$contact";
    await userDetailsCharacteristic!.write(userDetails.codeUnits);
    if (!isFirst) return;
    isFirst = false;
    Navigation.close();
    showBottomSheet(isFirst);
  }

  Future<void> sendWiFiCredentials(String ssid, String password) async {
    try {
      wifiCredentialsCharacteristic?.lastValueStream.drain();
      await wifiCredentialsCharacteristic!.setNotifyValue(true);
      String wifiCredentials = "$ssid,$password";
      await wifiCredentialsCharacteristic!.write(wifiCredentials.codeUnits);

      wifiCredentialsCharacteristic!.onValueReceived.listen((value) async {
        String result = String.fromCharCodes(value);
        if (result == "success" && result != initialResult) {
          initialResult = "success";
          await onWifiConnected(
              remoteId,
              idController.text.trim(),
              locationController.text.trim(),
              FirebaseAuth.instance.currentUser!.uid);
          await widget.device.disconnect().whenComplete(() {
            Navigation.close();
            Navigation().messenger(
              title: "Success",
              color: CupertinoColors.systemGreen,
              icon: CupertinoIcons.check_mark_circled_solid,
              description: ' Connected to device',
            );
            Navigation.skipTo(Navigation.home);
          });
        } else if (result == "failure" && result != initialResult) {
          initialResult = "failure";
          Navigation.close();
          if (mounted) {
            setState(() {
              isConnecting = !isConnecting;
            });
          }
          _showAlert();
        }
      });
    } on Exception {
      Navigation.close();
      Navigation().messenger(
        title: "Error",
        color: CupertinoColors.systemRed,
        icon: CupertinoIcons.clear_circled_solid,
        description: 'Failed to send Wi-Fi credentials',
      );
    }
  }

  _showAlert() {
    showDialog(
      context: Navigation.navigatorKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Connection Failed",
            style:
                Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 17),
          ),
          content: Text(
            "Please re-enter the Wi-Fi password",
            style: Theme.of(context).textTheme.labelLarge,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigation.close();
                showBottomSheet(isFirst);
                initialResult = "";
              },
              child: const Text("Retry"),
            ),
          ],
        );
      },
    );
  }

  void showBottomSheet(bool isFirstSheet) {
    showModalBottomSheet(
      context: Navigation.navigatorKey.currentState!.context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: Dimensions.contentPadding,
              right: Dimensions.contentPadding,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: isFirstSheet
                ? deviceDetailsSheet(setModalState)
                : wifiModalSheet(setModalState, isConnecting),
          );
        });
      },
    );
  }

  Widget deviceDetailsSheet(StateSetter setModalState) {
    final tStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey);
    return Form(
      key: _deviceDetailsFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.device.platformName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          CTextField(
            controller: idController,
            labelText: 'Device Name',
            textInputType: TextInputType.text,
            validator: (val) => validateText(val),
            labelStyle: tStyle,
          ),
          CTextField(
            controller: locationController,
            labelText: 'Device Location',
            textInputType: TextInputType.text,
            validator: (val) => validateText(val),
            labelStyle: tStyle,
          ),
          const SizedBox(height: Dimensions.contentPadding),
          ContactWidget(
            phoneController: phoneNumberController,
            onInputChange: (val) {
              phoneNumber = val ?? "";
            },
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: Dimensions.contentPadding),
            child: CElevatedButton(
              action: () async {
                if (_deviceDetailsFormKey.currentState!.validate()) {
                  await sendDeviceDetails(
                    idController.text,
                    locationController.text,
                    phoneNumberController.text,
                  );
                  setModalState(() {
                    isFirst = false;
                  });
                }
              },
              title: "Send",
            ),
          ),
        ],
      ),
    );
  }

  bool isVisible = false;

  Widget wifiModalSheet(StateSetter setModalState, [bool isConnect = false]) {
    return Form(
      key: _wifiCredentialsFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (!isScanning && networks.isNotEmpty)
            DropdownButton<String>(
              dropdownColor: Theme.of(context).colorScheme.tertiary,
              menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
              isExpanded: true,
              borderRadius: BorderRadius.circular(10),
              value: ssid.isNotEmpty ? ssid : null,
              onChanged: (String? newValue) {
                setModalState(() {
                  ssid = newValue!;
                  passwordController.clear();
                });
              },
              items: networks.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.contentPadding),
                child: Text(
                  networks.isEmpty ? "No networks available" : "Select Network",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              style: Theme.of(context).textTheme.labelLarge,
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.contentPadding),
            ),
          CTextField(
            controller: passwordController,
            labelText: 'Password',
            textInputType: TextInputType.text,
            validator: (val) => validateText(val),
            enabled: networks.isNotEmpty,
            isPassword: isVisible,
            action: () {
              setModalState(() {
                isVisible = !isVisible;
              });
            },
            icon: !isVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            onSubmitted: networks.isNotEmpty
                ? (o) => connectWifi(setModalState)
                : (o) {},
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: Dimensions.contentPadding),
            child: CElevatedButton(
              change: isConnect,
              action: networks.isNotEmpty
                  ? () => connectWifi(setModalState)
                  : () {}, // Disable button if no networks
              title: "Connect",
              widget: const CircularProgressIndicator.adaptive(
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  connectWifi(StateSetter setModalState) async {
    if (_wifiCredentialsFormKey.currentState!.validate()) {
      setModalState(() => isConnecting = !isConnecting);
      await sendWiFiCredentials(ssid, passwordController.text);
    }
  }

  Future<void> onWifiConnected(
      String remoteId, String name, String location, String userId) async {
    final deviceInfo = DeviceInfo(
      id: remoteId,
      name: name,
      location: location,
    );

    await FirestoreMethods().uploadDeviceInfo(deviceInfo, userId);
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    locationController.dispose();
    idController.dispose();
    passwordController.dispose();
    wifiCredentialsCharacteristic?.lastValueStream.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200]!.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(22)),
      ),
      child: ListTile(
        leading: Icon(
          !widget.device.platformName.contains(Constants.scanName)
              ? Icons.do_not_disturb_alt
              : Icons.gas_meter,
        ),
        title: Text(
          widget.device.platformName.isEmpty
              ? 'Unknown Device'
              : widget.device.platformName,
          style: Theme.of(context).textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${widget.rssi} dBm'),
        subtitleTextStyle: DeviceTile._computeStyle(widget.rssi),
        trailing: TextButton(
          onPressed: widget.device.platformName.contains(Constants.scanName)
              ? () async {
                  if (isCurrentlyConnected) {
                    showBottomSheet(isFirst);
                  } else {
                    await _connectToDevice();
                  }
                }
              : null,
          child: Text(
            !widget.device.platformName.contains(Constants.scanName)
                ? 'Not Connectable'
                : 'Connect',
            style: TextStyle(
              color: !widget.device.platformName.contains(Constants.scanName)
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGreen,
              fontSize: !widget.device.platformName.contains(Constants.scanName)
                  ? 12
                  : 16,
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:see_gas_app/common_widgets/c_text_field.dart';
// import 'package:see_gas_app/utils/dimensions.dart';
// import 'package:see_gas_app/utils/extensions.dart';
//
// import '../../../utils/constants.dart';
// import '../../../utils/navigation.dart';
// import '../../../common_widgets/c_elevated_button.dart';
// import '../../../common_widgets/contact_widget.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// // Define the state provider
// final deviceTileProvider =
//     StateNotifierProvider<DeviceTileNotifier, DeviceTileState>(
//   (ref) => DeviceTileNotifier(),
// );
//
String? validateText(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter some text';
  }
  return null;
}
//
// // Define the state class
// class DeviceTileState {
//   final bool isFirst;
//   final bool isScanning;
//   final bool isCurrentlyConnected;
//   final bool isConnecting;
//   final String initialResult;
//   final List<String> networks;
//   final String ssid;
//
//   DeviceTileState({
//     this.isFirst = true,
//     this.isScanning = false,
//     this.isCurrentlyConnected = false,
//     this.isConnecting = false,
//     this.initialResult = "",
//     this.networks = const [],
//     this.ssid = "",
//   });
//
//   DeviceTileState copyWith({
//     bool? isFirst,
//     bool? isScanning,
//     bool? isCurrentlyConnected,
//     bool? isConnecting,
//     String? initialResult,
//     List<String>? networks,
//     String? ssid,
//   }) {
//     return DeviceTileState(
//       isFirst: isFirst ?? this.isFirst,
//       isScanning: isScanning ?? this.isScanning,
//       isCurrentlyConnected: isCurrentlyConnected ?? this.isCurrentlyConnected,
//       isConnecting: isConnecting ?? this.isConnecting,
//       initialResult: initialResult ?? this.initialResult,
//       networks: networks ?? this.networks,
//       ssid: ssid ?? this.ssid,
//     );
//   }
// }
//
// // Define the notifier class
// class DeviceTileNotifier extends StateNotifier<DeviceTileState> {
//   DeviceTileNotifier() : super(DeviceTileState());
//
//   void setIsFirst(bool value) {
//     state = state.copyWith(isFirst: value);
//     print('ss');
//   }
//
//   void setIsScanning(bool value) {
//     state = state.copyWith(isScanning: value);
//   }
//
//   void setIsCurrentlyConnected(bool value) {
//     state = state.copyWith(isCurrentlyConnected: value);
//   }
//
//   void setIsConnecting(bool value) {
//     state = state.copyWith(isConnecting: value);
//   }
//
//   void setNetworks(List<String> networks) {
//     state = state.copyWith(networks: networks);
//   }
//
//   void setSsid(String ssid) {
//     state = state.copyWith(ssid: ssid);
//   }
// }
//
// class DeviceTile extends ConsumerWidget {
//   final BluetoothDevice device;
//   final int rssi;
//
//   const DeviceTile({
//     super.key,
//     required this.device,
//     required this.rssi,
//   });
//
//   static TextStyle _computeStyle(int rssi) {
//     final Map<int, Color> rssiRanges = {
//       -35: Colors.greenAccent[700]!,
//       -45: Colors.lightGreen,
//       -55: Colors.lime[600]!,
//       -65: Colors.amber,
//       -75: Colors.deepOrangeAccent,
//       -85: Colors.redAccent,
//     };
//
//     for (var range in rssiRanges.entries) {
//       if (rssi >= range.key) {
//         return TextStyle(color: range.value.withOpacity(0.8));
//       }
//     }
//     return TextStyle(color: Colors.redAccent.withOpacity(0.8));
//   }
//
//   static final _deviceDetailsFormKey = GlobalKey<FormState>();
//   static final _wifiCredentialsFormKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final deviceTileState = ref.watch(deviceTileProvider);
//
//     return Container(
//       margin: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.grey[200]!.withOpacity(0.8),
//         borderRadius: const BorderRadius.all(Radius.circular(22)),
//       ),
//       child: ListTile(
//         leading: Icon(
//           !device.platformName.contains(Constants.scanName)
//               ? Icons.do_not_disturb_alt
//               : Icons.gas_meter,
//         ),
//         title: Text(
//           device.platformName.isEmpty ? 'Unknown Device' : device.platformName,
//           style: Theme.of(context).textTheme.labelLarge,
//           overflow: TextOverflow.ellipsis,
//         ),
//         subtitle: Text('${rssi} dBm'),
//         subtitleTextStyle: _computeStyle(rssi),
//         trailing: TextButton(
//           onPressed: device.platformName.contains(Constants.scanName)
//               ? () async {
//                   if (deviceTileState.isCurrentlyConnected) {
//                     showBottomSheet(context, ref, deviceTileState.isFirst);
//                   } else {
//                     await _connectToDevice(ref, context);
//                   }
//                 }
//               : null,
//           child: Text(
//             !device.platformName.contains(Constants.scanName)
//                 ? 'Not Connectable'
//                 : 'Connect',
//             style: TextStyle(
//               color: !device.platformName.contains(Constants.scanName)
//                   ? CupertinoColors.systemRed
//                   : CupertinoColors.systemGreen,
//               fontSize:
//                   !device.platformName.contains(Constants.scanName) ? 12 : 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _connectToDevice(WidgetRef ref, BuildContext context) async {
//     bool isConnected = false;
//     Navigation().loading();
//     try {
//       await device.connect(timeout: const Duration(seconds: 20));
//       isConnected = true;
//       ref.read(deviceTileProvider.notifier).setIsCurrentlyConnected(true);
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
//       await _discoverServices(ref, context);
//     }
//   }
//
//   Future<void> _discoverServices(WidgetRef ref, BuildContext context) async {
//     await device.requestMtu(512);
//     List<BluetoothService> services = await device.discoverServices();
//
//     for (var service in services) {
//       if (service.uuid.toString() == Constants.serviceUUID) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.uuid.toString() ==
//               Constants.networkCharacteristicUUID) {
//             ref.read(deviceTileProvider.notifier).setIsScanning(true);
//             await characteristic.setNotifyValue(true);
//             characteristic.value.listen((value) {
//               String networksString = utf8.decode(value);
//               List<String> networks = networksString
//                   .split('\n')
//                   .where((s) => s.isNotEmpty)
//                   .toList();
//               ref.read(deviceTileProvider.notifier).setNetworks(networks);
//               ref.read(deviceTileProvider.notifier).setIsScanning(false);
//             });
//           }
//         }
//       }
//     }
//     Navigation.close();
//     showBottomSheet(context, ref, ref.read(deviceTileProvider).isFirst);
//   }
//
//   void showBottomSheet(BuildContext context, WidgetRef ref, bool isFirstSheet) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       enableDrag: true,
//       showDragHandle: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 left: 16.0,
//                 right: 16.0,
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: isFirstSheet
//                   ? deviceDetailsSheet(context, ref, setModalState)
//                   : wifiModalSheet(ref, setModalState),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget deviceDetailsSheet(
//       BuildContext context, WidgetRef ref, StateSetter setModalState) {
//     final tStyle =
//         Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey);
//     return Form(
//       key: _deviceDetailsFormKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             device.platformName,
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           CTextField(
//             // controller: idController,
//             labelText: 'Device Name',
//             textInputType: TextInputType.text,
//             validator: (val) => validateText(val),
//             labelStyle: tStyle,
//           ),
//           CTextField(
//             // controller: locationController,
//             labelText: 'Device Location',
//             textInputType: TextInputType.text,
//             validator: (val) => validateText(val),
//             labelStyle: tStyle,
//             basePadding: Dimensions.contentPadding,
//           ),
//           ContactWidget(
//             phoneController: TextEditingController(),
//           ),
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(vertical: Dimensions.contentPadding),
//             child: CElevatedButton(
//               action: () {
//                 // if (_deviceDetailsFormKey.currentState!.validate()) {
//                 //   sendDeviceDetails(
//                 //     idController.text,
//                 //     locationController.text,
//                 //     phoneNumberController.text,
//                 //   );
//                 //   setModalState(() {
//                 //     isFirst = false;
//                 //   });
//                 // }
//                 ref.read(deviceTileProvider.notifier).setIsFirst(false);
//
//               },
//               title: "Send",
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget wifiModalSheet(WidgetRef ref, StateSetter setModalState) {
//     final deviceTileState = ref.watch(deviceTileProvider);
//     return Form(
//       key: _wifiCredentialsFormKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (!deviceTileState.isScanning &&
//               deviceTileState.networks.isNotEmpty)
//             DropdownButton<String>(
//               value:
//                   deviceTileState.ssid.isNotEmpty ? deviceTileState.ssid : null,
//               onChanged: (String? newValue) {
//                 setModalState(() {
//                   ref.read(deviceTileProvider.notifier).setSsid(newValue!);
//                 });
//               },
//               items: deviceTileState.networks
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           if (deviceTileState.isScanning) CircularProgressIndicator(),
//           CElevatedButton(
//             action: () {
//               // Implement sending Wi-Fi credentials
//             },
//             title: "Send Wi-Fi Credentials",
//           ),
//         ],
//       ),
//     );
//   }
// }
