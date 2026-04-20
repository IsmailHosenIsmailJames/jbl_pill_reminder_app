import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:go_router/go_router.dart";

import "package:jbl_pills_reminder_app/src/features/auth/presentation/getx/auth_controller.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/add_reminder.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/signup_page.dart";
import "package:jbl_pills_reminder_app/src/screens/history/history_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/my_pills/my_pills_page.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/profile_page.dart";
import "package:jbl_pills_reminder_app/src/screens/take_medicine/take_medicine_page.dart";
import "package:jbl_pills_reminder_app/src/widgets/routes_not_found.dart";

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.rootRoute,
    routes: [
      GoRoute(
        path: Routes.rootRoute,
        name: Routes.rootRoute,
        builder: (context, state) {
          final AuthController authController = Get.find<AuthController>();
          return Obx(() {
            if (authController.isCheckingAuth.value) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authController.userEntity.value != null
                ? const HomeScreen()
                : const LoginPage();
          });
        },
      ),
      GoRoute(
        path: Routes.loginRoute,
        name: Routes.loginRoute,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signupRoute,
        name: Routes.signupRoute,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: Routes.homeRoute,
        name: Routes.homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.takeMedicineRoute,
        name: Routes.takeMedicineRoute,
        builder: (context, state) {
          final reminder = state.extra as ReminderModel;
          return TakeMedicinePage(currentMedicationToTake: reminder);
        },
      ),
      GoRoute(
        path: Routes.addReminderRoute,
        name: Routes.addReminderRoute,
        builder: (context, state) {
          final editMode = state.extra as bool? ?? false;
          return AddReminder(editMode: editMode);
        },
      ),
      GoRoute(
        path: Routes.profileRoute,
        name: Routes.profileRoute,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: Routes.myPillsRoute,
        name: Routes.myPillsRoute,
        builder: (context, state) {
          final phone = state.extra as String? ?? "";
          return MyPillsPage(phone: phone);
        },
      ),
      GoRoute(
        path: Routes.historyRoute,
        name: Routes.historyRoute,
        builder: (context, state) {
          final phone = state.extra as String? ?? "";
          return HistoryPage(phone: phone);
        },
      ),
    ],
    errorBuilder: (context, state) => const RoutesNotFound(routeName: "Unknown"),
  );
}
