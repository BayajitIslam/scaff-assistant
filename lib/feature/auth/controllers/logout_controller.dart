import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/storage_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOGOUT CONTROLLER
/// Handles user logout with API call and local cleanup
/// ═══════════════════════════════════════════════════════════════════════════
class LogoutController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Observable States
  // ─────────────────────────────────────────────────────────────────────────
  final isLoading = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    Console.divider(label: 'LOGOUT');
    Console.auth('Logging out user...');

    isLoading.value = true;

    try {
      // Call logout API
      final response = await ApiService.postFormAuth(
        ApiEndpoints.logout,
        body: {},
      );

      Console.auth('Response status: ${response.statusCode}');

      if (response.success) {
        Console.success('Logout successful');
        _clearAndNavigate();
      } else {
        // Even if API fails, clear local data and logout
        Console.warning('Logout API failed, clearing local data anyway');
        _clearAndNavigate();
      }
    } catch (e) {
      Console.error('Logout exception: $e');
      // Still logout even on exception
      _clearAndNavigate();
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logout with Confirmation
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> logoutWithConfirmation() async {
    final confirmed = await SnackbarService.confirm(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      isDanger: true,
    );

    if (confirmed) {
      await logout();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear Data and Navigate to Login
  // ─────────────────────────────────────────────────────────────────────────
  void _clearAndNavigate() {
    // Clear all user data
    StorageService.clearUserSession();

    // Show success message
    SnackbarService.success('Logged out successfully');

    // Navigate to login screen
    Get.offAllNamed(RouteNames.login);
  }
}
