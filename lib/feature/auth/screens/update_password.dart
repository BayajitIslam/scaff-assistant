import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/routing/route_name.dart';
import '../../../core/theme/text_theme.dart';
import '../widgets/s_full_btn.dart';
import '../widgets/s_text_field.dart';

class UpdatePassword extends StatelessWidget {
  const UpdatePassword({super.key});

  @override
  Widget build(BuildContext context) {

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
                'UPDATE PASSWORD',
                style: STextTheme.headLine().copyWith(fontWeight: FontWeight.w500, color: SColor.textPrimary, fontSize: 24),
              ),
              SizedBox(height: DynamicSize.small(context)),
              Text(
                'Create a new password that you don’t use on any other site',
                style: STextTheme.subHeadLine(),
              ),
              SizedBox(
                height: DynamicSize.large(context),
              ),

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






