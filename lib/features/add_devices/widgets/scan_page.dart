import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:see_gas_app/features/add_devices/widgets/available_devices.dart';
import 'package:see_gas_app/features/add_devices/widgets/scan_title.dart';

import '../../../common_widgets/c_appbar.dart';
import '../../../utils/dimensions.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late bool _isScanning;
  late List<ScanResult> _scanResults;

  @override
  void initState() {
    super.initState();
    _isScanning = false;
    _scanResults = [];
    _scanDevice();
  }

  @override
  void dispose() {
    _scanResults.clear();
    super.dispose();
  }

  Future _scanDevice() async {
    _scanResults.clear();

    FlutterBluePlus.scanResults.listen(
      (results) {
        if (mounted) setState(() => _scanResults = results);
      },
      onError: (e) {
        if (kDebugMode) {
          print('Error scan result subscription: $e');
        }
      },
    );

    FlutterBluePlus.isScanning.listen((state) {
      if (mounted) setState(() => _isScanning = state);
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error scan device method: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CAppBar(title: 'Devices'),
      body: Stack(
        children: [
          ScanTitleWidget(isScanning: _isScanning),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.contentPadding,
              vertical: Dimensions.contentPadding*2
            ),
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                AvailableDevices(scanResults: _scanResults),
                if (!_isScanning && _scanResults.isNotEmpty) ...[
                  TextButton(
                    onPressed: _scanDevice,
                    child: const Text('Scan Again'),
                  ),
                ]
              ],
            ),
          ),
          if (!_isScanning && _scanResults.isEmpty)
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.do_not_disturb,
                    size: Dimensions.iconRadius,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  Text(
                    'No Devices Found',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: _scanDevice,
                    child: const Text('Scan Again'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
