import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/core/widgets/app_button.dart';
import 'package:scaffassistant/feature/Calculator/widgets/weight_calculator_widget/description_card.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/controller/count_tool_controller.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/widgets/build_card.dart';
import 'package:scaffassistant/routing/route_name.dart';

class CountToolScreen extends GetView<CountToolController> {
  const CountToolScreen({super.key});

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
            'Count Tool',
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
            DescriptionCard(
              text:
                  "Place items clearly on the ground avoid overlap where possible",
            ),
            SizedBox(height: 53),
            // Text
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Text(
                "Select component :",
                style: AppTextStyles.headLine().copyWith(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Category Card
            SizedBox(height: 20),
            SizedBox(
              height: 242,
              child: ListView.separated(
                itemBuilder: (context, index) => Obx(
                  () => BuildCard(
                    width: double.infinity,
                    name: controller.componentTypes[index],

                    isActive: controller.selectedComponentIndex.value == index,

                    onTap: () {
                      controller.selectedComponentIndex.value = index;
                      Console.info(
                        "Selected Component: ${controller.componentTypes[index]}",
                      );
                    },
                  ),
                ),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 22);
                },
                itemCount: controller.componentTypes.length,
              ),
            ),

            //Open Camera Button
            AppButton(
              text: "open camera",
              icon: Icons.camera_alt_rounded,
              onPressed: () => controller.openCamara(),
            ),
          ],
        ),
      ),
    );
  }
}
