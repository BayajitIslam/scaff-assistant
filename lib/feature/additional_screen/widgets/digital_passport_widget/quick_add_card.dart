import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';
import 'action_button.dart';

class QuickAddCard extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onUpload;

  const QuickAddCard({super.key, this.onCapture, this.onUpload});

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
            'QUICK ADD',
            style: STextTheme.headLine().copyWith(color: SColor.textPrimary),
          ),

          SizedBox(height: DynamicSize.medium(context)),

          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'CAPTURE',
                  isPrimary: true,
                  onTap: onCapture,
                ),
              ),
              SizedBox(width: DynamicSize.horizontalMedium(context)),
              Expanded(
                child: ActionButton(
                  icon: Icons.upload_outlined,
                  label: 'UPLOAD',
                  isPrimary: false,
                  onTap: onUpload,
                ),
              ),
            ],
          ),

          SizedBox(height: DynamicSize.medium(context)),

          // Description
          Text(
            'Capture supports card front / back and full A4 pages . Upload supports PDF, JPG, PNG',
            style: STextTheme.subHeadLine().copyWith(
              color: SColor.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
