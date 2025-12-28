import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import '../../../routing/route_name.dart';

class LoginNote extends StatelessWidget {
  const LoginNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: (DynamicSize.large(context) * 15)),
        Text(
          'Made by ScaffAssistant',
          style: AppTextStyles.subHeadLine().copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: DynamicSize.small(context)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Login or Sign up',
              style: AppTextStyles.headLine().copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
