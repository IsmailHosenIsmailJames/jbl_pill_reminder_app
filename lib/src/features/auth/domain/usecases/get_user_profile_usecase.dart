import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/user_entity.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class GetUserProfileUseCase {
  final AuthRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.getUserProfile();
  }
}
