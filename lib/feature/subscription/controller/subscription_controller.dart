import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scaffassistant/routing/route_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;

  var isAvailable = false.obs;
  RxList<ProductDetails> products = RxList<ProductDetails>([]);
  var premiumActive = false.obs;

  // We will store a BuildContext to show native SnackBar
  late BuildContext context;

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  @override
  void onInit() {
    loadPremiumStatus();
    initStore();
    super.onInit();
  }

  Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    premiumActive.value = prefs.getBool('premium') ?? false;
  }

  Future<void> savePremiumStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('premium', value);
  }

  Future<void> initStore() async {
    final available = await _iap.isAvailable();
    isAvailable.value = available;
    if (!available) return;

    const idMonthly = {'premium_monthly'};
    const idYearly = {'elite_yearly'};

    final monthlyResponse = await _iap.queryProductDetails(idMonthly);
    final yearlyResponse = await _iap.queryProductDetails(idYearly);
    products.value = [
      ...monthlyResponse.productDetails,
      ...yearlyResponse.productDetails
    ];

    _iap.purchaseStream.listen((purchases) {
      _handlePurchase(purchases);
    });
  }

  void buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    _showSnackBar("Processing purchase...");
  }

  void restore() async {
    await _iap.restorePurchases();
    _showSnackBar("Restoring purchases...");
  }

  void _handlePurchase(List<PurchaseDetails> purchases) async {
    for (var p in purchases) {
      if (p.status == PurchaseStatus.purchased) {
        premiumActive.value = true;
        await savePremiumStatus(true);
        _iap.completePurchase(p);
        _showSnackBar("Purchase successful!");

        Future.delayed(Duration(milliseconds: 300), () {
          Get.offAllNamed(RouteNames.home);
        });
      } else if (p.status == PurchaseStatus.restored) {
        premiumActive.value = true;
        await savePremiumStatus(true);
        _iap.completePurchase(p);
        _showSnackBar("Purchase restored!");
        Future.delayed(Duration(milliseconds: 300), () {
          Get.offAllNamed(RouteNames.home);
        });
      } else if (p.status == PurchaseStatus.error) {
        _showSnackBar("Purchase failed: ${p.error?.message}");
      }
    }
  }

  void _showSnackBar(String message) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }
}
