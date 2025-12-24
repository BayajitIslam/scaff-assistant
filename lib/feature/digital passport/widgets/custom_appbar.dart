import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
                size: 28,
              ),
            ),

            // Title
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: AppTextStyles.headLine().copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // Actions or placeholder for symmetry
            if (actions != null)
              Row(children: actions!)
            else
              SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}
