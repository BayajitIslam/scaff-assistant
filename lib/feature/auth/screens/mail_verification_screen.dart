import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/image_paths.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/core/widgets/app_text_field.dart';
import 'package:scaffassistant/feature/auth/controllers/reset_password_controller.dart';

class MailVerificationScreen extends StatelessWidget {
  const MailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResetPasswordController resetPasswordController = Get.put(
      ResetPasswordController(),
    );

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
                'Reset your password',
                style: AppTextStyles.headLine().copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: DynamicSize.small(context)),
              Text(
                'We’ll send you an OTP to reset your password',
                style: AppTextStyles.subHeadLine(),
              ),
              SizedBox(height: DynamicSize.large(context)),

              // === Email Fields === //
              AppTextField(
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                controller: resetPasswordController.emailController,
              ),

              SizedBox(height: DynamicSize.large(context)),

              // === Login Button === //
              Obx(
                () => AppButton(
                  text: resetPasswordController.isLoading.value
                      ? 'Sending...'
                      : 'Send OTP',
                  onPressed: () {
                    if (!resetPasswordController.isLoading.value) {
                      resetPasswordController.verifyEmail();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
