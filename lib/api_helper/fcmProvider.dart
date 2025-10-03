import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart'
    show FirebaseMessaging, RemoteMessage;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskify/api_helper/firebaseService.dart';

class FCMProvider with ChangeNotifier {
  /// when app is in the foreground
  static Future<void> onTapNotification(NotificationResponse? response) async {
    if (response?.payload != null) {
      final data = FCMProvider.convertPayload(response!.payload!);
      if (data.containsKey('id')) {
        // Add screen navigation here...
      }
    }
  }

  static Map convertPayload(String payload) {
    if (payload != "{}") {
      final String data = payload.substring(1, payload.length - 1);
      List<String> split = [];
      List<String> list = data.split(",");
      list.forEach((String s) => split.addAll(s.split(":")));

      Map mapped = {};
      for (int i = 0; i < split.length + 1; i++) {
        if (i % 2 == 1)
          mapped.addAll({split[i - 1].trim().toString(): split[i].trim()});
      }
      return mapped;
    }
    return {};
  }

  /// Handle notifications when app is in the foreground
  static Future<void> onMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        print('Full Message: ${message.data}');
        final data = message.data;

        // Show local notifications for Android 13+ devices
        if (Platform.isAndroid) {
          await _showLocalNotification(message);
        }
      }
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    // You can use the data from message to create a local notification
    final title = message.notification?.title ?? 'New Notification';
    final body = message.notification?.body ?? 'You have a new notification';

    await FirebaseService.localNotificationsPlugin.show(
      message.hashCode, // Unique ID
      title,
      body,
      FirebaseService.platformChannelSpecifics, // Your notification details
      payload:
          message.data.toString(), // Optional, pass extra data if necessary
    );
  }

  /// Handle notification taps when the app is in the background or terminated
  static Future<void> handleNotificationTaps() async {
    void handleNotification(RemoteMessage message) {
      final data = message.data;
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleNotification);

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      handleNotification(initialMessage);
    }
  }

  static Future<void> backgroundHandler(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      // Handle background notification data
      if (Platform.isAndroid) {
        await _showLocalNotification(message);
      }
    }
  }
}
