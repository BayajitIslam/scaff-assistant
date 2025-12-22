import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class AlertItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String trigger;
  final String message;
  final bool isEnabled;
  final ValueChanged<bool>? onToggleChanged;

  const AlertItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trigger,
    required this.message,
    required this.isEnabled,
    this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DynamicSize.small(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with icon and toggle
          Row(
            children: [
              // Icon
              Icon(icon, color: iconColor, size: 18),

              SizedBox(width: DynamicSize.horizontalSmall(context)),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textBlackPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Toggle
              _buildToggle(context),
            ],
          ),

          // Trigger text
          Padding(
            padding: EdgeInsets.only(
              left: 18 + DynamicSize.horizontalSmall(context),
              top: DynamicSize.small(context) * 0.5,
            ),
            child: Text(
              trigger,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Message text
          Padding(
            padding: EdgeInsets.only(
              left: 18 + DynamicSize.horizontalSmall(context),
              top: DynamicSize.small(context) * 0.5,
            ),
            child: Text(
              message,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlackPrimary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggleChanged?.call(!isEnabled),
      child: Container(
        width: 30,
        height: 16,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.textPrimary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 11,
            height: 11,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
