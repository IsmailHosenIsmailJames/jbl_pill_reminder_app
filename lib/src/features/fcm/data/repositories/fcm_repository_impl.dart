import "../datasources/fcm_remote_data_source.dart";

abstract class FCMRepository {
  Future<void> registerDevice(String token);
}

class FCMRepositoryImpl implements FCMRepository {
  final FCMRemoteDataSource remoteDataSource;

  FCMRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> registerDevice(String token) async {
    return await remoteDataSource.registerDevice(token);
  }
}
