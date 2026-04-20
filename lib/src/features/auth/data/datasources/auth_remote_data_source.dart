import "package:dio/dio.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/models/auth_model.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/models/user_model.dart";

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String mobile, String password);
  Future<AuthModel> signup(Map<String, dynamic> signupData);
  Future<UserModel> getUserProfile();
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
}
