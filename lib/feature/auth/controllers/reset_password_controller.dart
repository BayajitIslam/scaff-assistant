import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/const/string_const/api_endpoint.dart';
import 'package:scaffassistant/feature/auth/controllers/otp_verification_controller.dart';
import 'package:scaffassistant/routing/route_name.dart';

class ResetPasswordController extends GetxController{

  RxBool isLoading = false.obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> verifyEmail() async {
    isLoading.value = true;
    final response = await http.post(
      Uri.parse(APIEndPoint.mailVerification),
      body: {
        'email': emailController.text,
      },
    );

    print('Response status for login: ${response.statusCode}');

    if(response.statusCode == 200){
      isLoading.value = false;
      // Handle successful login
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseData['exists'] == true) {
        final OtpVerificationController otpVerificationController = Get.put(OtpVerificationController());
        otpVerificationController.resendOTP(
          emailController.text,
          'password_reset',
        );
        Get.toNamed(RouteNames.otpVerification);
      } else {
        Get.snackbar('Error', 'Email does not exist or is not verified');
      }
    } else {
      isLoading.value = false;
      print('Login failed: ${response.body}');
    }

  }

}