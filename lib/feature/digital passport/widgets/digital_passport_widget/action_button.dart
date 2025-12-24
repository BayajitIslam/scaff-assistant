import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: DynamicSize.horizontalMedium(context) * 1.5,
          vertical: DynamicSize.small(context),
        ),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.textBlackPrimary : Colors.white,
          borderRadius: BorderRadius.circular(8),

          boxShadow: [
            BoxShadow(
              color: const Color(0x2E000000),
              blurRadius: 2,
              spreadRadius: 1.3,
            ),
          ],
          // border: Border.all(
          //   color: isPrimary ? SColor.textBlackPrimary : SColor.borderColor,
          //   width: 1,
          // ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isPrimary ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: DynamicSize.horizontalSmall(context)),
            Text(
              label,
              style: AppTextStyles.headLine().copyWith(
                color: isPrimary ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
