import 'package:get_storage/get_storage.dart';

class UserStatus {
  static void setIsLoggedIn(bool status) {
    final box = GetStorage();
    box.write('isLoggedIn', status);
  }

  static bool getIsLoggedIn() {
    final box = GetStorage();
    return box.read('isLoggedIn') ?? false;
  }

  // is first time user
  static void setIsFirstTimeUser(bool status) {
    final box = GetStorage();
    box.write('isFirstTimeUser', status);
  }

  static bool getIsFirstTimeUser() {
    final box = GetStorage();
    return box.read('isFirstTimeUser') ?? true;
  }
}
