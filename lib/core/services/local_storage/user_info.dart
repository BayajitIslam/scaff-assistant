import 'package:get_storage/get_storage.dart';

class UserInfo {
  static void setUserName(String name) {
    final box = GetStorage();
    box.write('userName', name);
  }

  static String getUserName() {
    final box = GetStorage();
    return box.read('userName');
  }

  static void setUserEmail(String email) {
    final box = GetStorage();
    box.write('userEmail', email);
  }

  static String getUserEmail() {
    final box = GetStorage();
    return box.read('userEmail');
  }

  static void setAccessToken(String token) {
    final box = GetStorage();
    box.write('accessToken', token);
  }

  static String getAccessToken() {
    final box = GetStorage();
    return box.read('accessToken') ?? '';
  }

  static void clearUserInfo() {
    final box = GetStorage();
    box.remove('userName');
    box.remove('userEmail');
    box.remove('accessToken');
    box.remove('isLoggedIn');
  }
}
