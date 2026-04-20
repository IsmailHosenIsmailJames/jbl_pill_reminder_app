import "package:dio/dio.dart";
import "dart:convert";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";

class AuthInterceptor extends Interceptor {
  final LocalDbRepository localDbRepository;

  AuthInterceptor(this.localDbRepository);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final String? userInfoStr = await localDbRepository.getPreference("user_info");
    if (userInfoStr != null) {
      try {
        final Map<String, dynamic> userInfo = jsonDecode(userInfoStr);
        final String? token = userInfo["data"]?["access_token"] ?? userInfo["access_token"];
        
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
      } catch (e) {
        // Handle JSON decode error or missing token
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Potentially clear user session or redirect to login
      // For now, we'll just propagate the error
    }
    super.onError(err, handler);
  }
}
