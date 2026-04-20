import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class VerifyOTPUseCase {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  Future<Map<String, dynamic>> call(String mobile, String otp, String hash) {
    return repository.verifyOtp(mobile, otp, hash);
  }
}
