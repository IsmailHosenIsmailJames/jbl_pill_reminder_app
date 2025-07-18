import "dart:developer";

import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/controller/profile_page_controller.dart";
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

        return MaterialPageRoute(
          builder: (context) =>
              RoutesNotFound(routeName: settings.name ?? "'Empty'"),
        );
      },
      initialRoute: Routes.rootRoute,
    );
  }
}
