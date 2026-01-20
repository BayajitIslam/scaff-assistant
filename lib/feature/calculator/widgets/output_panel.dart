import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/calculator/widgets/inner_shadow_container.dart';

class OutputPanelItem {
  final String label;
  final String value;

  OutputPanelItem({required this.label, required this.value});
}

class OutputPanel extends StatelessWidget {
  final String title;
  final List<OutputPanelItem> items;
  final String? totalLabel;
  final String? totalValue;

  const OutputPanel({
    super.key,
    required this.title,
    required this.items,
    this.totalLabel,
    this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            title,
            style: AppTextStyles.headLine().copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Items Container with inner shadow on all 4 sides
        InnerShadowContainer(
          borderRadius: 5,
          backgroundColor: Colors.white,
          shadowColor: Colors.black,
          shadowSpread: 10,
          padding: EdgeInsets.all(DynamicSize.medium(context)),
          child: Column(
            children: [
              ...items.map((item) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: DynamicSize.small(context) * 0.5,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bullet Point
                      Container(
                        margin: EdgeInsets.only(
                          top: 6,
                        ), // Align with first line of text
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: DynamicSize.horizontalMedium(context)),

                      // Label
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTextStyles.subHeadLine().copyWith(
                            color: AppColors.textPrimary,
                            height: 1.2, // Improved line height
                          ),
                        ),
                      ),

                      SizedBox(width: 8), // Spacing between label and value
                      // Value
                      Expanded(
                        flex:
                            2, // Give more space to value if needed, or just let it wrap
                        child: Text(
                          item.value,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.subHeadLine().copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            height: 1.2, // Match line height
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Divider and Total inside container
              if (totalLabel != null && totalValue != null) ...[
                SizedBox(height: DynamicSize.small(context)),
                Divider(color: AppColors.border, thickness: 1),
                SizedBox(height: DynamicSize.small(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalLabel!,
                      style: AppTextStyles.headLine().copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      totalValue!,
                      style: AppTextStyles.subHeadLine().copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
