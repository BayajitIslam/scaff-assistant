import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/controller/quiz_controller.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/widgets/option_tile.dart';
import 'package:scaffassistant/routing/route_name.dart';

class QuizScreen extends GetView<QuizController> {
  QuizScreen({super.key});

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
            controller.reset();
            Get.toNamed(RouteNames.scaffoldRevisionTest);
          },
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            argument,
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
              child: Obx(
                () => Text(
                  'Question ${controller.currentQuestionIndex.value + 1}/${controller.selectedQuestionCount.value}',
                  style: AppTextStyles.subHeadLine().copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: AppColors.textBlackPrimary,
                  ),
                ),
              ),
            ),

            //Progress bar
            const SizedBox(height: 10),
            Obx(
              () => LinearPercentIndicator(
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width * 0.85,
                // animation: true,
                lineHeight: 8.0,
                animationDuration: 1000,
                percent:
                    (controller.currentQuestionIndex.value + 1) /
                    controller.selectedQuestionCount.value,

                barRadius: Radius.circular(15),
                animateToInitialPercent: false,
                progressColor: AppColors.textBlackPrimary,
              ),
            ),

            //Question
            const SizedBox(height: 37),
            Text(
              "${controller.currentQuestionIndex.value + 1}. ${controller.currentQuestions[controller.currentQuestionIndex.value].question}",
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlackPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            //Options
            SizedBox(height: 22),
            Expanded(
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => Obx(
                  () => OptionTile(
                    isSelected:
                        controller
                            .currentQuestions[controller
                                .currentQuestionIndex
                                .value]
                            .selectedIndex ==
                        index,
                    option: controller
                        .currentQuestions[controller.currentQuestionIndex.value]
                        .options[index],
                    onTap: () => controller.selectAnswer(index),
                  ),
                ),
                separatorBuilder: (context, index) => SizedBox(height: 17),
                itemCount: controller
                    .currentQuestions[controller.currentQuestionIndex.value]
                    .options
                    .length,
              ),
            ),

            //Next Button
            Obx(
              () => controller.isAnswered.value
                  ? AppButton(
                      text: 'Next',
                      onPressed: () => controller.nextQuestion(),
                    )
                  : Container(),
            ),
            SizedBox(height: 19),
          ],
        ),
      ),
    );
  }
}
