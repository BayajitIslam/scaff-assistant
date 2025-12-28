import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textBlackPrimary,
          foregroundColor: AppColors.textSecondary,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: AppColors.primary,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppColors.textBlackPrimary,

                  size: 30,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.headLine().copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
