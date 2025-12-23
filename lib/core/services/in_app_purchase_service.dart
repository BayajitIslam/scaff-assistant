import 'dart:async';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// IN-APP PURCHASE SERVICE
/// Handles subscription purchases for iOS and Android
/// ═══════════════════════════════════════════════════════════════════════════
class InAppPurchaseService extends GetxService {
  // ─────────────────────────────────────────────────────────────────────────
  // Singleton Instance
  // ─────────────────────────────────────────────────────────────────────────

  static InAppPurchaseService get to => Get.find<InAppPurchaseService>();

  // ─────────────────────────────────────────────────────────────────────────
  // Product IDs (Configure these in App Store Connect / Google Play Console)
  // ─────────────────────────────────────────────────────────────────────────

  static const String monthlyProductId = 'scaff_premium_monthly';
  static const String yearlyProductId = 'scaff_premium_yearly';

  static const Set<String> _productIds = {monthlyProductId, yearlyProductId};

  // ─────────────────────────────────────────────────────────────────────────
  // Variables
  // ─────────────────────────────────────────────────────────────────────────

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Observable states
  final RxBool isAvailable = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPurchasing = false.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxList<PurchaseDetails> purchases = <PurchaseDetails>[].obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialize Service
  // ─────────────────────────────────────────────────────────────────────────

