import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/image_paths.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/core/widgets/app_otp_field.dart';
import 'package:scaffassistant/feature/auth/controllers/otp_verification_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// OTP VERIFICATION SCREEN
/// Verify OTP for signup or password reset
/// ═══════════════════════════════════════════════════════════════════════════
class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key});

  // Initialize controller
  final OtpVerificationController controller = Get.put(
    OtpVerificationController(),
  );

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from previous screen
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final name = args['name'] ?? '';
    final email = args['email'] ?? '';
    final password = args['password'] ?? '';
    final purpose = args['purpose'] ?? 'signup';

    return Scaffold(
      backgroundColor: AppColors.primary,

      // ─────────────────────────────────────────────────────────────────────
      // App Bar
      // ─────────────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // Body
      // ─────────────────────────────────────────────────────────────────────
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              _buildLogo(),

              const SizedBox(height: 32),

              // Header Text
              _buildHeaderText(email),

              const SizedBox(height: 40),

              // OTP Field
              _buildOtpField(),

              const SizedBox(height: 32),

              // Verify Button
              _buildVerifyButton(name, email, password, purpose),

              const SizedBox(height: 16),

              // Resend OTP
              _buildResendOtp(email, purpose),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logo Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Center(child: Image.asset(ImagePaths.logo, width: 103, height: 103));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header Text Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderText(String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify OTP',
          style: AppTextStyles.headLine().copyWith(
            color: AppColors.textPrimary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit code to',
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email.isNotEmpty ? email : 'your email',
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OTP Field Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOtpField() {
    return AppOTPField(
      length: 6,
      controller: controller.otpController,
      onCompleted: (otp) {
        // Auto-submit when all digits entered (optional)
        // controller.verifyOtp(name, email, password);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Verify Button Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildVerifyButton(
    String name,
    String email,
    String password,
    String purpose,
  ) {
    return Obx(
      () => AppButton(
        text: 'Verify OTP',
        onPressed: () {
          if (purpose == 'password_reset') {
            controller.verifyOtpForPasswordReset(email);
          } else {
            controller.verifyOtp(name, email, password);
          }
        },
        isLoading: controller.isLoading.value,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resend OTP Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildResendOtp(String email, String purpose) {
    return Obx(
      () => Column(
        children: [
          // Resend timer text
          if (!controller.canResend.value)
            Text(
              'Resend in ${controller.resendTimer.value}s',
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textSecondary,
              ),
            ),

          const SizedBox(height: 8),

          // Resend button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.canResend.value
                  ? () => controller.resendOtp(email, purpose)
                  : null,
              child: Text(
                controller.isResending.value ? 'Sending...' : 'Resend OTP',
                style: GoogleFonts.roboto(
                  color: controller.canResend.value
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: controller.canResend.value
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
