import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:see_gas_app/features/add_devices/widgets/ble_off.dart';
import '../widgets/scan_page.dart';

class AddDevicesScreen extends StatefulWidget {
  const AddDevicesScreen({super.key});

  @override
  State<AddDevicesScreen> createState() => _AddDevicesScreenState();
}

class _AddDevicesScreenState extends State<AddDevicesScreen> {
  late BluetoothAdapterState _bluetoothAdapterState;

  @override
  void initState() {
    _bluetoothAdapterState = BluetoothAdapterState.unknown;

    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _bluetoothAdapterState = state;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage = _bluetoothAdapterState == BluetoothAdapterState.on
        ? const ScanPage()
        : const BleOffPage();

    return currentPage;
  }
}
