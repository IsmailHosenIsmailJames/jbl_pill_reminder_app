import "dart:developer";

import "package:alarm/alarm.dart";
import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:flutter_foreground_task/flutter_foreground_task.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:jbl_pills_reminder_app/src/core/background/work_manager/callback_dispacher.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/model/signup_models.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/controller/profile_page_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/take_medicine/take_medicine_page.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:jbl_pills_reminder_app/src/theme/const_values.dart";
import "package:toastification/toastification.dart";
import "package:workmanager/workmanager.dart";

bool isUpdateChecked = false;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "reminder_process",
    "reminder_processor",
    frequency: const Duration(minutes: 15),
  );

  FlutterForegroundTask.initCommunicationPort();
  await Alarm.init();

  await Hive.initFlutter();
  await Hive.openBox("user_db");
  await Hive.openBox("reminder_db");
  await Hive.openBox("reminder_done");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationsService.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationsService.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationsService.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationsService.onDismissActionReceivedMethod);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        navigatorKey: MyApp.navigatorKey,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData.light().copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.light,
            seedColor: MyAppColors.primaryColor,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius,
                ),
              ),
              side: BorderSide(
                color: MyAppColors.primaryColor,
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyAppColors.primaryColor,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              iconColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius,
                ),
              ),
            ),
          ),
        ),
        defaultTransition: Transition.leftToRight,
        onGenerateRoute: (settings) {
          if (settings.name == "/notification-page") {
            return MaterialPageRoute(builder: (context) {
              final ReceivedAction receivedAction =
                  settings.arguments as ReceivedAction;
              final String? data = receivedAction.payload?["data"];
              if (data != null) {
                return TakeMedicinePage(
                    currentMedicationToTake: ReminderModel.fromJson(data));
              } else {
                return const HomeScreen();
              }
            });
          }
          return null;
        },
        onInit: () async {
          FlutterNativeSplash.remove();
          await Future.delayed(const Duration(seconds: 1));

          final userInfoController = Get.put(ProfilePageController());
          final userInfo =
              Hive.box("user_db").get("user_info", defaultValue: null);
          if (userInfo != null && userInfo.isNotEmpty) {
            try {
              userInfoController.userInfo.value =
                  UserInfoModel.fromJson(userInfo);
            } catch (e) {
              log(e.toString(), name: "UserInfoModel Error");
            }
          }

          if (userInfoController.userInfo.value != null) {
            Get.off(() => const HomeScreen());
          } else {
            Get.off(() => const LoginPage());
          }
        },
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              backgroundColor: MyAppColors.shadedMutedColor,
              color: MyAppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
