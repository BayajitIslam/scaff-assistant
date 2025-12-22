import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/image_paths.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/core/widgets/app_text_field.dart';
import 'package:scaffassistant/core/widgets/social_button.dart';
import 'package:scaffassistant/feature/auth/controllers/login_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOGIN SCREEN
/// User authentication login interface
/// ═══════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Initialize controller
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ─────────────────────────────────────────────────────────────
              // Logo
              // ─────────────────────────────────────────────────────────────
              _buildLogo(),

              const SizedBox(height: 32),

              // ─────────────────────────────────────────────────────────────
              // Welcome Text
              // ─────────────────────────────────────────────────────────────
              _buildWelcomeText(),

              const SizedBox(height: 32),

              // ─────────────────────────────────────────────────────────────
              // Login Form
              // ─────────────────────────────────────────────────────────────
              _buildLoginForm(),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────────────────────
              // Forgot Password
              // ─────────────────────────────────────────────────────────────
              _buildForgotPassword(),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────────────────
              // Login Button
              // ─────────────────────────────────────────────────────────────
              _buildLoginButton(),

              const SizedBox(height: 32),

              // ─────────────────────────────────────────────────────────────
              // Divider
              // ─────────────────────────────────────────────────────────────
              _buildDivider(),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────────────────
              // Social Login Buttons
              // ─────────────────────────────────────────────────────────────
              _buildSocialButtons(),

              const SizedBox(height: 32),

              // ─────────────────────────────────────────────────────────────
              // Sign Up Link
              // ─────────────────────────────────────────────────────────────
              _buildSignUpLink(),

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
  // Welcome Text Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login',
          style: AppTextStyles.headLine().copyWith(
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Access to your account',
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login Form Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Obx(
      () => Column(
        children: [
          // Email Field
          AppTextField(
            controller: controller.emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            // textInputAction: TextInputAction.next,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Password Field
          AppTextField(
            controller: controller.passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            obscureText: !controller.isPasswordVisible.value,
            // textInputAction: TextInputAction.done,
            prefixIcon: const Icon(
              Icons.lock_outlined,
              color: AppColors.textSecondary,
            ),
            suffixIcon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            changedSuffixIcon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Forgot Password Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.goToForgotPassword,
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.roboto(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login Button Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return Obx(
      () => AppButton(
        text: 'Login',
        onPressed: controller.login,
        isLoading: controller.isLoading.value,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Divider Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.textSecondary)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: AppTextStyles.subHeadLine().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.textSecondary)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Social Login Buttons Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            text: 'Google',
            image: ImagePaths.google,
            onTap: controller.googleSignIn,
          ),
        ),
        // const SizedBox(width: 16),
        // Expanded(
        //   child: SocialButton(
        //     text: 'Apple',
        //     image: ImagePaths.apple,
        //     onTap: controller.appleSignIn,
        //   ),
        // ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign Up Link Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: controller.goToSignup,
          child: Text(
            'Sign Up',
            style: AppTextStyles.subHeadLine().copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
