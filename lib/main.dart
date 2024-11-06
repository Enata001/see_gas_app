import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:see_gas_app/firebase_options.dart';
import 'package:see_gas_app/services/messaging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  PushNotificationService notificationService = PushNotificationService();
  notificationService.initialize();
  final pref = await SharedPreferences.getInstance();
  runApp(MyApp(
    preferences: pref,
  ));
}

