import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/common_widgets/contact_widget.dart';
import 'package:see_gas_app/features/authentication/widgets/social_button.dart';
import 'package:see_gas_app/utils/extensions.dart';
import '../../../providers/auth_state_notifier.dart';
import '../../../utils/constants.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/navigation.dart';
import '../../../common_widgets/c_elevated_button.dart';
import '../../../common_widgets/c_text_field.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late FocusNode firstFocus;
  late FocusNode secondFocus;
  late FocusNode thirdFocus;
  late FocusNode fourthFocus;
  late FocusNode fifthFocus;
  String? formattedNumber = "";

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    usernameController = TextEditingController();
    phoneController = TextEditingController();
    firstFocus = FocusNode();
    secondFocus = FocusNode();
    thirdFocus = FocusNode();
    fourthFocus = FocusNode();
    fifthFocus = FocusNode();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    firstFocus.dispose();
    secondFocus.dispose();
    thirdFocus.dispose();
    fourthFocus.dispose();
    super.dispose();
  }

  bool isNotVisible = true;
  bool isNotConfirmPasswordVisible = true;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Let's get Started",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              CTextField(
                labelText: 'Email',
                textInputType: TextInputType.text,
                controller: emailController,
                validator: validateText,
                focusNode: firstFocus,
                inputAction: TextInputAction.next,
                onSubmitted: (e) async {
                  firstFocus.nextFocus();
                },
              ),
              CTextField(
                labelText: 'Username',
                textInputType: TextInputType.text,
                controller: usernameController,
                validator: validateText,
                focusNode: secondFocus,
                inputAction: TextInputAction.next,
                onSubmitted: (e) async {
                  secondFocus.nextFocus();
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
                inputAction: TextInputAction.next,
                action: () {
                  isNotVisible = !isNotVisible;
                  setState(() {});
                },
                validator: validateText,
                focusNode: thirdFocus,
                onSubmitted: (e) async {
                  thirdFocus.nextFocus();
                },
              ),
              CTextField(
                labelText: 'Confirm Password',
                textInputType: TextInputType.text,
                isPassword: isNotConfirmPasswordVisible,
                controller: confirmPasswordController,
                icon: !isNotConfirmPasswordVisible
                    ? CupertinoIcons.eye
                    : CupertinoIcons.eye_slash,
                inputAction: TextInputAction.go,
                action: () {
                  isNotConfirmPasswordVisible = !isNotConfirmPasswordVisible;
                  setState(() {});
                },
                validator: validateText,
                focusNode: fourthFocus,
                onSubmitted: (e) async {
                  fourthFocus.nextFocus();
                },
              ),
              const SizedBox(
                height: Dimensions.contentPadding,
              ),
              ContactWidget(
                phoneController: phoneController,
                node: fifthFocus,
                validator: validateText,
                onInputChange: (number) {
                  formattedNumber = number;
                  print(formattedNumber);
                },
              ),
              const SizedBox(
                height: Dimensions.contentPadding,
              ),
              CElevatedButton(
                title: 'Sign Up',
                action: () async => signUp(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Dimensions.contentPadding),
          child: Text(
            'Or',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SocialButton(
            title: 'Continue with Google',
            asset: Constants.googleLogoPath,
            action: () async {
              await ref
                  .read(authStateNotifierProvider.notifier)
                  .signInWithGoogle(onNew: () async {
                final detailsFormKey = GlobalKey<FormState>();
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
                              node: fifthFocus,
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
                              padding: const EdgeInsets.only(
                                  bottom: Dimensions.contentPadding),
                              child: CElevatedButton(
                                title: 'Complete',
                                action: () {
                                  if (detailsFormKey.currentState!.validate()) {
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

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authStateNotifierProvider.notifier).signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          username: usernameController.text.trim(),
          phoneContact: formattedNumber ?? "");
    }
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }


}
