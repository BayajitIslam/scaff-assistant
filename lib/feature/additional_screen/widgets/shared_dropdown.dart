import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

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
              style: STextTheme.subHeadLine().copyWith(
                color: SColor.textBlackPrimary,
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
                    style: STextTheme.subHeadLine().copyWith(
                      color: SColor.textBlackPrimary,
                      // height: 0.22,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: SColor.textBlackPrimary,
                  ),
                  isExpanded: true,
                  style: STextTheme.subHeadLine().copyWith(
                    color: SColor.textBlackPrimary,
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
                              color: SColor.textBlackPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            item,
                            style: STextTheme.subHeadLine().copyWith(
                              color: SColor.textBlackPrimary,
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
                          style: STextTheme.subHeadLine().copyWith(
                            color: SColor.textBlackPrimary,
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
