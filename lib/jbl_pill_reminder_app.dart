import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/home_page.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:toastification/toastification.dart';

import 'src/core/foreground_service/foreground_task_manager.dart';

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
        onInit: () async {
          FlutterNativeSplash.remove();

          if (await ForegroundTaskManager.isServiceRunning() == false) {
            log("Form OnInit");
            if (await ForegroundTaskManager.requestPermissions()) {
              ForegroundTaskManager.initService();
              await ForegroundTaskManager.startService();
            }
          }
        },
        home: const HomePage(),
      ),
    );
  }
}
