import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// OTP VERIFICATION CONTROLLER
/// Handles OTP verification for signup and password reset
/// ═══════════════════════════════════════════════════════════════════════════
class OtpVerificationController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Text Controllers
  // ─────────────────────────────────────────────────────────────────────────
  final otpController = TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────
  // Observable States
  // ─────────────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isResending = false.obs;
  final canResend = true.obs;
  final resendTimer = 0.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Validate OTP
  // ─────────────────────────────────────────────────────────────────────────
  bool _validateOtp() {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      SnackbarService.error('Please enter the OTP');
      return false;
    }

    if (otp.length != 6) {
      SnackbarService.error('Please enter a valid 6-digit OTP');
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Verify OTP (For Signup)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> verifyOtp(String name, String email, String password) async {
    // Validate first
    if (!_validateOtp()) return;

    Console.divider(label: 'OTP VERIFICATION');
    Console.auth('Verifying OTP for: $email');

    isLoading.value = true;

    try {
      // Make API request
      final response = await ApiService.postForm(
        ApiEndpoints.otpVerification,
        body: {
          'email': email,
          'otp_code': otpController.text.trim(),
          'full_name': name,
          'password': password,
        },
      );

      Console.auth('Response status: ${response.statusCode}');

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        Console.success('OTP verified! Account activated.');

        // Save user session
        StorageService.saveUserSession(
          userName: data['full_name'] ?? data['username'] ?? name,
          email: data['email'] ?? email,
          accessToken: data['access_token']?['access'] ?? '',
          refreshToken: data['access_token']?['refresh'],
          userId: data['id']?.toString(),
        );

        // Show success and navigate
        SnackbarService.success('Account verified successfully!');
        Get.offAllNamed(RouteNames.home);
      } else {
        Console.error('OTP verification failed: ${response.message}');
        SnackbarService.error(
          response.message ?? 'Invalid OTP. Please try again.',
        );
      }
    } catch (e) {
      Console.error('OTP verification exception: $e');
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Verify OTP (For Password Reset)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> verifyOtpForPasswordReset(String email) async {
    // Validate first
    if (!_validateOtp()) return;

    Console.divider(label: 'PASSWORD RESET OTP');
    Console.auth('Verifying reset OTP for: $email');

    isLoading.value = true;

    try {
      // Make API request
      final response = await ApiService.postForm(
        ApiEndpoints.otpVerification,
        body: {'email': email, 'otp_code': otpController.text.trim()},
      );

      Console.auth('Response status: ${response.statusCode}');

      if (response.success) {
        Console.success('OTP verified! Proceed to reset password.');
        SnackbarService.success('OTP verified!');

        // Navigate to password reset screen
        Get.toNamed(
          RouteNames.passwordReset,
          arguments: {'email': email, 'otp': otpController.text.trim()},
        );
      } else {
        Console.error('Reset OTP failed: ${response.message}');
        SnackbarService.error(response.message ?? 'Invalid OTP');
      }
    } catch (e) {
      Console.error('Reset OTP exception: $e');
      SnackbarService.error('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resend OTP
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> resendOtp(String email, String purpose) async {
    if (!canResend.value) {
      SnackbarService.warning(
        'Please wait ${resendTimer.value}s before resending',
      );
      return;
    }

    Console.auth('Resending OTP to: $email (purpose: $purpose)');

    isResending.value = true;

    try {
      final response = await ApiService.postForm(
        ApiEndpoints.resendOtp,
        body: {
          'email': email,
          'purpose': purpose, // 'signup' or 'password_reset'
        },
      );

      Console.auth('Resend status: ${response.statusCode}');

      if (response.success) {
        Console.success('OTP resent successfully');
        SnackbarService.success('OTP has been resent to your email');

        // Start cooldown timer
        _startResendTimer();
      } else {
        Console.error('Resend failed: ${response.message}');
        SnackbarService.error(response.message ?? 'Failed to resend OTP');
      }
    } catch (e) {
      Console.error('Resend exception: $e');
      SnackbarService.error('Something went wrong');
    } finally {
      isResending.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resend Timer (60 seconds cooldown)
  // ─────────────────────────────────────────────────────────────────────────
  void _startResendTimer() {
    canResend.value = false;
    resendTimer.value = 60;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendTimer.value--;

      if (resendTimer.value <= 0) {
        canResend.value = true;
        return false; // Stop the loop
      }
      return true; // Continue the loop
    });
  }
}
