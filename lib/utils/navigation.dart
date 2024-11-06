import 'package:flutter/material.dart';
import 'package:see_gas_app/features/add_devices/screens/add_devices_screen.dart';
import 'package:see_gas_app/features/authentication/screens/auth_screen.dart';
import 'package:see_gas_app/features/authentication/screens/email_verification_screen.dart';
import 'package:see_gas_app/features/home/screens/home_screen.dart';
import 'package:see_gas_app/features/profile/screens/profile_screen.dart';
import 'package:see_gas_app/models/user_model.dart';

import '../entry_page.dart';
import '../features/authentication/screens/forgot_password_screen.dart';
import '../features/devices/screen/device_info_screen.dart';
import '../models/device_info_model.dart';

class Navigation {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const entry = "/";
  static const authPage = "auth_page";
  static const signOut = "sign_out";
  static const account = "profile";
  static const home = "home";
  static const addDevice = "add_device";
  static const forgotPassword = "forgot_password";
  static const deviceInfo = "device_info";
  static const verifyEmail = "verify_email";

  static goTo(String routeName, [dynamic args]) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: args);
  }

  static skipTo(String routeName, [dynamic args]) {
    return navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false, arguments: args);
  }

  static close([args]) {
    return navigatorKey.currentState?.pop(args);
  }

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case entry:
        return OpenRoute(widget: const EntryPage());
      case home:
        return OpenRoute(widget: HomeScreen());
      case authPage:
        return OpenRoute(widget: const AuthScreen());
      case forgotPassword:
        return OpenRoute(widget: const ForgotPasswordScreen());
      case addDevice:
        return OpenRoute(widget: const AddDevicesScreen());
      case account:
        return OpenRoute(
            widget: const ProfileScreen());
      case deviceInfo:
        final args = settings.arguments as Map<String, dynamic>;
        return OpenRoute(
          widget: DeviceInfoScreen(
            info: args['info'] as DeviceInfo,
            color: args['color'] as Color,
          ),
        );
      case verifyEmail:
        return OpenRoute(widget: EmailVerificationScreen());
      default:
        return OpenRoute(widget: ErrorScreen(settings: settings));
    }
  }
}

class OpenRoute extends PageRouteBuilder {
  final Widget widget;

  OpenRoute({required this.widget})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
}

class ErrorScreen extends StatelessWidget {
  final RouteSettings settings;

  const ErrorScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "${settings.name} page does not exist",
        ),
      ),
    );
  }
}
