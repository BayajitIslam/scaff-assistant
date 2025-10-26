import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/const/string_const/api_endpoint.dart';
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/core/local_storage/user_status.dart';
import 'package:scaffassistant/routing/route_name.dart';

class LoginController extends GetxController{

  RxBool isLoading = false.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    isLoading.value = true;
    final response = await http.post(
      Uri.parse(APIEndPoint.login),
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    print('Response status for login: ${response.statusCode}');

    if(response.statusCode == 200){
      isLoading.value = false;
      // Handle successful login
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      UserStatus.setIsLoggedIn(true);
      UserInfo.setUserName(responseData['full_name'] ?? responseData['username'] ?? '');
      UserInfo.setUserEmail(responseData['email'] ?? emailController.text);
      UserInfo.setAccessToken(responseData['access_token']?['access'] ?? '');
      Get.offAllNamed(RouteNames.home);
    } else {
      isLoading.value = false;
      print('Login failed: ${response.body}');
    }

  }

}