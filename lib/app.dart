import "package:flutter/material.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:get/get.dart";
import "package:google_fonts/google_fonts.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/theme/colors.dart";
import "package:jbl_pills_reminder_app/src/theme/const_values.dart";
import "package:jbl_pills_reminder_app/src/widgets/routes_not_found.dart";

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
    return GetMaterialApp(
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
      initialRoute: Routes.rootRoute,
      getPages: [
        GetPage(
          name: Routes.rootRoute,
          page: () => Obx(() {
            if (authController.isCheckingAuth.value) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authController.userEntity.value != null
                ? const HomeScreen()
                : const LoginPage();
          }),
        ),
      ],
      unknownRoute: GetPage(
        name: "/unknown",
        page: () => const RoutesNotFound(routeName: "Unknown"),
      ),
    );
  }
}
