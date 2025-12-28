import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/services/google_signin_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SIGNUP CONTROLLER
/// Handles new user registration flow
/// ═══════════════════════════════════════════════════════════════════════════
class SignupController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Text Controllers
  // ─────────────────────────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────
  // Observable States
  // ─────────────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Toggle Password Visibility
  // ─────────────────────────────────────────────────────────────────────────
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validate Inputs
  // ─────────────────────────────────────────────────────────────────────────
  bool _validateInputs() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Check empty fields
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      SnackbarService.error('Please fill in all fields');
      return false;
    }

    // Validate name length
    if (name.length < 2) {
      SnackbarService.error('Name must be at least 2 characters');
      return false;
    }

    // Validate email format
    if (!GetUtils.isEmail(email)) {
      SnackbarService.error('Please enter a valid email');
      return false;
    }

    // Validate password length
    if (password.length < 6) {
      SnackbarService.error('Password must be at least 6 characters');
      return false;
    }

    // Check password match (if confirm field is used)
    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      SnackbarService.error('Passwords do not match');
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Signup API Call
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> signUp() async {
    // Validate first
    if (!_validateInputs()) return;

    Console.divider(label: 'SIGNUP');
    Console.auth('Creating new account...');

    isLoading.value = true;

    try {
      // Make API request
      final response = await ApiService.postForm(
        ApiEndpoints.signup,
        body: {
          'full_name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      Console.auth('Response status: ${response.statusCode}');

      if (response.success) {
        Console.success('Account created! OTP sent.');

        // Show success message
        SnackbarService.success(
          'Account created successfully. Please verify your email.',
        );

        // Navigate to OTP verification with user data
        Get.toNamed(
          RouteNames.otpVerification,
          arguments: {
            'name': nameController.text.trim(),
            'email': emailController.text.toLowerCase().trim(),
            'password': passwordController.text.trim(),
          },
        );
      } else {
        // Handle error response
        Console.error('Signup failed: ${response.message}');

        // Check for specific error messages
        final data = response.data;
        String errorMessage = response.message ?? 'Signup failed';

        if (data is Map && data['email'] != null) {
          errorMessage = 'This email is already registered';
        }

        SnackbarService.error(errorMessage);
      }
    } catch (e) {
      Console.error('Signup exception: $e');
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigate to Login
  // ─────────────────────────────────────────────────────────────────────────
  void goToLogin() {
    Console.nav('Navigating to Login');
    Get.back();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Google Sign Up
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> googleSignUp() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      await GoogleSignInService.signIn();
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Apple Sign Up
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> appleSignUp() async {
    Console.auth('Apple Sign Up initiated...');
    SnackbarService.info('Apple Sign Up coming soon!');
    // TODO: Implement Apple Sign Up
  }
}
