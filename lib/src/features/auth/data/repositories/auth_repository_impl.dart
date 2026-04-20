import "package:jbl_pills_reminder_app/src/features/auth/data/datasources/auth_remote_data_source.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/auth_entity.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/entities/user_entity.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthEntity> login(String mobile, String password) async {
    return await remoteDataSource.login(mobile, password);
  }

  @override
  Future<AuthEntity> signup(Map<String, dynamic> signupData) async {
    return await remoteDataSource.signup(signupData);
  }

  @override
  Future<UserEntity> getUserProfile() async {
    return await remoteDataSource.getUserProfile();
  }
}
