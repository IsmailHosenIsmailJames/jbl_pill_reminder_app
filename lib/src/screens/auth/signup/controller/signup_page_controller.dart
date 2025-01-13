import 'package:get/get.dart';
import 'package:jbl_pill_reminder_app/src/core/functions/genearate_random_id.dart';
import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPageController extends GetxController {
  RxBool showPassword = false.obs;

  Future<String?> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    final SharedPreferences preferences = SharedPrefs.prefs;
    await preferences.setString('name', name);
    await preferences.setString('phone', phone);
    await preferences.setString('password', password);

    final uuid = getRandomGeneratedID(); // just for demo
    await preferences.setString("uuid", uuid.toString());

    return uuid.toString(); // registration successful // just for demo
  }
}
