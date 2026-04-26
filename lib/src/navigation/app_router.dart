import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:jbl_pills_reminder_app/src/core/functions/dependency_injection.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_state.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/add_reminder.dart";
import "package:jbl_pills_reminder_app/src/features/pill_schedule/domain/entities/pill_schedule_entity.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/login/login_page.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/signup_page.dart";
import "package:jbl_pills_reminder_app/src/screens/history/history_page.dart";
import "package:jbl_pills_reminder_app/src/screens/home/home_screen.dart";
import "package:jbl_pills_reminder_app/src/screens/my_pills/my_pills_page.dart";
import "package:jbl_pills_reminder_app/src/screens/profile_page/profile_page.dart";
import "package:jbl_pills_reminder_app/src/screens/take_medicine/take_medicine_page.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/forgot_password/forgot_password_page.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/forgot_password/verify_otp_page.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/forgot_password/reset_password_page.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/reminder/domain/entities/reminder_entity.dart";
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
          return BlocBuilder<AuthCubit, AuthState>(
            bloc: sl<AuthCubit>(),
            builder: (context, authState) {
              if (authState is AuthLoading || authState is AuthInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return authState is Authenticated
                  ? const HomeScreen()
                  : const LoginPage();
            },
          );
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
          if (state.extra is ReminderEntity) {
            return TakeMedicinePage(reminder: state.extra as ReminderEntity);
          } else if (state.extra is PillScheduleEntity) {
            return TakeMedicinePage(
                currentMedicationToTake: state.extra as PillScheduleEntity);
          }
          return const TakeMedicinePage();
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
      GoRoute(
        path: Routes.forgotPasswordRoute,
        name: Routes.forgotPasswordRoute,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<ForgotPasswordCubit>(),
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: Routes.verifyOtpRoute,
        name: Routes.verifyOtpRoute,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BlocProvider(
            create: (context) => sl<ForgotPasswordCubit>(),
            child: VerifyOtpPage(
              mobile: extra["mobile"],
              hash: extra["hash"],
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.resetPasswordRoute,
        name: Routes.resetPasswordRoute,
        builder: (context, state) {
          final sessionToken = state.extra as String;
          return BlocProvider(
            create: (context) => sl<ForgotPasswordCubit>(),
            child: ResetPasswordPage(sessionToken: sessionToken),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => const RoutesNotFound(routeName: "Unknown"),

  );
}
