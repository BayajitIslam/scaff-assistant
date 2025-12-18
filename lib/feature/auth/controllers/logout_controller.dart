import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/const/string_const/api_endpoint.dart';
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/routing/route_name.dart';

class LogoutController extends GetxController{

  RxBool isLoading = false.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    isLoading.value = true;
    final response = await http.post(
      Uri.parse(APIEndPoint.logout),
      headers: {
        'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
      },
    );

    print('Response status for logout: ${response.statusCode}');

    if(response.statusCode == 200){
      isLoading.value = false;
      UserInfo.clearUserInfo();
      Get.offAllNamed(RouteNames.login);
    } else {
      isLoading.value = false;
      print('Logout failed: ${response.body}');
    }

  }

}