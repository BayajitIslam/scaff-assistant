import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SOCIAL BUTTON
/// Button for social login (Google, Apple, etc.)
/// Note: Wrap with Expanded when using in a Row
/// ═══════════════════════════════════════════════════════════════════════════
class SocialButton extends StatelessWidget {
  final String text;
  final String image;
  final VoidCallback? onTap;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.text,
    required this.image,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  image,
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.login, size: 20);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GOOGLE SIGN IN BUTTON
/// Pre-configured Google sign-in button
/// ═══════════════════════════════════════════════════════════════════════════
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const GoogleSignInButton({super.key, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.g_mobiledata, size: 24);
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// APPLE SIGN IN BUTTON
/// Pre-configured Apple sign-in button
/// ═══════════════════════════════════════════════════════════════════════════
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const AppleSignInButton({super.key, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Continue with Apple',
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
    );
  }
}
