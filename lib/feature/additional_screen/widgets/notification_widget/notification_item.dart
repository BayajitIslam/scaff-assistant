import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String time;
  final String message;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.time,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 23, vertical: 10),
        margin: EdgeInsets.only(left: 26, right: 26, top: 23),
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
            // Title row with icon and date/time
            Row(
              children: [
                // Icon
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(width: DynamicSize.horizontalSmall(context)),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: STextTheme.subHeadLine().copyWith(
                      color: SColor.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Date and Time
                Text(
                  '$date . $time',
                  style: STextTheme.subHeadLine().copyWith(
                    color: SColor.textBlackPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            SizedBox(height: DynamicSize.small(context)),

            // Message
            Padding(
              padding: EdgeInsets.only(
                left: 10 + DynamicSize.horizontalSmall(context),
              ),
              child: Text(
                message,
                style: STextTheme.subHeadLine().copyWith(
                  color: SColor.textBlackPrimary,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
