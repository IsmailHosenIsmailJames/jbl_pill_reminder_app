import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jbl_pill_reminder_app/src/data/check/auth_check.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';
import 'package:jbl_pill_reminder_app/src/model/medication/medication_model.dart';
import 'package:jbl_pill_reminder_app/src/resources/keys.dart';
import 'package:jbl_pill_reminder_app/src/screens/auth/login/login_page.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/controller/home_controller.dart';
import 'package:jbl_pill_reminder_app/src/screens/home/home_page.dart';
import 'package:jbl_pill_reminder_app/src/screens/permissions/permission_page.dart';
import 'package:jbl_pill_reminder_app/src/theme/colors.dart';
import 'package:jbl_pill_reminder_app/src/theme/const_values.dart';
import 'package:permission_handler/permission_handler.dart';
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
        onInit: () async {
          final homeController = Get.put(HomeController());
          FlutterNativeSplash.remove();

          List<String>? allPrescription =
              SharedPrefs.prefs.getStringList(allMedicationKey);
          if (allPrescription != null) {
            for (String prescription in allPrescription) {
              homeController.listOfAllMedications.add(
                MedicationModel.fromJson(prescription),
              );
            }
          }

          if (!(await checkNotificationPermissions() &&
              await Permission.scheduleExactAlarm.status.isGranted)) {
            Get.off(() => const PermissionPage());
          } else {
            AuthCheck.isLoggedIn()
                ? Get.off(() => const HomePage())
                : Get.off(() => const LoginPage());
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
