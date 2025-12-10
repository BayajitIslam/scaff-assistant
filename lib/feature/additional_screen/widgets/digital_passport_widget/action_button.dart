import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

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
          color: isPrimary ? SColor.textBlackPrimary : Colors.white,
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
              color: isPrimary ? SColor.primary : SColor.textSecondary,
            ),
            SizedBox(width: DynamicSize.horizontalSmall(context)),
            Text(
              label,
              style: STextTheme.headLine().copyWith(
                color: isPrimary ? SColor.primary : SColor.textSecondary,
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
