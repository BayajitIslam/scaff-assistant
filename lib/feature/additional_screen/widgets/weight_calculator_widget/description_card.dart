import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

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
        style: STextTheme.subHeadLine().copyWith(
          color: SColor.textBlackPrimary,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }
}
