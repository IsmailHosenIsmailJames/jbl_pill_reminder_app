import "package:get/get.dart";
import "package:hive_ce_flutter/adapters.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/model/signup_models.dart";

class ProfilePageController extends GetxController {
  Rx<UserInfoModel?> userInfo = Rx<UserInfoModel?>(null);
  @override
  void onInit() {
    final String? userData =
        Hive.box("user_db").get("user_info", defaultValue: null);
    if (userData != null) {
      userInfo.value = UserInfoModel.fromJson(userData);
    }
    super.onInit();
  }
}
