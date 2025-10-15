import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/local_storage/user_status.dart';
import 'package:scaffassistant/core/theme/SColor.dart';

import '../../../core/theme/text_theme.dart';
import '../../../routing/route_name.dart';
import '../widgets/s_full_btn.dart';
import '../widgets/s_text_field.dart';
import '../widgets/social_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
        automaticallyImplyLeading: false,
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
                'LOGIN',
                style: STextTheme.headLine().copyWith(fontWeight: FontWeight.w500, color: SColor.textPrimary, fontSize: 24),
              ),
              SizedBox(height: DynamicSize.small(context)),
              Text(
                'Access to your account',
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
              SizedBox(height: DynamicSize.large(context)),

              // === Login Button === //
              SFullBtn(
                text: 'Login',
                onPressed: () {
                  Get.toNamed(RouteNames.home);
                  UserStatus.setIsLoggedIn(true);
                },
              ),

              SizedBox(height: DynamicSize.small(context)),

              // === Forgot Password === //
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Get.toNamed(RouteNames.mailVerification);
                  },
                  child: Text(
                    'Forgot password ?',
                    style: STextTheme.subHeadLine().copyWith(fontSize: 12),
                  ),
                ),
              ),
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
                      'Don\'t have an account? ',
                      style: STextTheme.subHeadLine().copyWith(fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteNames.signup);
                      },
                      child: Text(
                        'Sign Up',
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






