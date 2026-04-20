abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class OtpSent extends ForgotPasswordState {
  final String mobile;
  final String hash;
  OtpSent(this.mobile, this.hash);
}

class OtpVerified extends ForgotPasswordState {
  final String sessionToken;
  OtpVerified(this.sessionToken);
}

class PasswordResetSuccess extends ForgotPasswordState {}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  ForgotPasswordError(this.message);
}
