import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/image_paths.dart';
import 'package:scaffassistant/feature/subscription/controller/subscription_controller.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUBSCRIPTION SCREEN
/// Displays available subscription plans for purchase
/// ═══════════════════════════════════════════════════════════════════════════
class SubscriptionScreen extends StatelessWidget {
  SubscriptionScreen({super.key});

  final controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          "Choose a Subscription",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Skip button
          TextButton(
            onPressed: () {
              Get.toNamed(RouteNames.home);
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() => _buildBody()),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build Body
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    // Show loading while initializing
    if (controller.isInitializing.value) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.textPrimary),
            SizedBox(height: 16),
            Text(
              'Loading subscription plans...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Store not available or error
    if (!controller.isAvailable.value || controller.errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    // No products found
    if (controller.products.isEmpty) {
      return _buildEmptyState();
    }

    // Products loaded - show list
    return _buildContent();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Error State
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Store not available',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshProducts(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Continue without subscription',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty State
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No subscription plans available',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshProducts(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Refresh',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Continue without subscription',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Content
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Logo
          _buildLogo(),

          const SizedBox(height: 30),

          // Products List
          Expanded(child: _buildProductsList()),

          const SizedBox(height: 10),

          // Restore Purchases
          _buildRestoreButton(),

          // Info Text
          _buildInfoText(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logo
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          ImagePaths.logo,
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.workspace_premium,
              size: 80,
              color: AppColors.textPrimary,
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlock Premium Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Get access to all features with a subscription',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Products List
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProductsList() {
    return ListView.separated(
      itemCount: controller.products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final product = controller.products[index];
        return _buildProductCard(product);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Product Card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProductCard(ProductDetails product) {
    final isMonthly = product.id.contains('monthly');

    return Card(
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isMonthly
            ? BorderSide.none
            : const BorderSide(color: Colors.amber, width: 2),
      ),
      elevation: 4,
      child: Stack(
        children: [
          // Best Value Badge
          if (!isMonthly)
            Positioned(
              top: 0,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  product.title.replaceAll(RegExp(r'\(.*?\)'), '').trim(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  product.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Price & Subscribe Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isMonthly ? 'per month' : 'per year',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMonthly
                              ? AppColors.textPrimary
                              : Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        onPressed: controller.isPurchasing.value
                            ? null
                            : () => controller.buyProduct(product),
                        child: controller.isPurchasing.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Subscribe",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Restore Button
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildRestoreButton() {
    return Obx(
      () => TextButton(
        onPressed: controller.isLoading.value
            ? null
            : () => controller.restorePurchases(),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textSecondary,
                ),
              )
            : const Text(
                "Restore Purchases",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Info Text
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildInfoText() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          "By subscribing, you agree to our Terms of Service and Privacy Policy.\nSubscription automatically renews unless canceled.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
