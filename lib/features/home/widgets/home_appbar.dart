import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/common_widgets/c_dialog.dart';
import 'package:see_gas_app/providers/auth_state_notifier.dart';
import 'package:see_gas_app/providers/user_notifier.dart';

import '../../../providers/theme_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/navigation.dart';
import '../../../utils/themes.dart';

class HomeAppbar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userProvider);
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi,', style: Theme.of(context).textTheme.labelLarge),
          Text(
            userInfo?.username ?? 'User',
            style:
                Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 20),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      leadingWidth: 55,
      leading: Padding(
        padding: const EdgeInsets.only(left: Dimensions.contentPadding),
        child: GestureDetector(
          onTap: () => Navigation.goTo(Navigation.account, userInfo),
          child: CircleAvatar(
            backgroundImage:
                NetworkImage(userInfo?.photoLink ?? Constants.profileLink),
          ),
        ),
      ),
      actions: [
        Consumer(builder: (context, ref, child) {
          final theme = ref.watch(themeProvider);
          final darkTheme = theme.theme == AppTheme.darkTheme;
          return IconButton(
            onPressed: () {
              theme.changeTheme();
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                !darkTheme ? Icons.nights_stay : Icons.wb_sunny,
                key: ValueKey<bool>(darkTheme),
                size: Dimensions.appBarIconSize,
              ),
            ),
          );
        }),
        IconButton(
          onPressed: () {
            customDialog(
                context: context,
                title: 'Sign Out',
                message: 'Do you want to sign out?',
                callback: () async {
                  await ref.read(authStateNotifierProvider.notifier).signOut();
                  Navigation.skipTo(Navigation.authPage);
                });
          },
          icon: const Icon(
            Icons.exit_to_app_outlined,
            size: Dimensions.appBarIconSize,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(Dimensions.appBarHeight);
}
