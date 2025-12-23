import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/services/google_signin_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/feature/subscription/controller/subscription_controller.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOGIN CONTROLLER
/// Handles user authentication login flow
/// ═══════════════════════════════════════════════════════════════════════════
class LoginController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Text Controllers
  // ─────────────────────────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────
  // Observable States
  // ─────────────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Toggle Password Visibility
  // ─────────────────────────────────────────────────────────────────────────
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validate Inputs
  // ─────────────────────────────────────────────────────────────────────────
  bool _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnackbarService.error('Please fill in all fields');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      SnackbarService.error('Please enter a valid email');
      return false;
    }

    if (password.length < 6) {
      SnackbarService.error('Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login API Call
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (!_validateInputs()) return;

    Console.divider(label: 'LOGIN');
    Console.auth('Attempting login...');

    isLoading.value = true;

    try {
      final response = await ApiService.postForm(
        ApiEndpoints.login,
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      Console.auth('Response status: ${response.statusCode}');

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        Console.success('Login successful!');

        // Save user session
        StorageService.saveUserSession(
          userName: data['full_name'] ?? data['username'] ?? '',
          email: data['email'] ?? emailController.text.trim(),
          accessToken: data['access_token']?['access'] ?? data['access'] ?? '',
          refreshToken: data['access_token']?['refresh'] ?? data['refresh'],
          userId: data['id']?.toString(),
        );

        SnackbarService.success('Welcome back!');

        // Check subscription and navigate
        await SubscriptionController.checkAndNavigateAfterLogin();
      } else {
        Console.error('Login failed: ${response.message}');
        SnackbarService.error(
          response.message ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      Console.error('Login exception: $e');
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Google Sign In
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> googleSignIn() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      await GoogleSignInService.signIn();
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Apple Sign In
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> appleSignIn() async {
    Console.auth('Apple Sign In initiated...');
    SnackbarService.info('Apple Sign In coming soon!');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigate to Signup
  // ─────────────────────────────────────────────────────────────────────────
  void goToSignup() {
    Console.nav('Navigating to Signup');
    Get.toNamed(RouteNames.signup);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigate to Forgot Password
  // ─────────────────────────────────────────────────────────────────────────
  void goToForgotPassword() {
    Console.nav('Navigating to Forgot Password');
    Get.toNamed(RouteNames.mailVerification);
  }
}
