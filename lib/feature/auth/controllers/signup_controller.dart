import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/const/string_const/api_endpoint.dart';
import 'package:scaffassistant/routing/route_name.dart';

class SignupController extends GetxController{

  RxBool isLoading = false.obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signUp() async {

    isLoading.value = true;
    final response = await http.post(
      Uri.parse(APIEndPoint.signup),
      body: {
        'full_name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    print('Response status for sing up: ${response.statusCode}');

    if(response.statusCode == 200 || response.statusCode == 201){
      isLoading.value = false;
      // Handle successful login
      Get.offAllNamed(RouteNames.otpVerification, arguments: {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      });
      Get.showSnackbar(
        GetSnackBar(
          message: 'Account created successfully. Please verify your email.',
          duration: Duration(seconds: 3),
        )
      );
    } else {
      isLoading.value = false;
      print('Sing Up failed: ${response.body}');
    }

  }

}