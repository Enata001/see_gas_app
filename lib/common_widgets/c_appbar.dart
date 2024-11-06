import 'package:flutter/material.dart';
import 'package:see_gas_app/utils/dimensions.dart';

class CAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;

  const CAppBar({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 24,
            ),
      ),
      actions: trailing == null
          ? null
          : [
              SizedBox(child: trailing),
              const SizedBox(
                width: Dimensions.contentPadding,
              )
            ],
      // forceMaterialTransparency: true,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize =>
      const Size(double.infinity, Dimensions.appBarHeight);
}
