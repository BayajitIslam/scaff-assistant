import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class TextFieldWithLabel extends StatelessWidget {
  final String label;
  final String? secondaryLabel;
  final String? hint;
  final String? suffix;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWithLabel({
    super.key,
    required this.label,
    this.secondaryLabel,
    this.hint,
    this.suffix,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DynamicSize.small(context)),
      child: Row(
        children: [
          // Label Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textBlackPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (secondaryLabel != null)
                  Text(
                    secondaryLabel!,
                    style: AppTextStyles.subHeadLine().copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // TextField with suffix
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: SColor.borderColor,
                      //   width: 1,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x2E000000),
                          blurRadius: 2,
                          spreadRadius: 1.3,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      onChanged: onChanged,
                      inputFormatters: inputFormatters,
                      style: AppTextStyles.subHeadLine().copyWith(
                        color: AppColors.textBlackPrimary,
                      ),
                      decoration: InputDecoration(
                        // hintText: hint,
                        // hintStyle: STextTheme.subHeadLine().copyWith(
                        //   color: SColor.textBlackPrimary,
                        // ),
                        suffix: Text(
                          suffix!,
                          style: AppTextStyles.subHeadLine().copyWith(
                            color: AppColors.textBlackPrimary,
                            height: 0.22,
                          ),
                        ),

                        contentPadding: EdgeInsets.symmetric(
                          horizontal: DynamicSize.horizontalMedium(context),
                          vertical: DynamicSize.small(context) * 1.2,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
