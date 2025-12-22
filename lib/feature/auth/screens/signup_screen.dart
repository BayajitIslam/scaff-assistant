import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/image_paths.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/core/widgets/app_text_field.dart';
import 'package:scaffassistant/core/widgets/social_button.dart';
import 'package:scaffassistant/feature/auth/controllers/signup_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SIGNUP SCREEN
/// New user registration interface
/// ═══════════════════════════════════════════════════════════════════════════
class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  // Initialize controller
  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
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
              _buildHeaderText(),

              const SizedBox(height: 32),

              // Signup Form
              _buildSignupForm(),

              const SizedBox(height: 24),

              // Signup Button
              _buildSignupButton(),

              const SizedBox(height: 32),

              // Divider
              _buildDivider(),

              const SizedBox(height: 24),

              // Social Buttons
              _buildSocialButtons(),

              const SizedBox(height: 32),

              // Login Link
              _buildLoginLink(),

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
    return Center(child: Image.asset(ImagePaths.logo, width: 80, height: 80));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header Text Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign up',
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
  // Signup Form Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSignupForm() {
    return Obx(
      () => Column(
        children: [
          // Full Name Field
          AppTextField(
            controller: controller.nameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            keyboardType: TextInputType.name,
            // textInputAction: TextInputAction.next,
            // textCapitalization: TextCapitalization.words,
            prefixIcon: const Icon(
              Icons.person_outlined,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

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
  // Signup Button Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSignupButton() {
    return Obx(
      () => AppButton(
        text: 'Sign Up',
        onPressed: controller.signUp,
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
  // Social Buttons Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            text: 'Google',
            image: ImagePaths.google,
            onTap: controller.googleSignUp,
          ),
        ),
        // const SizedBox(width: 16),
        // Expanded(
        //   child: SocialButton(
        //     text: 'Apple',
        //     image: ImagePaths.apple,
        //     onTap: controller.appleSignUp,
        //   ),
        // ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Login Link Widget
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: controller.goToLogin,
          child: Text(
            'Login',
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
