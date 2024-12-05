import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPageController extends GetxController {
  RxBool showPassword = false.obs;

  Future<bool> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    // TODO: implement signUp
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('name', name);
    await preferences.setString('phone', phone);
    await preferences.setString('password', password);
    return true; // registation
  }
}
