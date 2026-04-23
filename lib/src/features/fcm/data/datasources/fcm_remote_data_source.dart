import "package:dio/dio.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";

abstract class FCMRemoteDataSource {
  Future<void> registerDevice(String token);
}

class FCMRemoteDataSourceImpl implements FCMRemoteDataSource {
  final Dio dio;

  FCMRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> registerDevice(String token) async {
    try {
      await dio.post(
        registerFCMTokenAPI,
        data: {"token": token},
      );
    } catch (e) {
      rethrow;
    }
  }
}
