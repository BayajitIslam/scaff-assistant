import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/const/size_const/dynamic_size.dart';
import '../../../core/theme/SColor.dart';
import '../../../core/theme/text_theme.dart';
import '../../../routing/route_name.dart';

class LoginNote extends StatelessWidget {
  const LoginNote({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: (DynamicSize.large(context)*15),),
        Text(
          'Made by ScaffAssistant',
          style: STextTheme.subHeadLine().copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: SColor.textPrimary,
          ),
        ),
        SizedBox(height: DynamicSize.small(context),),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              backgroundColor: SColor.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Login or Sign up',
              style: STextTheme.headLine().copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
      ],
    );
  }
}