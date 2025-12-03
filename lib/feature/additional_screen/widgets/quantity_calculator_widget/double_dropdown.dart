import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

class DoubleDropdown extends StatelessWidget {
  final String label;
  final String? selectedValue1;
  final String? selectedValue2;
  final List<String> items1;
  final List<String> items2;
  final String hint1;
  final String hint2;
  final ValueChanged<String?>? onChanged1;
  final ValueChanged<String?>? onChanged2;

  const DoubleDropdown({
    super.key,
    required this.label,
    required this.selectedValue1,
    required this.selectedValue2,
    required this.items1,
    required this.items2,
    this.hint1 = 'Select',
    this.hint2 = 'Select',
    this.onChanged1,
    this.onChanged2,
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
              style: STextTheme.subHeadLine().copyWith(
                color: SColor.textBlackPrimary,
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
                  // First Dropdown
                  _buildDropdown(
                    context: context,
                    selectedValue: selectedValue1,
                    items: items1,
                    hint: hint1,
                    onChanged: onChanged1,
                  ),

                  SizedBox(height: DynamicSize.small(context)),

                  // Second Dropdown
                  _buildDropdown(
                    context: context,
                    selectedValue: selectedValue2,
                    items: items2,
                    hint: hint2,
                    onChanged: onChanged2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String? selectedValue,
    required List<String> items,
    required String hint,
    ValueChanged<String?>? onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 35,
      padding: EdgeInsets.symmetric(
        horizontal: DynamicSize.horizontalMedium(context),
      ),
      decoration: BoxDecoration(
        // border: Border.all(color: SColor.borderColor, width: 1),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x2E000000),
            blurRadius: 2,
            spreadRadius: 1.3,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            hint,
            style: STextTheme.subHeadLine().copyWith(color: SColor.textPrimary),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: SColor.textBlackPrimary,
          ),
          isExpanded: true,
          style: STextTheme.subHeadLine().copyWith(color: SColor.textPrimary),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: STextTheme.subHeadLine().copyWith(
                  color: SColor.textBlackPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
