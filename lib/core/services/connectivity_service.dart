import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/utils/console.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CONNECTIVITY SERVICE
/// Monitors internet connectivity and shows dialog when no internet
/// ═══════════════════════════════════════════════════════════════════════════
class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find<ConnectivityService>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final isConnected = true.obs;
  bool _isDialogOpen = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialize
  // ─────────────────────────────────────────────────────────────────────────

  Future<ConnectivityService> init() async {
    Console.info('Initializing ConnectivityService...');

    // Check initial connectivity
    await _checkConnectivity();

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);

    Console.success('ConnectivityService initialized');
    return this;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Check Connectivity
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
    } catch (e) {
      Console.error('Connectivity check error: $e');
      isConnected.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // On Connectivity Changed
  // ─────────────────────────────────────────────────────────────────────────

  void _onChanged(List<ConnectivityResult> result) {
    Console.info('Connectivity changed: $result');
    _updateStatus(result);

    if (Get.context == null) return;

    if (isConnected.value) {
      _dismissDialog();
    } else {
      _showNoInternetDialog();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update Status
  // ─────────────────────────────────────────────────────────────────────────

  void _updateStatus(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.none) || result.isEmpty) {
      isConnected.value = false;
      Console.warning('No internet connection');
    } else {
      isConnected.value = true;
      Console.success('Internet connected');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Show No Internet Dialog
  // ─────────────────────────────────────────────────────────────────────────

  void _showNoInternetDialog() {
    if (_isDialogOpen) return;
    if (Get.context == null) return;

    _isDialogOpen = true;
    Console.warning('Showing no internet dialog');

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Retry Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _checkConnectivity();
                    if (isConnected.value) {
                      _dismissDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dismiss Dialog
  // ─────────────────────────────────────────────────────────────────────────

  void _dismissDialog() {
    if (_isDialogOpen) {
      _isDialogOpen = false;
      try {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      } catch (e) {
        Console.warning('Could not dismiss dialog: $e');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
