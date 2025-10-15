import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/theme/SColor.dart';

import '../../../core/theme/text_theme.dart';
import '../widgets/s_full_btn.dart';
import '../widgets/s_text_field.dart';
import '../widgets/social_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: SColor.primary,

      // === App Bar === //
      appBar: AppBar(
        backgroundColor: SColor.primary,
        actions: [
          TextButton(
            onPressed: null,
            child: Text(
              'Skip',
              style: STextTheme.subHeadLine(),
            ),
          )
        ],
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
                'SIGN UP',
                style: STextTheme.headLine().copyWith(fontWeight: FontWeight.w500, color: SColor.textPrimary, fontSize: 24),
              ),
              SizedBox(height: DynamicSize.small(context)),
              Text(
                'Create an account to continue!',
                style: STextTheme.subHeadLine(),
              ),
              SizedBox(
                height: DynamicSize.large(context),
              ),

              // === Email Fields === //
              STextField(
                labelText: 'Email',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: DynamicSize.medium(context)),

              // === Password Fields === //
              STextField(
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: true,
                suffixIcon: Icon(Icons.visibility_off, color: SColor.borderColor),
                changedSuffixIcon: Icon(Icons.visibility, color: SColor.textPrimary),
              ),
              SizedBox(height: DynamicSize.medium(context)),
              STextField(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                obscureText: true,
                suffixIcon: Icon(Icons.visibility_off, color: SColor.borderColor),
                changedSuffixIcon: Icon(Icons.visibility, color: SColor.textPrimary),
              ),
              SizedBox(height: DynamicSize.large(context)),

              // === Login Button === //
              SFullBtn(
                text: 'Sign Up',
                onPressed: () {

                },
              ),

              SizedBox(height: DynamicSize.small(context)),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: SColor.textPrimary,
                      thickness: 1.5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: DynamicSize.horizontalLarge(context)),
                    child: Text(
                      'or continue with',
                      style: STextTheme.subHeadLine().copyWith(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: SColor.textPrimary,
                      thickness: 1.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: DynamicSize.medium(context)),

              // === Social Buttons === //
              Row(
                children: [

                  // === Google Button === //
                  SocialButton(
                    text: 'sign in with Google',
                    image: ImagePath.google,
                  ),
                  SizedBox(width: DynamicSize.horizontalMedium(context)),

                  // === Apple Button === //
                  SocialButton(
                    text: 'sign in with Apple',
                    image: ImagePath.apple,
                  ),
                ],
              ),
              SizedBox(height: DynamicSize.medium(context)),

              // === Sign Up === //
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: STextTheme.subHeadLine().copyWith(fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.roboto(
                          color: SColor.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationThickness: 3,
                          decorationColor: SColor.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}






