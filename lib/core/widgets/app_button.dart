// ============================================================================
// AppButton - Reusable Button Widget
// ============================================================================
// Purpose: Consistent button design across the app
// Replaces: SFullBtn
// Usage: AppButton(text: 'Login', onPressed: () {})
// ============================================================================

import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';

/// Reusable full-width button widget
class AppButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Tap handler
  final VoidCallback? onPressed;

  /// Button background color
  final Color? backgroundColor;

  /// Button text color
  final Color? textColor;

  /// Button height
  final double? height;

  /// Button width (null = full width)
  final double? width;

  /// Border radius
  final double? borderRadius;

  /// Show loading indicator
  final bool isLoading;

  /// Loading text (shows when isLoading = true)
  final String? loadingText;

  /// Button elevation
  final double? elevation;

  /// Icon (optional)
  final IconData? icon;

  /// Icon position (left or right)
  final IconPosition iconPosition;

  /// Border (optional)
  final BorderSide? border;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.width,
    this.borderRadius = 10,
    this.isLoading = false,
    this.loadingText,
    this.elevation = 0,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.textPrimary,
          foregroundColor: textColor ?? AppColors.primary,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            side: border ?? BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  /// Build button content (text, icon, loading)
  Widget _buildButtonContent() {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.primary,
              ),
            ),
          ),
          if (loadingText != null) ...[
            const SizedBox(width: 12),
            Text(loadingText!, style: AppTextStyles.headLine()),
          ],
        ],
      );
    }

    // With icon
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconPosition == IconPosition.left) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(text, style: AppTextStyles.headLine()),
          if (iconPosition == IconPosition.right) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ],
      );
    }

    // Text only
    return Text(text, style: AppTextStyles.headLine());
  }
}

// ============================================================================
// AppButton Variants - Pre-configured buttons
// ============================================================================

/// Primary button (black background, yellow text)
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final IconData? icon;

  const AppPrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.textPrimary,
      textColor: AppColors.primary,
      isLoading: isLoading,
      loadingText: loadingText,
      icon: icon,
    );
  }
}

/// Secondary button (yellow background, black text)
class AppSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final IconData? icon;

  const AppSecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      textColor: AppColors.textPrimary,
      isLoading: isLoading,
      loadingText: loadingText,
      icon: icon,
    );
  }
}

/// Outline button (transparent with border)
class AppOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final bool isLoading;
  final IconData? icon;

  const AppOutlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? AppColors.textPrimary,
      border: BorderSide(color: borderColor ?? AppColors.border, width: 2),
      elevation: 0,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

/// Text button (no background)
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;

  const AppTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text, style: AppTextStyles.headLine()),
    );
  }
}

/// Icon position enum
enum IconPosition { left, right }

// ============================================================================
// Usage Examples
// ============================================================================
//
// 1. Basic button:
// ```dart
// AppButton(
//   text: 'Login',
//   onPressed: () => controller.login(),
// )
// ```
//
// 2. Loading state:
// ```dart
// Obx(() => AppButton(
//   text: 'Login',
//   onPressed: () => controller.login(),
//   isLoading: controller.isLoading.value,
//   loadingText: 'Logging in...',
// ))
// ```
//
// 3. With icon:
// ```dart
// AppButton(
//   text: 'Sign up with Google',
//   icon: Icons.login,
//   onPressed: () {},
// )
// ```
//
// 4. Primary button variant:
// ```dart
// AppPrimaryButton(
//   text: 'Login',
//   onPressed: () {},
// )
// ```
//
// 5. Outline button:
// ```dart
// AppOutlineButton(
//   text: 'Cancel',
//   onPressed: () => Get.back(),
// )
// ```
//
// 6. Custom colors:
// ```dart
// AppButton(
//   text: 'Delete',
//   backgroundColor: AppColors.error,
//   textColor: Colors.white,
//   onPressed: () => deleteItem(),
// )
// ```
//
// ============================================================================
