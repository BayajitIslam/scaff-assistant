import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

class AlertTypesCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const AlertTypesCard({
    super.key,
    required this.title,
    required this.children,
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
          // Title
          Text(
            title,
            style: STextTheme.headLine().copyWith(
              color: SColor.textBlackPrimary,
            ),
          ),

          SizedBox(height: DynamicSize.small(context)),

          // Alert items
          ...children,
        ],
      ),
    );
  }
}
