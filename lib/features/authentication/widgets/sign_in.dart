import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/features/authentication/widgets/social_button.dart';
import 'package:see_gas_app/providers/auth_state_notifier.dart';
import 'package:see_gas_app/utils/extensions.dart';
import '../../../common_widgets/contact_widget.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/navigation.dart';
import '../../../common_widgets/c_elevated_button.dart';
import '../../../common_widgets/c_text_field.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late FocusNode firstFocus;
  late FocusNode secondFocus;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    firstFocus = FocusNode();
    secondFocus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    firstFocus.dispose();
    secondFocus.dispose();
  }

  bool isNotVisible = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateNotifierProvider);

    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Hello, welcome back!",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: Dimensions.contentPadding,
              ),
              Text(
                'Log in to continue',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              CTextField(
                labelText: 'Username',
                textInputType: TextInputType.text,
                controller: emailController,
                validator: (value) => validateText(value),
                focusNode: firstFocus,
                inputAction: TextInputAction.next,
                onSubmitted: (e) async {
                  firstFocus.nextFocus();
                },
              ),
              CTextField(
                labelText: 'Password',
                textInputType: TextInputType.text,
                isPassword: isNotVisible,
                controller: passwordController,
                icon: !isNotVisible
                    ? CupertinoIcons.eye
                    : CupertinoIcons.eye_slash,
                inputAction: TextInputAction.go,
                onSubmitted: (e) async => login(ref),
                action: () {
                  isNotVisible = !isNotVisible;
                  setState(() {});
                },
                validator: (value) => validateText(value),
                focusNode: secondFocus,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    "Button Pressed".log();
                    Navigation.goTo(Navigation.forgotPassword);
                  },
                  child: const Text(
                    "Forgot your password?",
                  ),
                ),
              ),
              const SizedBox(
                height: Dimensions.contentPadding,
              ),
              CElevatedButton(
                title: 'Sign In',
                action: () async => login(ref),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: Dimensions.contentPadding,
          ),
          child: Text(
            'Or ',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SocialButton(
            title: 'Continue with Google',
            asset: Constants.googleLogoPath,
            action: () async {
              await ref.read(authStateNotifierProvider.notifier).signInWithGoogle(onNew: () async {
                final detailsFormKey = GlobalKey<FormState>();
                final TextEditingController usernameController  =  TextEditingController();
                final TextEditingController phoneController  =  TextEditingController();
                String? formattedNumber ="";
                final List<String?> details = await showModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Form(
                        key: detailsFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CTextField(
                              labelText: 'Username',
                              textInputType: TextInputType.text,
                              controller: usernameController,
                              validator: validateText,
                              inputAction: TextInputAction.next,
                            ),
                            const SizedBox(
                              height: Dimensions.contentPadding,
                            ),
                            ContactWidget(
                              phoneController: phoneController,
                              validator: validateText,
                              onInputChange: (number) {
                                formattedNumber = number;
                                print(formattedNumber);
                              },
                            ),
                            const SizedBox(
                              height: Dimensions.contentPadding,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.contentPadding),
                              child: CElevatedButton(
                                title: 'Complete',
                                action: () {
                                  if (detailsFormKey.currentState!
                                      .validate()) {
                                    Navigation.close([
                                      usernameController.text.trim(),
                                      formattedNumber
                                    ]);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                return details;
              });
            }),
      ],
    );
  }

  void login(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      await ref
          .read(authStateNotifierProvider.notifier)
          .signInWithCredentials(email: email, password: password);
    }

  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }


}
