import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class TubeTypeSelector extends StatelessWidget {
  final String label;
  final String value1;
  final String value2;
  final bool isSecondSelected;
  final ValueChanged<bool>? onToggleChanged;

  const TubeTypeSelector({
    super.key,
    required this.label,
    required this.value1,
    required this.value2,
    required this.isSecondSelected,
    this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DynamicSize.small(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlackPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Right side with left border
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(),
              padding: EdgeInsets.only(
                left: DynamicSize.horizontalMedium(context),
              ),
              child: Column(
                children: [
                  // First row - 3.2 mm
                  _buildOptionRow(
                    context: context,
                    value: value1,
                    isSelected: !isSecondSelected,
                    onTap: () => onToggleChanged?.call(false),
                  ),

                  SizedBox(height: DynamicSize.small(context)),

                  // Second row - 4.0 mm
                  _buildOptionRow(
                    context: context,
                    value: value2,
                    isSelected: isSecondSelected,
                    onTap: () => onToggleChanged?.call(true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required BuildContext context,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Value text
          Text(
            value,
            style: AppTextStyles.subHeadLine().copyWith(
              color: AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),

          SizedBox(width: DynamicSize.horizontalMedium(context)),

          // Toggle
          _buildToggle(context, isSelected, onTap),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context, bool isOn, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 31,
        height: 16,
        decoration: BoxDecoration(
          color: isOn ? AppColors.textPrimary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 11,
            height: 11,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isOn ? AppColors.primary : Colors.white,
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
