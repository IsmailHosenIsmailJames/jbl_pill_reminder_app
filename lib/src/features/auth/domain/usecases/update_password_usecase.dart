import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> call(String oldPassword, String newPassword) {
    return repository.updatePassword(oldPassword, newPassword);
  }
}
