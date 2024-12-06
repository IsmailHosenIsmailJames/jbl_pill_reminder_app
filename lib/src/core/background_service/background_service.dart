import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jbl_pill_reminder_app/src/core/common.dart';
import 'package:jbl_pill_reminder_app/src/core/notifications/initialize_notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBackgroundService {
  static FlutterBackgroundService service = FlutterBackgroundService();

  static Future<void> init() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        LocalNotifications.flutterLocalNotificationsPlugin;

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(LocalNotifications.notificationChannel);

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: (service) {
          log("IOS on Foreground");
        },

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        autoStartOnBoot: true,

        // auto start service
        autoStart: true,
        isForegroundMode: false,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);

    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();

    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await preferences.reload();
      String? timestamp = preferences.getString("timestamp");

      print(timestamp);

      if (timestamp != null) {
        Map<String, dynamic> timeData =
            Map<String, dynamic>.from(jsonDecode(timestamp));
        final notificationTime =
            DateTime.fromMillisecondsSinceEpoch(timeData['time']);
        if (DateTime.now().difference(notificationTime).inSeconds >= 0 &&
            !timeData['isShown']) {
          LocalNotifications.flutterLocalNotificationsPlugin
              .show(
            1,
            "Hello BOOOOOOS",
            "Do you want to join with us...",
            const NotificationDetails(
              android: AndroidNotificationDetails(
                "1",
                notificationChannelId,
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            payload: "There we have ",
          )
              .then(
            (value) async {
              await preferences.setString(
                  "timestamp",
                  jsonEncode({
                    "time": timeData['time'],
                    "isShown": true,
                  }));
            },
          );
          return;
        }
      }
    });
  }
}
