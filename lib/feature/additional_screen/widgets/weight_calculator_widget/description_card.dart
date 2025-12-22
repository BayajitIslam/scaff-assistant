import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class DescriptionCard extends StatelessWidget {
  final String text;

  const DescriptionCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DynamicSize.medium(context)),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FF9F),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: AppTextStyles.subHeadLine().copyWith(
          color: AppColors.textBlackPrimary,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }
}
