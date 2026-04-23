import "../../data/repositories/fcm_repository_impl.dart";

class RegisterFCMTokenUseCase {
  final FCMRepository repository;

  RegisterFCMTokenUseCase({required this.repository});

  Future<void> call(String token) async {
    return await repository.registerDevice(token);
  }
}
