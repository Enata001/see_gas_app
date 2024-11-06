import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/utils/extensions.dart';
import '../../../providers/auth_state_notifier.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/navigation.dart';
import '../entities/auth_state.dart';
import '../widgets/sign_in.dart';
import '../widgets/sign_up.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const  EdgeInsets.symmetric(
              horizontal: Dimensions.contentPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.contentPadding/5,
                      bottom: Dimensions.logoBottomPadding,
                    ),
                    child: Image.asset(
                      Constants.logoPath,
                      scale: Dimensions.logoScaleSize,
                    )),
                Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final offAnimation = Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return SlideTransition(
                          position: offAnimation,
                          child: child,
                        );
                      },
                      child: isSignIn ? const SignIn() : const SignUp(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSignIn
                              ? "Don't have an account?"
                              : 'Already have an account?',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isSignIn = !isSignIn;
                            });
                          },
                          child: Text(
                            isSignIn ? "Sign Up" : 'Sign In',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
