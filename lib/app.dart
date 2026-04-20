import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:jbl_pills_reminder_app/src/navigation/app_router.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:jbl_pills_reminder_app/src/theme/const_values.dart";

import "src/features/auth/presentation/getx/auth_controller.dart";

class App extends StatefulWidget {
  final bool isLoggedIn;

  const App({super.key, required this.isLoggedIn});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AuthController authController = Get.find<AuthController>();

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
    return MaterialApp.router(
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
      routerConfig: AppRouter.router,
    );
  }
}
