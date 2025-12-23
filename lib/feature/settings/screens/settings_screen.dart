import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/icon_paths.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/feature/auth/controllers/logout_controller.dart';
import 'package:scaffassistant/routing/route_name.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SETTINGS SCREEN
/// User profile and app settings
/// ═══════════════════════════════════════════════════════════════════════════
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize logout controller
    final logoutController = Get.put(LogoutController());

    return Scaffold(
      backgroundColor: Colors.white,

      // ─────────────────────────────────────────────────────────────────────
      // App Bar
      // ─────────────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Settings', style: AppTextStyles.headLine()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Body
      // ─────────────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info Card
            _buildUserInfoCard(),

            const SizedBox(height: 24),

            // Settings List
            _buildSettingsList(logoutController),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // User Info Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUserInfoCard() {
    final userName = StorageService.getUserName();
    final userEmail = StorageService.getUserEmail();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.textPrimary,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: AppTextStyles.headLine().copyWith(
                fontSize: 26,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isNotEmpty ? userName : 'User',
                  style: AppTextStyles.subHeadLine()
                      .copyWith(color: AppColors.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail.isNotEmpty ? userEmail : 'email@example.com',
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Settings List
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSettingsList(LogoutController logoutController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Email (non-editable)
          _SettingsTile(
            icon: IconPaths.email,
            title: 'Email',
            subtitle: StorageService.getUserEmail(),
            onTap: () {
              Get.snackbar(
                'Info',
                'Email cannot be changed',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Terms & Privacy
          _SettingsTile(
            icon: IconPaths.shield,
            title: 'Terms and Privacy Policy',
            onTap: () => Get.toNamed(RouteNames.tramsAndPrivacy),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Subscription (if applicable)
          _SettingsTile(
            icon: 'assets/icons/subscription.png',
            iconData: Icons.star_outline,
            title: 'Subscription',
            subtitle: StorageService.isPremium() ? 'Premium' : 'Free',
            onTap: () => Get.toNamed(RouteNames.subscription),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Logout
          Obx(
            () => _SettingsTile(
              icon: IconPaths.exit,
              title: logoutController.isLoading.value
                  ? 'Logging out...'
                  : 'Logout',
              titleColor: AppColors.error,
              onTap: () => logoutController.logoutWithConfirmation(),
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// SETTINGS TILE
/// Reusable settings list item
/// ═══════════════════════════════════════════════════════════════════════════
class _SettingsTile extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    this.icon,
    this.iconData,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIcon(),
      title: Text(
        title,
        style: AppTextStyles.subHeadLine().copyWith(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }

  Widget _buildIcon() {
    if (iconData != null) {
      return Icon(iconData, color: AppColors.textPrimary, size: 24);
    }

    if (icon != null) {
      return Image.asset(
        icon!,
        width: 24,
        height: 24,
        color: AppColors.textPrimary,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.settings, color: AppColors.textPrimary);
        },
      );
    }

    return const Icon(Icons.settings, color: AppColors.textPrimary);
  }
}
