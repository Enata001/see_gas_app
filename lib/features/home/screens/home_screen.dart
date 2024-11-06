import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/common_widgets/c_elevated_button.dart';
import 'package:see_gas_app/features/home/widgets/home_appbar.dart';
import 'package:see_gas_app/services/firebase_firestore_methods.dart';
import 'package:see_gas_app/utils/constants.dart';
import 'package:see_gas_app/utils/dimensions.dart';
import 'package:shimmer/shimmer.dart';

import '../../../models/device_info_model.dart';

import '../../../utils/navigation.dart';
import '../widgets/device.dart';

final devicesListProvider = StreamProvider.family<List<DeviceInfo>, String>(
  (ref, arg) {
    return FirestoreMethods().getDevices(arg);
  },
);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesList =
        ref.watch(devicesListProvider(FirebaseAuth.instance.currentUser!.uid));
    return Scaffold(
      appBar: HomeAppbar(),
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.contentPadding,
        ),
        // height: double.infinity,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Constants.logoPath,
            ),
            opacity: 0.10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Divider(),
            Text('All Devices',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                    )),
            // const SizedBox(height: Dimensions.contentPadding * 2),
            const Divider(),

            devicesList.when(
                data: (data) {
                  if (data.isEmpty) {
                    return noDataOrError(context,
                        message: 'No Available Devices',
                        icon: Icons.hourglass_empty_outlined,
                        rotate: true);
                  }
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return DeviceWidget(device: data[index],);
                      },
                    ),
                  );
                },
                loading: () => buildShimmerEffect(),
                error: (error, stack) => noDataOrError(context,
                    message: 'Failed to Load Data',
                    icon: Icons.wifi_tethering_error_rounded_outlined))
          ],
        ),
      ),
      floatingActionButton: ConstrainedBox(
          constraints: BoxConstraints.tight(const Size(160, 45)),
          child: CElevatedButton(
            action: () => Navigation.goTo(Navigation.addDevice),
            title: "Add a Device",
          )),
    );
  }

  Widget buildShimmerEffect() {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget noDataOrError(BuildContext context,
      {required String message,
      required IconData icon,
      Widget? onNext,
      bool rotate = false}) {
    return Expanded(
      child: Center(
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
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
var devices = [
  const DeviceInfo(
    id: "1",
    name: 'System A',
    location: 'Phree\'s Kitchen-Santorini',
  ),
  const DeviceInfo(
    id: "2",
    name: 'System B',
    location: 'Phree\'s Los Angeles',
  ),
];
