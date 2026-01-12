import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class InputPanelCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Widget? trailing;

  const InputPanelCard({
    super.key,
    this.title,
    required this.children,
    this.trailing,
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
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: AppTextStyles.headLine().copyWith(
                    color: AppColors.textBlackPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: DynamicSize.medium(context)),
          ],
          ...children,
        ],
      ),
    );
  }
}
