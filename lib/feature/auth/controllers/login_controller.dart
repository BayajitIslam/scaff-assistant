import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    print('Attempting login with email: ${APIEndPoint.login}');
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

  Future<void> googleSignIn() async {
    print('Starting Google Sign-In process...');
    try {
      isLoading.value = true;

      // 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
      // Initialize Google Sign-In
      await GoogleSignIn.instance.initialize(
        serverClientId: '594391332991-ddau3boono9g5c2acl9p80pt065c1uq0.apps.googleusercontent.com',
      );

      // Check if authentication is supported
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        Get.snackbar('Error', 'Google Sign-In not supported on this platform');
        return;
      }

      // Authenticate the user
      final GoogleSignInAccount? account = await GoogleSignIn.instance.authenticate();
      if (account == null) {
        Get.snackbar('Cancelled', 'Google sign-in cancelled');
        return;
      }

      print('🔐 User signed in: ${account.email}');

      // Define required scopes
      const List<String> scopes = [
        'email',
        'profile',
        'openid', // Required for ID token
      ];

      try {
        // Authorize the scopes to get tokens
        final token = account.authentication;
        final GoogleSignInClientAuthorization authorization =
        await account.authorizationClient.authorizeScopes(scopes);

        // ✅ FIXED: Get ID token instead of server auth code
        final String? accessToken = authorization.accessToken;
        final String? idToken = authorization.accessToken;
        print('🎫 ID Token: ${idToken ?? 'null'}');
        print('🔑 Access Token: ${accessToken ?? 'null'}');
        final Map<String, dynamic> googleProfile = {
          'id': account.id,
          'email': account.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
          'idToken': idToken,
          'accessToken': accessToken,
        };
        print('📦 Google profile: $googleProfile');
        if (idToken == null || idToken.isEmpty) {
          Get.snackbar('Error', 'Failed to get Google ID token');
          return;
        }
        print('🎫 ID Token received: ${idToken.substring(0, 20)}...');

        // ✅ FIXED: Send id_token to backend (matching your backend expectation)
        final loginResponse = await http.post(
          Uri.parse(APIEndPoint.googleLogin),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'access_token': idToken,  // ✅ Send id_token
          }),
        ).timeout(const Duration(seconds: 10));

        if (loginResponse.statusCode == 200) {
          final responseData = jsonDecode(loginResponse.body);
          print('🔐 Login Success Response: $responseData');

          // ✅ FIXED: Parse response matching regular login format
          final accessToken = responseData['access_token']['access'];
          final refreshToken = responseData['access_token']['refresh'];
          final userId = responseData['user_id'];
          final email = responseData['email'];
          final username = responseData['username'];
          final fullName = responseData['full_name'];
          final role = responseData['role'];
          final isVerified = responseData['is_verified'];

          // Store tokens
          UserStatus.setIsLoggedIn(true);
          UserInfo.setUserName(responseData['full_name'] ?? responseData['username'] ?? '');
          UserInfo.setUserEmail(responseData['email'] ?? emailController.text);
          UserInfo.setAccessToken(responseData['access_token']?['access'] ?? '');



          // Navigate to home
          Get.offAllNamed('/home');
        } else {
          print('❌ Login failed: ${loginResponse.body}');
          final errorData = jsonDecode(loginResponse.body);
          Get.snackbar(
            'Error',
            errorData['error'] ?? 'Google login failed',
          );
        }

      } catch (authError) {
        print('❌ Authorization error: $authError');
        Get.snackbar('Error', 'Failed to authorize Google account');
        return;
      }

    } on GoogleSignInException catch (e) {
      String errorMessage;
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          errorMessage = 'Google sign-in was cancelled';
          break;
        case GoogleSignInExceptionCode.clientConfigurationError:
          errorMessage = 'Google sign-in configuration error';
          break;
        default:
          errorMessage = 'Google sign-in error: ${e.description} (Code: ${e.code})';
      }
      print('❌ GoogleSignInException: $errorMessage');
      Get.snackbar('Error', errorMessage);
    } catch (e) {
      print('❌ Unexpected error: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }


  // Future<void> googleSignIn() async {
  //   print('Starting Google Sign-In process...');
  //   try {
  //     isLoading.value = true;
  //
  //     // Initialize Google Sign-In with server client ID
  //     await GoogleSignIn.instance.initialize(
  //       serverClientId: '594391332991-ddau3boono9g5c2acl9p80pt065c1uq0.apps.googleusercontent.com',
  //
  //     );
  //
  //     // Check if authentication is supported
  //     if (!GoogleSignIn.instance.supportsAuthenticate()) {
  //       Get.snackbar('Error', 'Google Sign-In not supported on this platform');
  //       return;
  //     }
  //
  //     // Authenticate the user
  //     final GoogleSignInAccount? account = await GoogleSignIn.instance.authenticate();
  //     if (account == null) {
  //       Get.snackbar('Cancelled', 'Google sign-in cancelled');
  //       return;
  //     }
  //
  //     print('🔐 User signed in: ${account.email}');
  //
  //     // Define required scopes
  //     const List<String> scopes = [
  //       'email',
  //       'profile',
  //       'openid', // Required for ID token
  //     ];
  //
  //     try {
  //       // Authorize the scopes to get tokens
  //       final GoogleSignInClientAuthorization authorization =
  //       await account.authorizationClient.authorizeScopes(scopes);
  //
  //       // Get server authorization (this gives you the ID token equivalent)
  //       final GoogleSignInServerAuthorization? serverAuth =
  //       await account.authorizationClient.authorizeServer(scopes);
  //
  //       if (serverAuth == null) {
  //         Get.snackbar('Error', 'Failed to get Google authorization');
  //         return;
  //       }
  //
  //       final String authCode = serverAuth.serverAuthCode;
  //       if (authCode.isEmpty) {
  //         Get.snackbar('Error', 'Failed to get Google auth code');
  //         return;
  //       }
  //       print('🎫 Server Auth Code: $authCode');
  //
  //       final loginResponse = await http.post(
  //         Uri.parse(APIEndPoint.googleLogin),
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode({
  //           'auth_code': authCode, // Changed from 'token' to 'auth_code'
  //           'email': account.email,
  //           'display_name': account.displayName,
  //         }),
  //       )
  //           .timeout(const Duration(seconds: 10));
  //
  //       if (loginResponse.statusCode == 200) {
  //         final responseData = jsonDecode(loginResponse.body);
  //         print('🔐 Login Success Response: $responseData');
  //       } else {
  //         print('❌ Login failed: ${loginResponse.body}');
  //         Get.snackbar(
  //           'Error',
  //           'Google login failed (${loginResponse.statusCode})',
  //         );
  //       }
  //
  //     } catch (authError) {
  //       print('❌ Authorization error: $authError');
  //       return;
  //     }
  //
  //   } on GoogleSignInException catch (e) {
  //     String errorMessage;
  //     switch (e.code) {
  //       case GoogleSignInExceptionCode.canceled:
  //         errorMessage = 'Google sign-in was cancelled';
  //         break;
  //       case GoogleSignInExceptionCode.clientConfigurationError:
  //         errorMessage = 'Google sign-in configuration error';
  //         break;
  //       default:
  //         errorMessage = 'Google sign-in error: ${e.description} (Code: ${e.code})';
  //     }
  //     print('❌ GoogleSignInException: $errorMessage');
  //     Get.snackbar('Error', errorMessage);
  //   }  finally {
  //     isLoading.value = false;
  //   }
  // }


}