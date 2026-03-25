import "package:get/get.dart";
import "package:jbl_pills_reminder_app/src/core/database/local_db_repository.dart";
import "package:jbl_pills_reminder_app/src/screens/auth/signup/model/signup_models.dart";

class ProfilePageController extends GetxController {
  Rx<UserInfoModel?> userInfo = Rx<UserInfoModel?>(null);
  @override
  void onInit() {
    loadUser();
    super.onInit();
  }

  Future<void> loadUser() async {
    final String? userData =
        await LocalDbRepository().getPreference("user_info");
    if (userData != null) {
      userInfo.value = UserInfoModel.fromJson(userData);
    }
  }
}
