import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;

  var isAvailable = false.obs;
  var products = <ProductDetails>[].obs;
  var premiumActive = false.obs;

  @override
  void onInit() {
    loadPremiumStatus();
    initStore();
    super.onInit();
  }

  // Load local premium status
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

    const ids = {'premium_monthly'}; // YOUR PLAYSTORE PRODUCT ID
    final response = await _iap.queryProductDetails(ids);

    products.value = response.productDetails;

    _iap.purchaseStream.listen((purchases) {
      _handlePurchase(purchases);
    });
  }

  void buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void restore() {
    _iap.restorePurchases();
  }

  void _handlePurchase(List<PurchaseDetails> purchases) async {
    for (var p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        // User now premium
        premiumActive.value = true;
        await savePremiumStatus(true);

        _iap.completePurchase(p);

        // Redirect to home
        Future.delayed(Duration(milliseconds: 300), () {
          Get.offAllNamed("/home");
        });
      }
    }
  }
}
