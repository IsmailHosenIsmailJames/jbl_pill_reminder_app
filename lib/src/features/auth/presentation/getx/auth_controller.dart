import "dart:convert";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:get/get.dart";


import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/get_user_profile_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/login_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/signup_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/user_entity.dart";

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final LocalDbRepository localDbRepository;

  AuthController({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.getUserProfileUseCase,
    required this.localDbRepository,
  });

  var isLoading = false.obs;
  var isCheckingAuth = true.obs;
  var userEntity = Rxn<UserEntity>();


  @override
  void onInit() {
    super.onInit();
    _loadUserFromLocal();
  }

  Future<void> _loadUserFromLocal() async {
    final String? userData = await localDbRepository.getPreference("user_info");
    // Note: We might need a model to parse this, but for now we'll just check if it exists
    // and rely on getUserProfile to refresh it.
    if (userData != null) {
      await getUserProfile();
    }
    isCheckingAuth.value = false;

  }

  Future<bool> login(String mobile, String password) async {
    isLoading.value = true;
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
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signup(Map<String, dynamic> signupData) async {
    isLoading.value = true;
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
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserProfile() async {
    try {
      final user = await getUserProfileUseCase();
      userEntity.value = user;
    } catch (e) {
      // If unauthorized, we might want to logout
      if (e.toString().contains("401")) {
        logout();
      }
    }
  }

  Future<void> logout() async {
    await localDbRepository.deletePreference("user_info");
    userEntity.value = null;
    Get.offAllNamed("/");
  }
}
