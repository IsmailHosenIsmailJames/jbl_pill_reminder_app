import "dart:convert";
import "dart:developer";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:jbl_pills_reminder_app/src/features/fcm/domain/usecases/register_fcm_token_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/data/models/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/navigation/app_router.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/core/functions/dependency_injection.dart";

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Request permission (required for iOS and Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("User granted permission", name: "FCMService");
    } else {
      log("User declined or has not accepted permission", name: "FCMService");
    }

    // 2. Initialize Local Notifications for Foreground handling
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/launcher_icon");
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          try {
            final reminderMap = Map<String, dynamic>.from(
                jsonDecode(response.data["reminder"] ?? "{}"));
            final reminder = ReminderModel.fromJson(reminderMap);
            AppRouter.router.pushNamed(
              Routes.takeMedicineRoute,
              extra: reminder,
            );
          } catch (e) {
            log("Error parsing reminder from local notification: $e",
                name: "FCMService");
          }
        });

    // 3. Configure foreground notification presentation
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Handle background messages (Must be a top-level function)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Got a message whilst in the foreground!", name: "FCMService");
      log(
        "FCM Message: ${JsonEncoder.withIndent("  ").convert(message.data)}",
        name: "FCMService",
      );
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // 6. Handle notification click (when app is in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification clicked!", name: "FCMService");
      _handleNotificationClick(message);
    });

    // 7. Check if app was opened from a terminated state via a notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      log("App opened from terminated state via notification",
          name: "FCMService");
      _handleNotificationClick(initialMessage);
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    String? reminderJson = message.data["reminder"];
    if (reminderJson != null) {
      try {
        final reminderMap = Map<String, dynamic>.from(jsonDecode(reminderJson));
        final reminder = ReminderModel.fromJson(reminderMap);
        AppRouter.router.pushNamed(
          Routes.takeMedicineRoute,
          extra: reminder,
        );
      } catch (e) {
        log("Error parsing reminder from FCM: $e", name: "FCMService");
      }
    }
  }

  static Future<void> getTokenAndRegister() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        log("FCM Token: $token", name: "FCMService");
        // Register token with backend
        await sl<RegisterFCMTokenUseCase>().call(token);
      }
    } catch (e) {
      log("Error getting/registering FCM token: $e", name: "FCMService");
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      "fcm_default_channel",
      "FCM Notifications",
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    _localNotificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformChannelSpecifics,
      payload: message.data["reminder"],
    );
  }
}

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}",
      name: "FCMService");
  // If you're going to use other Firebase services in the background,
  // you must call Firebase.initializeApp() first.
}
