import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:recycleorigindriver/core/app_locale_controller.dart';
import 'package:recycleorigindriver/core/config/app_config.dart';
import 'package:recycleorigindriver/core/notifications/fcm_background.dart';
import 'package:recycleorigindriver/core/notifications/firebase_bootstrap.dart';
import 'package:recycleorigindriver/core/utils/app_info_service.dart';
import 'package:recycleorigindriver/main.dart';

Future<void> bootstrapDriverApp(String envFile) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(envFile: envFile);
  await AppLocaleController.instance.load();
  await AppInfoService.instance.initialize();
  await FirebaseBootstrap.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}
