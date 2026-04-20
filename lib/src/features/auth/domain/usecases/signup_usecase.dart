import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/auth_entity.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthEntity> call(Map<String, dynamic> signupData) {
    return repository.signup(signupData);
  }
}
