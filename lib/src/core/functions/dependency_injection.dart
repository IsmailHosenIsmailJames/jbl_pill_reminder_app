import "dart:developer";
import "package:dio/dio.dart";
import "package:get_it/get_it.dart";

import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/core/network/dio_client.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/datasources/auth_remote_data_source.dart";
import "package:jbl_pills_reminder_app/src/features/auth/data/repositories/auth_repository_impl.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/repositories/auth_repository.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/get_user_profile_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/login_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/signup_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/update_password_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/send_otp_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/verify_otp_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/reset_password_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/auth_cubit.dart";
import "package:jbl_pills_reminder_app/src/features/auth/presentation/bloc/forgot_password_cubit.dart";
import "package:jbl_pills_reminder_app/src/screens/home/bloc/home_cubit.dart";


final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  final localDbRepository = LocalDbRepository();
  sl.registerLazySingleton<LocalDbRepository>(() => localDbRepository);

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
  sl.registerLazySingleton<DioClient>(() => dioClient);

  // Auth Feature - Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<DioClient>().dio));

  // Auth Feature - Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl()));

  // Auth Feature - Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => SendOTPUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOTPUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // Blocs / Cubits
  sl.registerLazySingleton(() => AuthCubit(
        loginUseCase: sl(),
        signUpUseCase: sl(),
        getUserProfileUseCase: sl(),
        updatePasswordUseCase: sl(),
        localDbRepository: sl(),
      ));

  sl.registerLazySingleton(() => ForgotPasswordCubit(
        sendOTPUseCase: sl(),
        verifyOTPUseCase: sl(),
        resetPasswordUseCase: sl(),
      ));


  sl.registerLazySingleton(() => HomeCubit(
        localDb: sl(),
      ));
}
