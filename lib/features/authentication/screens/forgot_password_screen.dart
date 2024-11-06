import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/common_widgets/c_appbar.dart';
import 'package:see_gas_app/utils/extensions.dart';
import '../../../providers/auth_state_notifier.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';
import '../../../common_widgets/c_elevated_button.dart';
import '../../../common_widgets/c_text_field.dart';
import '../../../utils/navigation.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late TextEditingController emailController;
  bool canResend = true;
  int cooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CAppBar(title: 'Forgot Password'),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.05,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.contentPadding,
                  ),
                  child: Image.asset(
                    Constants.mailPath,
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  canResend
                      ? "Enter your email and we will send you a password reset link"
                      : "You can resend in ${cooldown ~/ 60}:${(cooldown % 60).toString().padLeft(2, '0')}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                CTextField(
                  labelText: 'Email',
                  textInputType: TextInputType.text,
                  controller: emailController,
                  validator: (val) => validateText(val),
                ),
                const SizedBox(
                  height: Dimensions.contentPadding,
                ),
                CElevatedButton(
                  title: 'Reset',
                  change: canResend == false,
                  action: () async {
                    if(_formKey.currentState!.validate()) {
                      await resetPassword();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    await ref.read(authStateNotifierProvider.notifier).sendResetPasswordMail(
        email: email,
        onSent: () {
          Navigation().messenger(
            title: "Mail sent!",
            description: 'Verification mail has been sent to you.',
            icon: Icons.done_outline_rounded,
            color: Colors.blueGrey,
          );

          setState(() {
            canResend = false; // Disable resend button
          });
          startCooldown();
        });
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
            canResend = true;
            cooldown = 60;
          });
        }
        t.cancel();
      }
    });
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }
}
