import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// RESET PASSWORD CONTROLLER
/// Handles forgot password / email verification flow
/// ═══════════════════════════════════════════════════════════════════════════
class ResetPasswordController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Text Controllers
  // ─────────────────────────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Toggle Password Visibility
  // ─────────────────────────────────────────────────────────────────────────
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validate Email
  // ─────────────────────────────────────────────────────────────────────────
  bool _validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      SnackbarService.error('Please enter your email');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      SnackbarService.error('Please enter a valid email');
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Verify Email (Step 1 - Check if email exists)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> verifyEmail() async {
    // Validate first
    if (!_validateEmail()) return;

    Console.divider(label: 'PASSWORD RESET');
    Console.auth('Checking email: ${emailController.text.trim()}');

    isLoading.value = true;

    try {
      // Check if email exists
      final response = await ApiService.postForm(
        ApiEndpoints.mailVerification,
        body: {'email': emailController.text.trim()},
      );

      Console.auth('Response status: ${response.statusCode}');

      if (response.success) {
        final data = response.data as Map<String, dynamic>;

        if (data['exists'] == true) {
          Console.success('Email found! Sending OTP...');

          // Email exists, send OTP for password reset
          await _sendResetOtp();
        } else {
          Console.warning('Email not found');
          SnackbarService.error('Email does not exist or is not verified');
        }
      } else {
        Console.error('Email check failed: ${response.message}');
        SnackbarService.error(response.message ?? 'Unable to verify email');
      }
    } catch (e) {
      Console.error('Email verification exception: $e');
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Send Reset OTP
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _sendResetOtp() async {
    Console.auth('Sending password reset OTP...');

    try {
      final response = await ApiService.postForm(
        ApiEndpoints.resendOtp,
        body: {
          'email': emailController.text.trim(),
          'purpose': 'password_reset',
        },
      );

      if (response.success) {
        Console.success('Reset OTP sent');
        SnackbarService.success('OTP sent to your email');

        // Navigate to OTP verification
        Get.toNamed(
          RouteNames.otpVerification,
          arguments: {
            'email': emailController.text.trim(),
            'purpose': 'password_reset',
          },
        );
      } else {
        Console.error('Send OTP failed: ${response.message}');
        SnackbarService.error(response.message ?? 'Failed to send OTP');
      }
    } catch (e) {
      Console.error('Send OTP exception: $e');
      SnackbarService.error('Failed to send OTP');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validate New Password
  // ─────────────────────────────────────────────────────────────────────────
  bool _validateNewPassword() {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      SnackbarService.error('Please enter a new password');
      return false;
    }

    if (newPassword.length < 6) {
      SnackbarService.error('Password must be at least 6 characters');
      return false;
    }

    if (newPassword != confirmPassword) {
      SnackbarService.error('Passwords do not match');
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update Password (Final Step)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updatePassword(String email, String otp) async {
    // Validate first
    if (!_validateNewPassword()) return;

    Console.divider(label: 'UPDATE PASSWORD');
    Console.auth('Updating password for: $email');

    isLoading.value = true;

    try {
      final response = await ApiService.postForm(
        ApiEndpoints.passwordReset,
        body: {
          'email': email,
          'otp_code': otp,
          'new_password': newPasswordController.text.trim(),
        },
      );

      Console.auth('Response status: ${response.statusCode}');

      if (response.success) {
        Console.success('Password updated successfully');
        SnackbarService.success('Password updated! Please login.');

        // Navigate to login
        Get.offAllNamed(RouteNames.login);
      } else {
        Console.error('Password update failed: ${response.message}');
        SnackbarService.error(response.message ?? 'Failed to update password');
      }
    } catch (e) {
      Console.error('Password update exception: $e');
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }
}
