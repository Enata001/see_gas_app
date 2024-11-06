import 'package:shared_preferences/shared_preferences.dart';
import 'package:see_gas_app/models/user_model.dart';
import 'dart:developer' as devtools;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:see_gas_app/utils/navigation.dart';
import 'constants.dart';
import 'dimensions.dart';

extension Log on Object {
  void log() => devtools.log(toString());
}

extension Alerts on Navigation {
  void loading() async {
    showAdaptiveDialog(
        barrierDismissible: false,
        context: Navigation.navigatorKey.currentState!.context,
        builder: (_) {
          return LoadingAnimationWidget.flickr(
              leftDotColor: Constants.mainColor,
              rightDotColor: Constants.secondaryColor,
              size: 40);
        });
  }

  messenger(
      {required String title,
      required String description,
      required IconData icon,
      required Color color}) {
    return ScaffoldMessenger.of(Navigation.navigatorKey.currentState!.context)
        .showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: color,
              size: 50,
            ),
            const SizedBox(
              width: Dimensions.scaffoldSpacing,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      color: Theme.of(
                              Navigation.navigatorKey.currentState!.context)
                          .colorScheme
                          .scrim,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: Dimensions.scaffoldTitle,
                      ),
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                      color: Theme.of(
                              Navigation.navigatorKey.currentState!.context)
                          .colorScheme
                          .scrim,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Dimensions.scaffoldSubText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(Navigation.navigatorKey.currentState!.context)
            .colorScheme
            .tertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

extension UserPreferences on SharedPreferences {
  static const String _userDataKey = 'userData';
  static const String _appTheme = 'appTheme';

  Future<bool> saveUser(UserModel user) {
    return setString(_userDataKey, user.toString());
  }

  Future<bool> saveTheme(bool isDarkTheme) {
    return setBool(_appTheme, isDarkTheme);
  }

  bool getTheme() {
    return getBool(_appTheme) ?? false;
  }

  UserModel? getUser() {
    final userData = getString(_userDataKey);
    if (userData == null) {
      return null;
    }
    return UserModel.fromString(userData);
  }

  Future<bool> clearUser() {
    return remove(_userDataKey);
  }
}
