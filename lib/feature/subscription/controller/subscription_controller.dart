import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/services/storage_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUBSCRIPTION CONTROLLER
/// Handles in-app purchases and subscription management
/// ═══════════════════════════════════════════════════════════════════════════
class SubscriptionController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // In-App Purchase Instance
  // ─────────────────────────────────────────────────────────────────────────

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // ─────────────────────────────────────────────────────────────────────────
  // Product IDs (Configure in App Store Connect / Google Play Console)
  // ─────────────────────────────────────────────────────────────────────────

  static const Set<String> _productIds = {'premium_monthly', 'elite_yearly'};

  // ─────────────────────────────────────────────────────────────────────────
  // Observable States
  // ─────────────────────────────────────────────────────────────────────────

  final isInitializing = true.obs;
  final isAvailable = true.obs;
  final isLoading = false.obs;
  final isPurchasing = false.obs;
  final isSubscribed = false.obs;
  final products = <ProductDetails>[].obs;
  final errorMessage = ''.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _initStore();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Initialize Store
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initStore() async {
    Console.divider(label: 'IAP INITIALIZATION');
    isInitializing.value = true;
    errorMessage.value = '';

    try {
      final available = await _iap.isAvailable();
      isAvailable.value = available;

      if (!available) {
        Console.warning('In-App Purchase not available');
        errorMessage.value = 'Store not available on this device';
        isInitializing.value = false;
        return;
      }

      Console.success('IAP available');

      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          Console.error('Purchase stream error: $error');
        },
      );

      await _loadProducts();

      Console.success('IAP initialized');
    } catch (e) {
      Console.error('IAP initialization error: $e');
      errorMessage.value = 'Failed to initialize store';
      isAvailable.value = false;
    } finally {
      isInitializing.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Check Subscription on App Start (Static method)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<bool> checkSubscriptionOnStart() async {
    Console.divider(label: 'SUBSCRIPTION CHECK');

    final iap = InAppPurchase.instance;

    try {
      final available = await iap.isAvailable();
      if (!available) {
        Console.warning('Store not available - using cached status');
        return StorageService.isPremium();
      }

      bool hasActiveSubscription = false;
      // final completer = Completer<bool>();

      // Listen for purchase updates
      final subscription = iap.purchaseStream.listen((purchases) {
        for (var purchase in purchases) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            hasActiveSubscription = true;
            Console.success('Active subscription: ${purchase.productID}');

            if (purchase.pendingCompletePurchase) {
              iap.completePurchase(purchase);
            }
          }
        }
      });

      // Restore to check current status
      await iap.restorePurchases();

      // Wait for stream
      await Future.delayed(const Duration(seconds: 2));

      await subscription.cancel();

      StorageService.setIsPremium(hasActiveSubscription);

      Console.info('Subscription active: $hasActiveSubscription');
      Console.divider();

      return hasActiveSubscription;
    } catch (e) {
      Console.error('Subscription check error: $e');
      return StorageService.isPremium();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Check & Navigate After Login
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> checkAndNavigateAfterLogin() async {
    Console.info('Checking subscription after login...');

    final hasSubscription = await checkSubscriptionOnStart();

    if (hasSubscription) {
      Console.success('Has subscription → Home');
      Get.offAllNamed(RouteNames.home);
    } else {
      Console.warning('No subscription → Subscription Screen');
      Get.offAllNamed(RouteNames.subscription);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Show Subscription Expired Dialog
  // ─────────────────────────────────────────────────────────────────────────

  static void showSubscriptionExpiredDialog() {
    if (Get.context == null) return;

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
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Subscription Expired',
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
                'Your subscription has expired. Please renew to continue using the app.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Subscribe Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.offAllNamed(RouteNames.subscription);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Go to Subscription',
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
  // Load Products
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadProducts() async {
    Console.info('Loading products...');
    isLoading.value = true;

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        _productIds,
      );

      if (response.notFoundIDs.isNotEmpty) {
        Console.warning('Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        Console.error('Query error: ${response.error}');
        errorMessage.value = 'Failed to load products';
        return;
      }

      products.value = response.productDetails;
      Console.success('Loaded ${products.length} products');

      for (var product in products) {
        Console.info('Product: ${product.id} - ${product.price}');
      }

      if (products.isEmpty) {
        errorMessage.value = 'No subscription plans available';
      }
    } catch (e) {
      Console.error('Load products error: $e');
      errorMessage.value = 'Failed to load products';
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Refresh Products
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refreshProducts() async {
    Console.info('Refreshing products...');
    errorMessage.value = '';

    if (!isAvailable.value) {
      await _initStore();
    } else {
      await _loadProducts();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle Purchase Updates
  // ─────────────────────────────────────────────────────────────────────────

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    Console.divider(label: 'PURCHASE UPDATE');

    for (var purchase in purchaseDetailsList) {
      Console.info(
        'Status: ${purchase.status} | Product: ${purchase.productID}',
      );

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _handlePending();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccess(purchase);
          break;
        case PurchaseStatus.error:
          _handleError(purchase);
          break;
        case PurchaseStatus.canceled:
          _handleCanceled();
          break;
      }
    }

    Console.divider();
  }

  void _handlePending() {
    Console.info('Purchase pending...');
    isPurchasing.value = true;
  }

  Future<void> _handleSuccess(PurchaseDetails purchase) async {
    Console.success('Purchase successful!');

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
      Console.success('Purchase completed');
    }

    isSubscribed.value = true;
    StorageService.setIsPremium(true);
    StorageService.setIsFirstTimeUser(false);
    isPurchasing.value = false;

    SnackbarService.success('Welcome to Premium! 🎉');

    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed(RouteNames.home);
  }

  void _handleError(PurchaseDetails purchase) {
    Console.error('Purchase error: ${purchase.error?.message}');
    isPurchasing.value = false;

    final errorMsg = purchase.error?.message ?? 'Purchase failed';
    SnackbarService.error(errorMsg);

    if (purchase.pendingCompletePurchase) {
      _iap.completePurchase(purchase);
    }
  }

  void _handleCanceled() {
    Console.warning('Purchase canceled');
    isPurchasing.value = false;
    SnackbarService.info('Purchase canceled');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Buy Product
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> buyProduct(ProductDetails product) async {
    Console.divider(label: 'PURCHASE');
    Console.info('Buying: ${product.id} - ${product.price}');

    if (isPurchasing.value) {
      Console.warning('Purchase already in progress');
      return;
    }

    isPurchasing.value = true;

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      Console.info('Purchase initiated: $success');
    } catch (e) {
      Console.error('Buy error: $e');
      isPurchasing.value = false;
      SnackbarService.error('Failed to initiate purchase');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Restore Purchases
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    Console.divider(label: 'RESTORE PURCHASES');

    if (!isAvailable.value) {
      SnackbarService.error('Store not available');
      return;
    }

    try {
      isLoading.value = true;
      SnackbarService.info('Restoring purchases...');

      await _iap.restorePurchases();

      Console.success('Restore request sent');
    } catch (e) {
      Console.error('Restore error: $e');
      SnackbarService.error('Failed to restore purchases');
    } finally {
      isLoading.value = false;
    }
  }
}
