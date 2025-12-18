import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/feature/auth/controllers/reset_password_controller.dart';

import '../../../core/theme/text_theme.dart';
import '../widgets/s_full_btn.dart';
import '../widgets/s_text_field.dart';

class MailVerificationScreen extends StatelessWidget {
  const MailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResetPasswordController resetPasswordController = Get.put(
      ResetPasswordController(),
    );

    return Scaffold(
      backgroundColor: SColor.primary,

      // === App Bar === //
      appBar: AppBar(backgroundColor: SColor.primary),

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
                style: STextTheme.headLine().copyWith(
                  fontWeight: FontWeight.w500,
                  color: SColor.textPrimary,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: DynamicSize.small(context)),
              Text(
                'We’ll send you an OTP to reset your password',
                style: STextTheme.subHeadLine(),
              ),
              SizedBox(height: DynamicSize.large(context)),

              // === Email Fields === //
              STextField(
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                controller: resetPasswordController.emailController,
              ),

              SizedBox(height: DynamicSize.large(context)),

              // === Login Button === //
              Obx(
                () => SFullBtn(
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
