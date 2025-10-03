import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:taskify/api_helper/firebaseNotificationsService.dart';
import 'package:taskify/api_helper/firebaseService.dart';
import 'package:taskify/firebase_options.dart';
import 'package:taskify/screens/my_app.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'bloc/theme/theme_bloc.dart';
import 'bloc/theme/theme_event.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FCMProvider.onMessage();
  FCMProvider.handleNotificationTaps();
  FirebaseMessaging.onBackgroundMessage(FCMProvider.backgroundHandler);
  FirebaseService.localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseService.initializeFirebase();
// 2️⃣ Hive initialization (this is the fix!)



  bool isDarkTheme = false;

  runApp(
    BlocProvider(
      create: (_) => ThemeBloc()..add(InitialThemeEvent(isDarkTheme)),
      child: ShowCaseWidget(
        autoPlay: true,
        autoPlayDelay: const Duration(seconds: 8),
        builder: (context) => ThemeSwitcher(
          clipper: const ThemeSwitcherCircleClipper(),
          builder: (context) => MyApp(isDarkTheme: isDarkTheme),
        ),
      ),
    ),
  );
}
