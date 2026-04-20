import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String password, String sessionToken) {
    return repository.resetPassword(password, sessionToken);
  }
}
