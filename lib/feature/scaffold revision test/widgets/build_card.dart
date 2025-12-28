import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';

class BuildCard extends StatelessWidget {
  final double width;
  final String name;
  final bool isActive;

  final void Function()? onTap;
  const BuildCard({
    super.key,
    required this.width,
    required this.name,
    required this.isActive,
    this.onTap,
  });

  @override

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: width,
        decoration: BoxDecoration(
          color: isActive ? AppColors.grey : AppColors.background,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: AppColors.withOpacity(AppColors.textBlack, 0.18),
              blurRadius: 2,
              spreadRadius: 1.3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            name,
            style: AppTextStyles.subHeadLine().copyWith(
              color: isActive ? AppColors.textWhite : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
