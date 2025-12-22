import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/image_paths.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/core/widgets/app_text_field.dart';
import 'package:scaffassistant/routing/route_name.dart';

class UpdatePassword extends StatelessWidget {
  const UpdatePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,

      // === App Bar === //
      appBar: AppBar(backgroundColor: AppColors.primary),

      // === Body === //
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DynamicSize.horizontalLarge(context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Logo === //
              Center(
                child: Image(width: 100, image: AssetImage(ImagePath.logo)),
              ),
              SizedBox(height: DynamicSize.large(context)),

              // === Login Form === //
              Text(
                'UPDATE PASSWORD',
                style: AppTextStyles.headLine().copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: DynamicSize.small(context)),
              Text(
                'Create a new password that you don’t use on any other site',
                style: AppTextStyles.subHeadLine(),
              ),
              SizedBox(height: DynamicSize.large(context)),

              // === Password Fields === //
              AppTextField(
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: true,
                suffixIcon: Icon(
                  Icons.visibility_off,
                  color: AppColors.borderColor,
                ),
                changedSuffixIcon: Icon(
                  Icons.visibility,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: DynamicSize.medium(context)),
              AppTextField(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                obscureText: true,
                suffixIcon: Icon(
                  Icons.visibility_off,
                  color: AppColors.borderColor,
                ),
                changedSuffixIcon: Icon(
                  Icons.visibility,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: DynamicSize.large(context)),

              // === Login Button === //
              AppButton(
                text: 'update password',
                onPressed: () {
                  Get.offAllNamed(RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
