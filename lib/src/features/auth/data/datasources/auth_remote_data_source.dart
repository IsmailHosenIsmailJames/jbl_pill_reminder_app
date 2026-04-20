import "package:dio/dio.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/models/auth_model.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/models/user_model.dart";

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String mobile, String password);
  Future<AuthModel> signup(Map<String, dynamic> signupData);
  Future<UserModel> getUserProfile();
  Future<void> updatePassword(String oldPassword, String newPassword);
  Future<Map<String, dynamic>> requestOtp(String mobile);
  Future<Map<String, dynamic>> verifyOtp(
      String mobile, String otp, String hash);
  Future<void> resetPassword(String password, String sessionToken);
}


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthModel> login(String mobile, String password) async {
    final formattedMobile = mobile.startsWith("88") ? mobile : "88$mobile";
    try {
      final response = await dio.post(
        loginAPI,
        data: {
          "mobile": formattedMobile,
          "password": password,
        },
      );
      return AuthModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthModel> signup(Map<String, dynamic> signupData) async {
    if (signupData.containsKey("mobile")) {
      final mobile = signupData["mobile"].toString();
      signupData["mobile"] = mobile.startsWith("88") ? mobile : "88$mobile";
    }
    try {
      final response = await dio.post(
        signUpAPI,
        data: signupData,
      );
      return AuthModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }


  @override
  Future<UserModel> getUserProfile() async {
    try {
      final response = await dio.get(userProfileAPI);
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      await dio.patch(
        updatePasswordAPI,
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> requestOtp(String mobile) async {
    final formattedMobile = mobile.startsWith("88") ? mobile : "88$mobile";
    try {
      final response = await dio.post(
        otpRequestAPI,
        data: {"mobile": formattedMobile},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(
      String mobile, String otp, String hash) async {
    final formattedMobile = mobile.startsWith("88") ? mobile : "88$mobile";
    try {
      final response = await dio.post(
        verifyOtpAPI,
        data: {
          "mobile": formattedMobile,
          "otp": int.tryParse(otp) ?? 0,
          "hash": hash,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String password, String sessionToken) async {
    try {
      await dio.patch(
        updateForgotPasswordAPI,
        data: {
          "password": password,
          "sessionToken": sessionToken,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

