import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/controller/quiz_controller.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/widgets/build_card.dart';
import 'package:scaffassistant/routing/route_name.dart';

class QuizResultScreen extends StatelessWidget {
  QuizResultScreen({super.key});

  final argument = Get.arguments;

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
          onPressed: () {
            final controller = Get.find<QuizController>();
            controller.reset();
            Get.toNamed(RouteNames.scaffoldRevisionTest);
          },
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            "Result",
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
            //Question number
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                'Question ${argument['currentQuestionIndex'] + 1}/${argument['totalQuestions']}',
                style: AppTextStyles.subHeadLine().copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: AppColors.textBlackPrimary,
                ),
              ),
            ),

            //Progress bar
            const SizedBox(height: 10),
            LinearPercentIndicator(
              padding: EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width * 0.85,
              // animation: true,
              lineHeight: 8.0,
              animationDuration: 1000,
              percent:
                  (argument['currentQuestionIndex'] + 1) /
                  argument['totalQuestions'],
              barRadius: Radius.circular(15),
              animateToInitialPercent: false,
              progressColor: AppColors.textBlackPrimary,
            ),

            //TEST COMPLETED
            SizedBox(height: 30),
            Text(
              "Test Completed",
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlack,
                fontWeight: FontWeight.w500,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),

            //SCORE
            SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: Column(
                children: [
                  //Circle
                  CircularPercentIndicator(
                    radius: 75,
                    lineWidth: 25,
                    center: Text(
                      '${((argument['correctCount'] / argument['totalQuestions']) * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.subHeadLine().copyWith(
                        color: AppColors.textBlackPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                      ),
                    ),
                    percent:
                        argument['correctCount'] / argument['totalQuestions'],
                    progressColor: AppColors.primary,
                    backgroundColor: AppColors.textBlackPrimary,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),

                  //Text
                  SizedBox(height: 8),
                  Text(
                    "${argument['correctCount']}/${argument['totalQuestions']}",
                    style: AppTextStyles.subHeadLine().copyWith(
                      color: AppColors.textBlackPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),

            //
            SizedBox(height: 22),
            BuildCard(name: "Review answers", isActive: true),

            //
            SizedBox(height: 22),
            BuildCard(name: "Retry test", isActive: false),

            //
            SizedBox(height: 22),
            BuildCard(name: "Change category", isActive: false),
            //
            SizedBox(height: 22),
            BuildCard(
              onTap: () => RouteNames.home,
              name: "Exit",
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }
}
