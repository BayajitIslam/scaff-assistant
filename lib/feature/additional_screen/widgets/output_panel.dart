import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/inner_shadow_container.dart';

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
            style: STextTheme.headLine().copyWith(
              color: SColor.textPrimary,
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
                    children: [
                      // Bullet Point
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: SColor.textPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: DynamicSize.horizontalMedium(context)),

                      // Label
                      Expanded(
                        child: Text(
                          item.label,
                          style: STextTheme.subHeadLine().copyWith(
                            color: SColor.textPrimary,
                            height: 0.22,
                          ),
                        ),
                      ),

                      // Value
                      Text(
                        item.value,
                        style: STextTheme.subHeadLine().copyWith(
                          color: SColor.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Divider and Total inside container
              if (totalLabel != null && totalValue != null) ...[
                SizedBox(height: DynamicSize.small(context)),
                Divider(color: SColor.borderColor, thickness: 1),
                SizedBox(height: DynamicSize.small(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalLabel!,
                      style: STextTheme.headLine().copyWith(
                        color: SColor.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      totalValue!,
                      style: STextTheme.subHeadLine().copyWith(
                        color: SColor.textPrimary,
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
