import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/feature/auth/controllers/otp_verification_controller.dart';
import 'package:scaffassistant/feature/auth/widgets/s_otp_field.dart';
import 'package:scaffassistant/routing/route_name.dart';

import '../../../core/theme/text_theme.dart';
import '../widgets/s_full_btn.dart';
import '../widgets/s_text_field.dart';
import '../widgets/social_button.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final OtpVerificationController otpVerificationController = Get.put(OtpVerificationController());

    return Scaffold(
      backgroundColor: SColor.primary,

      // === App Bar === //
      appBar: AppBar(
        backgroundColor: SColor.primary,
      ),

      // === Body === //
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: DynamicSize.horizontalLarge(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // === Logo === //
              Center(
                child: Image(
                  width: 100,
                  image: AssetImage(ImagePath.logo),
                ),
              ),
              SizedBox(
                height: DynamicSize.large(context),
              ),

              // === Login Form === //
              Text(
                'Reset your password',
                style: STextTheme.headLine().copyWith(fontWeight: FontWeight.w500, color: SColor.textPrimary, fontSize: 24),
              ),
              SizedBox(height: DynamicSize.small(context)),
              Text(
                'We’ll send you an OTP to reset your password',
                style: STextTheme.subHeadLine(),
              ),
              SizedBox(
                height: DynamicSize.large(context),
              ),

              // === OTP Field === //
              SOTPField(
                length: 6,
                controller: otpVerificationController.otpController,
              ),

              SizedBox(height: DynamicSize.large(context)),

              // === Login Button === //
              Obx(
                  ()=> SFullBtn(
                    text: otpVerificationController.isLoading.value ? 'Verifying...' : 'Verify OTP',
                    onPressed: () {
                      // In the OTP screen or its controller
                      final args = Get.arguments as Map<String, dynamic>? ?? {};
                      final name = args['name'] ?? '';
                      final email = args['email'] ?? '';
                      final password = args['password'] ?? '';
                      otpVerificationController.otpVerify(name, email, password);
                    },
                  )
              ),

              SizedBox(height: DynamicSize.large(context)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    final args = Get.arguments as Map<String, dynamic>? ?? {};
                    final email = args['email'] ?? '';
                    otpVerificationController.resendOTP(email, 'signup');
                  },
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.poppins(
                      color: SColor.textPrimary,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}






