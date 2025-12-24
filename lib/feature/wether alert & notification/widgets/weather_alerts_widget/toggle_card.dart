import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class ToggleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final bool isEnabled;
  final ValueChanged<bool>? onToggleChanged;

  const ToggleCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    required this.isEnabled,
    this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DynamicSize.medium(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color(0x2E000000),
            blurRadius: 2,
            spreadRadius: 1.3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.headLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 0.22,
                ),
              ),
              _buildToggle(context),
            ],
          ),

          if (subtitle != null) ...[
            SizedBox(height: DynamicSize.small(context)),
            Text(
              subtitle!,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlackPrimary,
              ),
            ),
          ],

          if (description != null) ...[
            SizedBox(height: DynamicSize.small(context) * 0.5),
            Text(
              description!,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
          color: isEnabled ? AppColors.textPrimary : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
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
