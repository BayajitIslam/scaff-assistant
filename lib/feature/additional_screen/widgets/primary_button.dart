import 'package:flutter/material.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
          backgroundColor: SColor.textBlackPrimary,
          foregroundColor: SColor.textSecondary,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBackgroundColor: SColor.primary,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: SColor.textBlackPrimary,

                  size: 30,
                ),
              )
            : Text(
                text,
                style: STextTheme.headLine().copyWith(
                  color: SColor.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
