import "dart:developer";
import "package:dio/dio.dart";
import "package:get/get.dart";

import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/core/network/dio_client.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/datasources/auth_remote_data_source.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/repositories/auth_repository_impl.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/get_user_profile_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/login_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/signup_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/getx/auth_controller.dart";

Future<void> initDependencies() async {
  // Database
  final localDbRepository = LocalDbRepository();
  Get.put<LocalDbRepository>(localDbRepository, permanent: true);

  // Network
  final dioClient = DioClient(localDbRepository);
  dioClient.dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      log("--> ${options.method} ${options.uri}", name: "Dio");
      log("Headers: ${options.headers}", name: "Dio");
      log("Body: ${options.data}", name: "Dio");
      return handler.next(options);
    },
    onResponse: (response, handler) {
      log("<-- ${response.statusCode} ${response.requestOptions.uri}", name: "Dio");
      log("Response: ${response.data}", name: "Dio");
      return handler.next(response);
    },
    onError: (e, handler) {
      log("<-- ERROR ${e.response?.statusCode} ${e.requestOptions.uri}", name: "Dio");
      log("Message: ${e.message}", name: "Dio");
      return handler.next(e);
    },
  ));
  Get.put<DioClient>(dioClient, permanent: true);


  // Auth Feature - Data Sources
  Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dioClient.dio));

  // Auth Feature - Repositories
  Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find()));

  // Auth Feature - Use Cases
  Get.lazyPut(() => LoginUseCase(Get.find()));
  Get.lazyPut(() => SignUpUseCase(Get.find()));
  Get.lazyPut(() => GetUserProfileUseCase(Get.find()));

  // Auth Feature - Controller
  Get.put(AuthController(
    loginUseCase: Get.find(),
    signUpUseCase: Get.find(),
    getUserProfileUseCase: Get.find(),
    localDbRepository: Get.find(),
  ));
}
