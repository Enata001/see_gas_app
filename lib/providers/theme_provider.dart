import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/themes.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences pref;

  ThemeProvider(this.pref);

  late ThemeData _theme;

  ThemeData get theme {
    _theme = pref.getTheme() ? AppTheme.darkTheme : AppTheme.lightTheme;
    return _theme;
  }

  set newTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  void changeTheme() async {
    if (_theme == AppTheme.lightTheme) {
      await pref.saveTheme(true);
      newTheme = AppTheme.darkTheme;
    } else {
      await pref.saveTheme(false);
      newTheme = AppTheme.lightTheme;
    }
  }
}

final themeProvider =
    ChangeNotifierProvider<ThemeProvider>((ref) {
      throw UnimplementedError();
    },);
