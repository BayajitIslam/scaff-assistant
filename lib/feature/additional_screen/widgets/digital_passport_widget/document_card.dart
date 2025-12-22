import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget child;

  const DocumentCard({
    super.key,
    required this.title,
    this.onEdit,
    this.onDelete,
    required this.child,
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
          // Title row with action icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.headLine().copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.textBlackPrimary,
                      ),
                    ),
                  if (onDelete != null) ...[
                    SizedBox(width: DynamicSize.horizontalMedium(context)),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          SizedBox(height: DynamicSize.medium(context)),

          // Document content
          child,
        ],
      ),
    );
  }
}
