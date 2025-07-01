import "dart:convert";
import "dart:developer";

import "package:awesome_notifications/awesome_notifications.dart";
import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:jbl_pills_reminder_app/src/core/notifications/service.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/controller/profile_page_controller.dart";
import "package:jbl_pills_reminder_app/src/screens/take_medicine/take_medicine_page.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:jbl_pills_reminder_app/src/theme/const_values.dart";
import "package:jbl_pills_reminder_app/src/widgets/routes_not_found.dart";

class App extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
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

  final ProfilePageController userInfoController =
      Get.put(ProfilePageController());

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    final PageTransitionsTheme pageTransitionsTheme =
        const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    );
    return MaterialApp(
      navigatorKey: App.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData.light().copyWith(
        pageTransitionsTheme: pageTransitionsTheme,
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
      onGenerateRoute: (settings) {
        log(settings.name.toString(), name: "settings");
        log(settings.arguments.toString(), name: "settings");

        if (settings.name == Routes.rootRoute) {
          if (userInfoController.userInfo.value != null) {
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          } else {
            return MaterialPageRoute(builder: (context) => const LoginPage());
          }
        }
        if (settings.name == Routes.notificationRoute) {
          return MaterialPageRoute(builder: (context) {
            final ReceivedAction receivedAction =
                settings.arguments as ReceivedAction;
            final Map<String, String?>? data = receivedAction.payload != null
                ? Map<String, String?>.from(
                    jsonDecode(receivedAction.payload!["payloadString"]!))
                : null;
            if (data != null) {
              return TakeMedicinePage(
                  currentMedicationToTake: ReminderModel.fromMap(data));
            } else {
              return const HomeScreen();
            }
          });
        }
        if (settings.name == Routes.alarmRoute) {}

        return MaterialPageRoute(
          builder: (context) =>
              RoutesNotFound(routeName: settings.name ?? "'Empty'"),
        );
      },
      initialRoute: Routes.rootRoute,
    );
  }
}
