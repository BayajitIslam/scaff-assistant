import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';

class OptionTile extends StatelessWidget {
  final bool isSelected;
  final String option;
  final void Function()? onTap;
  const OptionTile({
    super.key,
    required this.option,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: AppColors.withOpacity(AppColors.textBlack, 0.18),
              blurRadius: 2,
              spreadRadius: 1.3,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            //Is Selected icon
            _buildRadioButton(isSelected),

            //Option tile content
            SizedBox(width: 15),
            Text(
              option,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton(bool isActive) {
    return Container(
      width: 16.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: isActive ? AppColors.textBlackPrimary : AppColors.grey,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.textBlack : Colors.transparent,
        ),
      ),
    );
  }
}
