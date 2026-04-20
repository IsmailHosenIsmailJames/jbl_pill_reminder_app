import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";

import "package:jbl_pills_reminder_app/src/navigation/app_router.dart";
import "package:jbl_pills_reminder_app/src/navigation/routes.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/get_user_profile_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/login_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/signup_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/update_password_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_state.dart";


class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final LocalDbRepository localDbRepository;


  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.getUserProfileUseCase,
    required this.updatePasswordUseCase,
    required this.localDbRepository,
  }) : super(AuthInitial());


  Future<void> checkAuthStatus() async {
    final String? userData = await localDbRepository.getPreference("user_info");
    if (userData != null) {
      await getUserProfile();
    } else {
      emit(Unauthenticated());
    }
  }

  Future<bool> login(String mobile, String password) async {
    emit(AuthLoading());
    try {
      final auth = await loginUseCase(mobile, password);
      // Save auth info
      await localDbRepository.savePreference(
          "user_info",
          jsonEncode({
            "id": auth.id,
            "access_token": auth.accessToken,
          }));

      // Fetch profile after login
      await getUserProfile();
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Login failed: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      emit(Unauthenticated());
      return false;
    }
  }

  Future<bool> signup(Map<String, dynamic> signupData) async {
    emit(AuthLoading());
    try {
      final auth = await signUpUseCase(signupData);
      // Save auth info
      await localDbRepository.savePreference(
          "user_info",
          jsonEncode({
            "id": auth.id,
            "access_token": auth.accessToken,
          }));

      // Fetch profile after signup
      await getUserProfile();
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Signup failed: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      emit(Unauthenticated());
      return false;
    }
  }

  Future<void> getUserProfile() async {
    // Only emit AuthLoading if NOT already authenticated.
    // Emitting AuthLoading while authenticated causes the router to
    // show the loading screen, which remounts HomeScreen, which calls
    // getUserProfile again — an infinite loop.
    if (state is! Authenticated) {
      emit(AuthLoading());
    }
    try {
      final user = await getUserProfileUseCase();
      emit(Authenticated(user));
    } catch (e) {
      if (e.toString().contains("401")) {
        await logout();
      } else {
        emit(Unauthenticated());
      }
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    try {
      await updatePasswordUseCase(oldPassword, newPassword);
      Fluttertoast.showToast(
        msg: "Password updated successfully!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update password: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
  }


  Future<void> logout() async {
    await localDbRepository.deletePreference("user_info");
    emit(Unauthenticated());
    AppRouter.router.go(Routes.rootRoute);
  }
}
