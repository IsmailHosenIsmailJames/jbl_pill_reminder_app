import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/home_page.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:toastification/toastification.dart';

class JblPillReminderApp extends StatelessWidget {
  const JblPillReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.light,
            seedColor: MyAppColors.primaryColor,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyAppColors.primaryColor,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius,
                ),
              ),
            ),
          ),
        ),
        defaultTransition: Transition.leftToRight,
        onInit: () {
          FlutterNativeSplash.remove();
        },
        home: const HomePage(),
      ),
    );
  }
}
