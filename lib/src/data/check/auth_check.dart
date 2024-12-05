import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';

class AuthCheck {
  static bool isLoggedIn() {
    String? name = SharedPrefs.prefs.getString("name");
    String? password = SharedPrefs.prefs.getString("name");
    String? mobileNumber = SharedPrefs.prefs.getString("name");
    if (name != null && password != null && mobileNumber != null) {
      return true;
    } else {
      return false;
    }
  }
}
