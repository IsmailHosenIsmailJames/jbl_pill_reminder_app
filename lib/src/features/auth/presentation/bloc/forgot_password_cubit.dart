import "package:flutter_bloc/flutter_bloc.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/send_otp_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/verify_otp_usecase.dart";
import "package:jbl_pills_reminder_app/src/features/auth/domain/usecases/reset_password_usecase.dart";
import "forgot_password_state.dart";

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final SendOTPUseCase sendOTPUseCase;
  final VerifyOTPUseCase verifyOTPUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordCubit({
    required this.sendOTPUseCase,
    required this.verifyOTPUseCase,
    required this.resetPasswordUseCase,
  }) : super(ForgotPasswordInitial());

  Future<void> sendOtp(String mobile) async {
    emit(ForgotPasswordLoading());
    try {
      final response = await sendOTPUseCase(mobile);
      // Assuming 'hash' is in response['data']['hash'] based on Postman verify-otp request
      final hash = response["data"]["hash"] ?? "";
      emit(OtpSent(mobile, hash));
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  Future<void> verifyOtp(String mobile, String otp, String hash) async {
    emit(ForgotPasswordLoading());
    try {
      final response = await verifyOTPUseCase(mobile, otp, hash);
      // Assuming 'sessionToken' is in response['data']['sessionToken']
      final sessionToken = response["data"]["sessionToken"] ?? "";
      emit(OtpVerified(sessionToken));
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }

  Future<void> resetPassword(String password, String sessionToken) async {
    emit(ForgotPasswordLoading());
    try {
      await resetPasswordUseCase(password, sessionToken);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }
}
