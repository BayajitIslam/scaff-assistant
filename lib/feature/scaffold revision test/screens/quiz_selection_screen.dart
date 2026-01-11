import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/controller/quiz_controller.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/models/quiz_model.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/widgets/build_card.dart';
import 'package:scaffassistant/routing/route_name.dart';

class QuizSelectionScreen extends GetView<QuizController> {
  const QuizSelectionScreen({super.key});

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
          onPressed: () => Get.toNamed(RouteNames.home),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            'Scaffold revision test',
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
        padding: const EdgeInsets.all(45.0),
        child: Column(
          children: [
            // Text
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                "Select a category :",
                style: AppTextStyles.headLine().copyWith(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Category Card
            SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => Obx(
                  () => BuildCard(
                    name: QuizDifficulty.values[index].displayName,

                    isActive:
                        controller.selectedDifficulty ==
                        QuizDifficulty.values[index],
                    onTap: () {
                      controller.selectedDifficulty.value =
                          QuizDifficulty.values[index];
                      Console.info(
                        "Selected difficulty: ${controller.selectedDifficulty.value.displayName}",
                      );
                    },
                  ),
                ),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 22);
                },
                itemCount: QuizDifficulty.values.length,
              ),
            ),

            // Text
            SizedBox(height: 44),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                "Choose number of questions :",
                style: AppTextStyles.headLine().copyWith(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Questions Count
            SizedBox(height: 20),

            // Expanded(
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemBuilder: (context, index) => Obx(
            //       () => BuildCard(
            //         name: '${controller.questionsCountOptions[index]}',
            //         isActive:
            //             controller.selectedQuestionCount.value ==
            //             controller.questionsCountOptions[index],
            //         onTap: () {
            //           controller.selectedQuestionCount.value =
            //               controller.questionsCountOptions[index];
            //           Console.info(
            //             "Selected question count: ${controller.selectedQuestionCount.value}",
            //           );
            //         },
            //       ),
            //     ),

            //     itemCount: controller.questionsCountOptions.length,
            //   ),
            // ),
            SizedBox(
              height: 35,
              child: Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.questionsCountOptions.length,
                    (index) {
                      bool isActive =
                          controller.selectedQuestionCount.value ==
                          controller.questionsCountOptions[index];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.selectedQuestionCount.value =
                                controller.questionsCountOptions[index];
                            Console.info(
                              "Selected question count: ${controller.selectedQuestionCount.value}",
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.grey
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.withOpacity(
                                    AppColors.textBlack,
                                    0.18,
                                  ),
                                  blurRadius: 2,
                                  spreadRadius: 1.3,
                                ),
                              ],
                            ),
                            child: Text(
                              '${controller.questionsCountOptions[index]}',
                              style: AppTextStyles.subHeadLine().copyWith(
                                color: isActive
                                    ? AppColors.textWhite
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            // Start Quiz Button
            Spacer(),
            Obx(
              () => controller.isAnswered.value
                  ? Container()
                  : AppButton(
                      text: 'Start Test',
                      onPressed: () => controller.startQuiz(
                        controller.selectedDifficulty.value,
                        controller.selectedQuestionCount.value,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
