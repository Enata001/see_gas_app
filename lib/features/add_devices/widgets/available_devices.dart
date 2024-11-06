import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_tile.dart';

class AvailableDevices extends StatelessWidget {
  final List<ScanResult> scanResults;
  const AvailableDevices({super.key, required this.scanResults});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scanResults.length,
      itemBuilder: (context, index) {
        int rssi = scanResults[index].rssi;
        BluetoothDevice device =
            scanResults[index].device;
        return
          DeviceTile(device: device, rssi: rssi);
      },
    );
  }
}
