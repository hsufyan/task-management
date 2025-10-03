import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskify/api_helper/firebaseNotificationsService.dart';

import '../../firebase_options.dart';

class FirebaseService {
  static FirebaseMessaging? _firebaseMessaging;

  static FirebaseMessaging get firebaseMessaging =>
      FirebaseService._firebaseMessaging ?? FirebaseMessaging.instance;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseService._firebaseMessaging = FirebaseMessaging.instance;
    await FirebaseService.initializeLocalNotifications();
    await FCMProvider.onMessage();
    await FirebaseService.onBackgroundMsg();
  }

  Future<String?> getDeviceToken() async {
    final messaging = FirebaseMessaging.instance;

    // 💡 Don't try token on web or simulator
    if (kIsWeb) return null;

    if (Platform.isIOS || Platform.isMacOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final isSimulator = iosInfo.isPhysicalDevice == false;

      if (isSimulator) {
        print("🔥 Skipping FCM token: running on iOS Simulator");
        return null;
      }

      // Wait up to 10 seconds for APNs token
      String? apnsToken;
      for (int i = 0; i < 10; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null) {
        print("🚫 APNs token not available. Skipping FCM token.");
        return null;
      }
    }

    try {
      final fcmToken = await messaging.getToken();
      print("✅ FCM Token: $fcmToken");
      return fcmToken;
    } catch (e) {
      print("🔥 Error getting FCM token: $e");
      return null;
    }
  }





  static FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeLocalNotifications() async {
    InitializationSettings initSettings = const InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings());

    await FirebaseMessaging.instance.requestPermission();

    /// on did receive notification response = for when app is opened via notification while in foreground on android
    await FirebaseService.localNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: FCMProvider.onTapNotification);

    /// need this for ios foregournd notification
    await FirebaseService.firebaseMessaging
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  static NotificationDetails platformChannelSpecifics =
      const NotificationDetails(
    android: AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      priority: Priority.max,
      importance: Importance.max,
       icon: 'ic_launcher', // ✅ Don't include file extension
    ),
  );

  static Future<void> onBackgroundMsg() async {
    FirebaseMessaging.onBackgroundMessage(FCMProvider.backgroundHandler);
  }
}
