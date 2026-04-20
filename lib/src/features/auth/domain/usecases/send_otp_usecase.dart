import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class SendOTPUseCase {
  final AuthRepository repository;

  SendOTPUseCase(this.repository);

  Future<Map<String, dynamic>> call(String mobile) {
    return repository.requestOtp(mobile);
  }
}
