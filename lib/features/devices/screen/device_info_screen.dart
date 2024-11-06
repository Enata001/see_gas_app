import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/common_widgets/c_elevated_button.dart';
import 'package:see_gas_app/common_widgets/c_appbar.dart';
import 'package:see_gas_app/models/device_info_model.dart';
import 'package:see_gas_app/models/readings_model.dart';
import 'package:see_gas_app/services/firebase_database_methods.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common_widgets/c_dialog.dart';
import '../../../providers/auth_state_notifier.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';

final sensorReadingsProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, deviceId) {
  return FirebaseDatabaseMethods.getSensorReadings(deviceId);
});

class DeviceInfoScreen extends ConsumerWidget {
  final DeviceInfo info;
  final Color color;

  const DeviceInfoScreen({super.key, required this.info, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final double lpgReading1 = 2000; // Replace with real data
    // final double lpgReading2 = 1800; // Replace with real data
    // final double lpgReading3 = 1500; // Replace with real data
    // final double smokeReading = 210; // Replace with real data
    // final double temperatureReading = 23.4; // Replace with real data
    // final double humidityReading = 27; // Replace with real data

    final sensorReadingsStream = ref.watch(sensorReadingsProvider(info.id));

    return Scaffold(
      appBar: CAppBar(title: info.name),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.contentPadding,
            right: Dimensions.contentPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: Dimensions.contentPadding),
              Hero(
                tag: info.id,
                child: Icon(
                  Icons.gas_meter_rounded,
                  color: color,
                  size: Dimensions.iconRadius,
                ),
              ),
              const SizedBox(height: Dimensions.contentPadding * 2),
              Text(info.location,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 22)),
              const SizedBox(height: Dimensions.contentPadding * 2),
              sensorReadingsStream.when(
                data: (data) {
                  print(info.id);
                  print(data.toString());
                  if (data.isEmpty) {
                    return noDataOrError(context,
                        message: 'No Data Available',
                        icon: Icons.hourglass_empty_outlined,
                        rotate: true);
                  }
                  final readings = DeviceReadings.fromMap(data);
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Status: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 19),
                          ),
                          const SizedBox(
                            width: Dimensions.contentPadding,
                          ),
                          Chip(

                            label: Text(
                              readings.danger ? 'danger' : 'OK',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 19),
                            ),
                            color: WidgetStateProperty.all(
                                readings.danger ? Colors.red : Colors.green),

                            shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: Dimensions.contentPadding / 2,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurStyle: BlurStyle.outer,
                              blurRadius: 1.5,
                            ),
                          ],
                        ),
                        child: GridView.count(
                          physics: ClampingScrollPhysics(),
                          crossAxisCount: 2,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          childAspectRatio: 1.3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 5,
                          children: [
                            buildReadingTile(context,
                                label: 'LPG 1',
                                value: readings.lpgOne,
                                icon: CupertinoIcons.wind),
                            buildReadingTile(context,
                                label: 'LPG 2',
                                value: readings.lpgTwo,
                                icon: CupertinoIcons.wind),
                            buildReadingTile(context,
                                label: 'LPG 3',
                                value: readings.lpgThree,
                                icon: CupertinoIcons.wind),
                            buildReadingTile(context,
                                label: 'Smoke',
                                value: readings.smoke.ceilToDouble(),
                                icon: Icons.smoke_free),
                            buildReadingTile(context,
                                label: 'Temperature',
                                value: readings.temp.ceilToDouble(),
                                icon: Icons.thermostat,
                                unit: '°C'),
                            buildReadingTile(context,
                                label: 'Humidity',
                                value: readings.humidity.ceilToDouble(),
                                icon: Icons.water_drop,
                                unit: '%'),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.contentPadding),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.contentPadding,
                            vertical: Dimensions.contentPadding * 0.4),
                        child: CElevatedButton(
                          action: () {
                            customDialog(
                                context: context,
                                title: 'Sign Out',
                                message: 'Do you want to sign out?',
                                callback: () async {
                                  await ref
                                      .read(authStateNotifierProvider.notifier)
                                      .removeDevice(info.id);
                                });
                          },
                          title: 'Remove Device',
                          color: color,
                        ),
                      ),
                    ],
                  );
                },
                error: (error, stackTrace) => noDataOrError(context,
                    message: 'Failed to load details',
                    icon: Icons.wifi_tethering_error_rounded_outlined),
                loading: () => buildShimmerEffect(context),
              ),
            ],
          ),
        ),
      ),
      // persistentFooterButtons: [],
    );
  }

  Widget buildShimmerEffect(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildReadingTile(BuildContext context,
      {required String label,
      required double value,
      required IconData icon,
      String? unit}) {
    return Card(
      borderOnForeground: true,
      color: Theme.of(context).canvasColor,
      shadowColor: color,
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                  )),
          Text('${value.toString()} ${unit ?? 'p.p.m'}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                  )),
        ],
      ),
    );
  }

  Widget noDataOrError(BuildContext context,
      {required String message,
      required IconData icon,
      Widget? onNext,
      bool rotate = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: rotate ? -81.2 : 0,
            child: Icon(
              icon,
              color: Color.lerp(
                  Constants.mainColor, Constants.secondaryColor, 0.5),
              size: Dimensions.iconRadius * 2,
            ),
          ),
          Text(
            message,
            style:
                Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
