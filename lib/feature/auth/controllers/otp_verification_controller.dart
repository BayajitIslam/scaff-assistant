import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/const/string_const/api_endpoint.dart';
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/core/local_storage/user_status.dart';
import 'package:scaffassistant/routing/route_name.dart';

class OtpVerificationController extends GetxController{

  RxBool isLoading = false.obs;

  TextEditingController otpController = TextEditingController();

  Future<void> otpVerify(String name , String email , String password) async {
    isLoading.value = true;
    final response = await http.post(
      Uri.parse(APIEndPoint.otpVerification),
      body: {
        'email': email,
        'otp_code': otpController.text,
        'full_name': name,
        'password': password,
      },
    );

    print('Response status for account cration: ${response.statusCode}');

    if(response.statusCode == 200 || response.statusCode == 201){
      isLoading.value = false;
      // Handle successful login
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      UserStatus.setIsLoggedIn(true);
      UserInfo.setUserName(responseData['full_name'] ?? responseData['username'] ?? '');
      UserInfo.setUserEmail(responseData['email'] ?? email);
      UserInfo.setAccessToken(responseData['access_token']?['access'] ?? '');
      Get.offAllNamed(RouteNames.home);
    } else {
      isLoading.value = false;
      Get.showSnackbar(
        GetSnackBar(
          message: 'OTP Verification failed. Please try again.',
          duration: Duration(seconds: 3),
        )
      );
      print('Account Creation failed: ${response.body}');
    }

  }

}