  Future<InAppPurchaseService> init() async {
    Console.divider(label: 'IN-APP PURCHASE INIT');

    // Check if store is available
    isAvailable.value = await _inAppPurchase.isAvailable();
    Console.info('Store available: ${isAvailable.value}');

    if (!isAvailable.value) {
      Console.warning('In-app purchases not available on this device');
      return this;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: _onPurchaseStreamDone,
      onError: _onPurchaseStreamError,
    );

    // Load products
    await loadProducts();

    Console.success('In-app purchase service initialized');
    Console.divider();

    return this;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Load Products from Store
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    Console.info('Loading products...');
    isLoading.value = true;

    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        Console.warning('Products not found: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        Console.error('Error loading products: ${response.error}');
        return;
      }

      products.value = response.productDetails;
      Console.success('Loaded ${products.length} products');

      for (var product in products) {
        Console.info('Product: ${product.id} - ${product.price}');
      }
    } catch (e) {
      Console.error('Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle Purchase Updates
  // ─────────────────────────────────────────────────────────────────────────

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    Console.divider(label: 'PURCHASE UPDATE');

    for (var purchaseDetails in purchaseDetailsList) {
      Console.info('Purchase status: ${purchaseDetails.status}');
      Console.info('Product ID: ${purchaseDetails.productID}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePendingPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handlePurchaseError(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchaseDetails);
          break;
      }
    }

    Console.divider();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle Pending Purchase
  // ─────────────────────────────────────────────────────────────────────────

  void _handlePendingPurchase(PurchaseDetails purchaseDetails) {
    Console.info('Purchase pending...');
    isPurchasing.value = true;
    SnackbarService.loading('Processing purchase...');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle Successful Purchase
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleSuccessfulPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    Console.success('Purchase successful!');

    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
      Console.success('Purchase completed');
    }

    // Update premium status
    StorageService.setIsPremium(true);
    Console.storage('Premium status saved');

    isPurchasing.value = false;

    // Show success message
    SnackbarService.success('Welcome to Premium! 🎉');

    // Navigate to home
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offAllNamed(RouteNames.home);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle Purchase Error
  // ─────────────────────────────────────────────────────────────────────────

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    Console.error('Purchase error: ${purchaseDetails.error}');
    isPurchasing.value = false;

    String errorMessage = 'Purchase failed. Please try again.';

    if (purchaseDetails.error != null) {
      errorMessage = purchaseDetails.error!.message;
    }

    SnackbarService.error(errorMessage);

    // Complete purchase to clear it
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle Canceled Purchase
  // ─────────────────────────────────────────────────────────────────────────

  void _handleCanceledPurchase(PurchaseDetails purchaseDetails) {
    Console.warning('Purchase canceled by user');
    isPurchasing.value = false;
    SnackbarService.info('Purchase canceled');

    // Complete purchase to clear it
    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stream Callbacks
  // ─────────────────────────────────────────────────────────────────────────

  void _onPurchaseStreamDone() {
    Console.info('Purchase stream closed');
    _subscription?.cancel();
  }

  void _onPurchaseStreamError(dynamic error) {
    Console.error('Purchase stream error: $error');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Buy Product
  // ─────────────────────────────────────────────────────────────────────────

  /// Purchase a product by ID
  Future<bool> buyProduct(String productId) async {
    Console.divider(label: 'BUYING PRODUCT');
    Console.info('Product ID: $productId');

    if (!isAvailable.value) {
      Console.error('Store not available');
      SnackbarService.error('Store not available on this device');
      return false;
    }

    if (isPurchasing.value) {
      Console.warning('Purchase already in progress');
      return false;
    }

    // Find the product
    final ProductDetails? product = products.firstWhereOrNull(
      (p) => p.id == productId,
    );

    if (product == null) {
      Console.error('Product not found: $productId');
      SnackbarService.error('Product not found');
      return false;
    }

    try {
      isPurchasing.value = true;

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      Console.info('Initiating purchase...');

      // For subscriptions, use buyNonConsumable
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      Console.info('Purchase initiated: $success');
      return success;
    } catch (e) {
      Console.error('Purchase error: $e');
      isPurchasing.value = false;
      SnackbarService.error('Failed to initiate purchase');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Buy Monthly Subscription
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> buyMonthly() async {
    return await buyProduct(monthlyProductId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Buy Yearly Subscription
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> buyYearly() async {
    return await buyProduct(yearlyProductId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Restore Purchases
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    Console.divider(label: 'RESTORE PURCHASES');

    if (!isAvailable.value) {
      Console.error('Store not available');
      SnackbarService.error('Store not available');
      return;
    }

    try {
      isLoading.value = true;
      SnackbarService.loading('Restoring purchases...');

      await _inAppPurchase.restorePurchases();

      Console.success('Restore initiated');
    } catch (e) {
      Console.error('Restore failed: $e');
      SnackbarService.error('Failed to restore purchases');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Get Product by ID
  // ─────────────────────────────────────────────────────────────────────────

  ProductDetails? getProduct(String productId) {
    return products.firstWhereOrNull((p) => p.id == productId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Get Monthly Product
  // ─────────────────────────────────────────────────────────────────────────

  ProductDetails? get monthlyProduct => getProduct(monthlyProductId);

  // ─────────────────────────────────────────────────────────────────────────
  // Get Yearly Product
  // ─────────────────────────────────────────────────────────────────────────

  ProductDetails? get yearlyProduct => getProduct(yearlyProductId);

  // ─────────────────────────────────────────────────────────────────────────
  // Get Product Price
  // ─────────────────────────────────────────────────────────────────────────

  String getProductPrice(String productId) {
    final product = getProduct(productId);
    return product?.price ?? '--';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Get Monthly Price
  // ─────────────────────────────────────────────────────────────────────────

  String get monthlyPrice => getProductPrice(monthlyProductId);

  // ─────────────────────────────────────────────────────────────────────────
  // Get Yearly Price
  // ─────────────────────────────────────────────────────────────────────────

  String get yearlyPrice => getProductPrice(yearlyProductId);

  // ─────────────────────────────────────────────────────────────────────────
  // Check Premium Status
  // ─────────────────────────────────────────────────────────────────────────

  bool get isPremium => StorageService.isPremium();

  // ─────────────────────────────────────────────────────────────────────────
  // Dispose
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    Console.info('Closing InAppPurchaseService');
    _subscription?.cancel();
    super.onClose();
  }
}
