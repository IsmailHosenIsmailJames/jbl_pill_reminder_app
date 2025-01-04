import 'package:jbl_pill_reminder_app/src/data/local_cache/shared_prefs.dart';

class AuthCheck {
  static bool isLoggedIn() {
    String? uuid = SharedPrefs.prefs.getString("uuid");
    if (uuid != null) {
      return true;
    } else {
      return false;
    }
  }
}
