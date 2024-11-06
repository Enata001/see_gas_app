import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:see_gas_app/features/authentication/screens/email_verification_screen.dart';
import 'package:see_gas_app/providers/auth_state_notifier.dart';
import 'package:see_gas_app/providers/user_notifier.dart';
import 'package:see_gas_app/utils/constants.dart';
import 'package:see_gas_app/utils/navigation.dart';
import 'features/authentication/screens/auth_screen.dart';
import 'features/home/screens/home_screen.dart';

class EntryPage extends ConsumerWidget {
  const EntryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return FutureBuilder(
      future: initializeDependencies(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {

          return const AuthCheck();
        }

        // Splash Screen
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Constants.logoPath,
                  scale: 2.5,
                  filterQuality: FilterQuality.high,
                ),

                // const SizedBox.expand(),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Constants.secondaryColor,
                    size: 50,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> initializeDependencies(WidgetRef ref) async {
    await ref.read(userProvider.notifier).loadUserFromCache();
    bool finished = await Future.delayed(
        const Duration(
          seconds: 2,
        ), () {
      bool isDone = true;

      return isDone;
    });
    return finished;
  }
}

class AuthCheck extends ConsumerWidget {
  const AuthCheck({super.key});

  final user = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVerified = ref.read(emailVerifiedProvider);
    if (ref.read(authStateNotifierProvider).userId != null && isVerified) {
      return HomeScreen();
    } else if (ref.read(authStateNotifierProvider).userId != null &&
        !isVerified) {
      return EmailVerificationScreen();
    } else {
      return AuthScreen();
    }
  }
}
