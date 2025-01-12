import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/core/common.dart';
import 'package:jbl_pill_reminder_app/src/screens/notifications_response/notifications_response_page.dart';
import 'package:jbl_pill_reminder_app/src/screens/take_medicine/take_medicine_page.dart';

class LocalNotifications {
  static AndroidNotificationChannel notificationChannel =
      const AndroidNotificationChannel(
    notificationChannelId, // id
    'JBL Pill Reminder', // title
    description: 'This is for pill reminding', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeService() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // initialize the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;

    log("message");

    if (payload == "take_medicine") {
      await Get.to(
        () => TakeMedicinePage(
          title: "Take Medicine",
          payload: payload,
        ),
      );
    } else {
      await Get.to(
        () => NotificationsResponsePage(
          payload: payload,
        ),
      );
    }
  }

  static void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse details) {
    debugPrint(details.payload);
  }
}
