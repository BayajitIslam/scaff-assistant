import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/calculator/controllers/weight_calculator_controller.dart';
import 'package:scaffassistant/feature/calculator/widgets/weight_calculator_widget/weight_input_widget.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/custom_appbar.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/primary_button.dart';
import '../widgets/weight_calculator_widget/description_card.dart';
import '../widgets/weight_calculator_widget/input_panel_card.dart';
import '../widgets/output_panel.dart';

class WeightCalculatorScreen extends StatelessWidget {
  WeightCalculatorScreen({super.key});

  final controller = Get.put(WeightCalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          CustomAppBar(
            title: 'WEIGHT CALCULATOR',
            onBackPressed: () => Get.back(),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DynamicSize.medium(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Card
                  DescriptionCard(
                    text:
                        'A simple, standalone tool used to calculate total scaffold weight based on user-entered quantities.',
                  ),

                  SizedBox(height: DynamicSize.large(context)),

                  // Input Panel
                  InputPanelCard(
                    title: 'INPUT PANEL',
                    children: [
                      // Tubes Input
                      Obx(
                        () => WeightInputWidget(
                          title: 'Tubes',
                          type: InputRowType.tubes,
                          selectedValue: controller.selectedTube.value,
                          items: controller.tubeOptions,
                          hint: '1ft',
                          onChanged: (value) {
                            controller.selectedTube.value = value;
                          },
                          selectedWallThickness:
                              controller.selectedWallThickness.value,
                          wallThicknessItems: controller.wallThicknessOptions,
                          wallThicknessHint: '3.2mm',
                          onWallThicknessChanged: (value) {
                            controller.selectedWallThickness.value = value;
                          },
                          quantity: controller.tubeQuantity.value,
                          onQuantityChanged: (value) {
                            controller.tubeQuantity.value = value;
                          },
                        ),
                      ),

                      // Boards Input
                      Obx(
                        () => WeightInputWidget(
                          title: 'Boards',
                          type: InputRowType.boards,
                          selectedValue: controller.selectedBoard.value,
                          items: controller.boardOptions,
                          hint: '3ft',
                          onChanged: (value) {
                            controller.selectedBoard.value = value;
                          },
                          quantity: controller.boardQuantity.value,
                          onQuantityChanged: (value) {
                            controller.boardQuantity.value = value;
                          },
                        ),
                      ),

                      // Fittings Input
                      Obx(
                        () => WeightInputWidget(
                          title: 'Fittings',
                          type: InputRowType.fittings,
                          selectedValue: controller.selectedFitting.value,
                          items: controller.fittingOptions,
                          hint: 'Double',
                          onChanged: (value) {
                            controller.selectedFitting.value = value;
                          },
                          quantity: controller.fittingQuantity.value,
                          onQuantityChanged: (value) {
                            controller.fittingQuantity.value = value;
                          },
                        ),
                      ),

                      SizedBox(height: DynamicSize.medium(context)),

                      // Calculate Button
                      Obx(
                        () => PrimaryButton(
                          text: 'CALCULATE WEIGHT',
                          isLoading: controller.isLoading.value,
                          onPressed: () {
                            controller.calculateWeight();
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DynamicSize.large(context)),

                  // Output Panel
                  Obx(
                    () => controller.showOutput.value
                        ? OutputPanel(
                            title: 'OUTPUT PANEL',
                            items: [
                              OutputPanelItem(
                                label: 'Tubes Total Weight :',
                                value: controller.tubesTotalWeight.value,
                              ),
                              OutputPanelItem(
                                label: 'Boards Total Weight :',
                                value: controller.boardsTotalWeight.value,
                              ),
                              OutputPanelItem(
                                label: 'Fittings Total Weight :',
                                value: controller.fittingsTotalWeight.value,
                              ),
                            ],
                            totalLabel: 'TOTAL WEIGHT :',
                            totalValue: controller.totalWeight.value,
                          )
                        : controller.isLoading.value
                        ? Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                              color: AppColors.primary,
                              size: 40,
                            ),
                          )
                        : controller.errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red.withOpacity(0.5),
                                ),
                                SizedBox(height: DynamicSize.medium(context)),
                                Text(
                                  controller.errorMessage.value,
                                  style: AppTextStyles.subHeadLine().copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: DynamicSize.medium(context)),
                                ElevatedButton(
                                  onPressed: () => controller.calculateWeight(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: DynamicSize.large(context)),
        ],
      ),
    );
  }
}
