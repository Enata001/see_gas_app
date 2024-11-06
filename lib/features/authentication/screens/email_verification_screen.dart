import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/utils/extensions.dart';
import '../../../common_widgets/c_elevated_button.dart';
import '../../../providers/auth_state_notifier.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/navigation.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool isVerified = false;
  bool canResendMail = false;
  Timer? timer;
  int cooldown = 300; // Cooldown period in seconds

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      isVerified = ref.read(emailVerifiedProvider);
      if (!isVerified) {
        sendVerificationMail();
        startTimer();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Email Verification',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.05,
          ),
          child: Center(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.contentPadding,
                  ),
                  child: Icon(
                    CupertinoIcons.mail_solid,
                    color: Constants.mainColor,
                    size: Dimensions.iconRadius,
                  ),
                ),
                Text(
                  "A verification link has been sent to your email address. Please verify from your inbox",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: Dimensions.contentPadding),
                // Displaying the countdown until the user can resend the verification mail
                Text(
                  "You can resend in ${cooldown ~/ 60}:${(cooldown % 60).toString().padLeft(2, '0')}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: Dimensions.contentPadding),
                const Spacer(),
                CElevatedButton(
                    title: 'Resend Verification Link',
                    change: canResendMail == false,
                    action: () async {
                      sendVerificationMail();
                    }),
                const SizedBox(height: Dimensions.contentPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 3), (t) async {
      await ref.read(authStateNotifierProvider.notifier).reloadUser();
      isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (isVerified) {
        timer?.cancel();
        Navigation().messenger(
          title: "Success",
          description: 'Email Verified',
          icon: CupertinoIcons.check_mark_circled_solid,
          color: CupertinoColors.systemGreen,
        );
        Navigation.skipTo(Navigation.home);
      }
    });
  }

  void sendVerificationMail() async {
    await ref.read(authStateNotifierProvider.notifier).sendVerificationMail(
      onSent: () {
        Navigation().messenger(
          title: "Mail sent!",
          description: 'Verification mail has been sent to you.',
          icon: Icons.done_outline_rounded,
          color: Colors.blueGrey,
        );
        setState(() {
          canResendMail = false; // Disable resend button
        });
        startCooldown(); // Start cooldown timer
      },
    );
  }

  void startCooldown() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel(); // Cancel the timer if not mounted
        return;
      }
      setState(() {
        cooldown--;
      });
      if (cooldown <= 0) {
        if (mounted) {
          setState(() {
            canResendMail = true;
            cooldown = 300;
          });
        }
        t.cancel();
      }
    });
  }
}
