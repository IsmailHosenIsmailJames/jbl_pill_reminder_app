String baseAPI = "http://103.168.140.135:6070/api/v1/";
String signUpAPI = "${baseAPI}auth/signup";
String loginAPI = "${baseAPI}auth/login";
String userProfileAPI = "${baseAPI}auth/user";
String updatePasswordAPI = "${baseAPI}auth/update-password";
String otpRequestAPI = "${baseAPI}auth/otp-request";
String verifyOtpAPI = "${baseAPI}auth/verify-otp";
String updateForgotPasswordAPI = "${baseAPI}auth/update-forgot-password";
String pillSchedulesAPI = "${baseAPI}pill-schedules";



// Old endpoints (kept for reference or other features not yet migrated)
String oldBaseAPI = "http://103.168.140.134:5003/api/";
String updateUserInfoAPI = "${oldBaseAPI}user/update_user/";
String createReminderAPI = "${oldBaseAPI}reminders/create/";
String getAppInfoAPI = "${oldBaseAPI}in_app_update/info/";

