import 'package:flutter/material.dart';

import '../../../utils/dimensions.dart';

class ScanTitleWidget extends StatelessWidget {
  const ScanTitleWidget({
    super.key,
    required this.isScanning,
  });

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return isScanning
        ? Padding(
      padding: const EdgeInsets.all(Dimensions.contentPadding),
      child: LinearProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
      ),
    )
        : const SizedBox.shrink();
  }
}