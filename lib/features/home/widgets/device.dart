import 'dart:math';

import 'package:flutter/material.dart';
import '../../../models/device_info_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/navigation.dart';

class DeviceWidget extends StatelessWidget {
  final DeviceInfo device;

  DeviceWidget({
    super.key,
    required this.device,
  });

  final Color color = colors[Random().nextInt(4)];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigation.goTo(
          Navigation.deviceInfo, {'info': device, 'color': color}),
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.devicePadding * 2),
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // color: Color.lerp(Colors.grey, CupertinoColors.systemMint, 0.2),
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 7,
              // offset: Offset(5, 5),
              blurStyle: BlurStyle.outer,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Hero(
              tag: device.id,
              child: const Icon(
                Icons.gas_meter,
                size: 50,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    device.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white, fontSize: 19),
                  ),
                  const SizedBox(
                    height: Dimensions.deviceLabelPadding,
                  ),
                  Text(
                    device.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

const colors = [
  Constants.mainColor,
  Colors.blueGrey,
  Colors.indigoAccent,
  Colors.blueAccent,
  Colors.blue,
  Colors.lightBlue,

  // Color.lerp(Colors.indigo, Colors.blueGrey, 0.5)
];
