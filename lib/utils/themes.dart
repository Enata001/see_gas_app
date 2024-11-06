import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';
import 'dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(useMaterial3: true).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Constants.mainColor,
          overlayColor: WidgetStatePropertyAll(
            Constants.mainColor,
          ),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Constants.mainColor,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.aBeeZee(
            fontSize: 25,
            color: Colors.black,
          ),
          labelLarge: GoogleFonts.aBeeZee(
            fontSize: Dimensions.elevatedButtonFontSize,
            color: Colors.black,
          ),
          bodyLarge: GoogleFonts.aBeeZee(
            fontSize: Dimensions.elevatedButtonFontSize,
            color: Colors.black,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          modalBackgroundColor: Colors.white,
          // constraints: BoxConstraints.expand(height: 400)
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Constants.secondaryColor,
          primary: Colors.black54,
          secondary: Constants.mainColor,
          scrim: Colors.black.withOpacity(0.6),
          tertiary: Colors.white,
        ),
      );

  static ThemeData get darkTheme => ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xff000425),
        applyElevationOverlayColor: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Constants.mainColor,
          foregroundColor: Colors.white,
        ),
        canvasColor: const Color(0xff000425),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xff000425),
          modalBackgroundColor: Color(0xff000425),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.aBeeZee(
            fontSize: 25,
          ),
          labelLarge: GoogleFonts.aBeeZee(
            fontSize: Dimensions.elevatedButtonFontSize,
          ),
          bodyLarge: GoogleFonts.aBeeZee(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.grey,
          secondary: Constants.mainColor,
          scrim: Colors.white,
          tertiary: Colors.black87,
        ),
      );
}
