import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/routing/route_name.dart';

class CountToolResultScreen extends StatelessWidget {
  CountToolResultScreen({super.key});

  final imagePath = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.toNamed(RouteNames.countToolScreen),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Result',
            style: AppTextStyles.headLine().copyWith(
              color: AppColors.textBlack,
              fontWeight: FontWeight.w400,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          children: [
            // Image Preview
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              ),
            ),

            //Estimate Count
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Estimate count : ",
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textBlackPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "20 Board",
                  style: AppTextStyles.subHeadLine().copyWith(
                    fontSize: 24,
                    color: AppColors.textBlackPrimary,
                  ),
                ),
              ],
            ),

            //Done Button
            Spacer(),
            AppButton(
              text: "Done",
              onPressed: () => Get.toNamed(RouteNames.countToolScreen),
            ),

            //Disclaimer
            SizedBox(height: 45),
            Text(
              "Estimate only . Verify manually",
              style: AppTextStyles.subHeadLine().copyWith(fontSize: 14),
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
