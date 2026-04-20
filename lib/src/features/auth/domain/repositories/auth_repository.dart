import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/auth_entity.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/user_entity.dart";

abstract class AuthRepository {
  Future<AuthEntity> login(String mobile, String password);
  Future<AuthEntity> signup(Map<String, dynamic> signupData);
  Future<UserEntity> getUserProfile();
  Future<void> updatePassword(String oldPassword, String newPassword);
  Future<Map<String, dynamic>> requestOtp(String mobile);
  Future<Map<String, dynamic>> verifyOtp(
      String mobile, String otp, String hash);
  Future<void> resetPassword(String password, String sessionToken);
}

