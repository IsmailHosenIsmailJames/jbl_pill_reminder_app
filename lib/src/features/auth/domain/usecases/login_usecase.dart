import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/auth_entity.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthEntity> call(String mobile, String password) {
    return repository.login(mobile, password);
  }
}
