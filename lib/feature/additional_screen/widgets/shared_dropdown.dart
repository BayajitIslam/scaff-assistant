import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class SharedDropdown extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  const SharedDropdown({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.hint = 'Select',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DynamicSize.small(context)),
      child: Row(
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlackPrimary,
                height: 0.22,
              ),
            ),
          ),

          // Dropdown
          Expanded(
            flex: 3,
            child: Container(
              height: 35,
              padding: EdgeInsets.symmetric(
                horizontal: DynamicSize.horizontalMedium(context),
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x2E000000),
                    blurRadius: 2,
                    spreadRadius: 1.3,
                  ),
                ],
                // border: Border.all(color: SColor.borderColor, width: 1),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  hint: Text(
                    hint,
                    style: AppTextStyles.subHeadLine().copyWith(
                      color: AppColors.textBlackPrimary,
                      // height: 0.22,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textBlackPrimary,
                  ),
                  isExpanded: true,
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textBlackPrimary,
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.textBlackPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            item,
                            style: AppTextStyles.subHeadLine().copyWith(
                              color: AppColors.textBlackPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return items.map((String item) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item,
                          style: AppTextStyles.subHeadLine().copyWith(
                            color: AppColors.textBlackPrimary,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
