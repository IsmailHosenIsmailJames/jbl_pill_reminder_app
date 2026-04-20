import "package:dio/dio.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "package:jbl_pills_reminder_app/src/core/network/auth_interceptor.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";

class DioClient {
  late final Dio _dio;

  DioClient(LocalDbRepository localDbRepository) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseAPI,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(AuthInterceptor(localDbRepository));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
    ));
  }

  Dio get dio => _dio;
}
