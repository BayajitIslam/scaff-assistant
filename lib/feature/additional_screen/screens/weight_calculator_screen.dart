import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/feature/additional_screen/controllers/weight_calculator_controller.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/custom_appbar.dart';
import '../widgets/weight_calculator_widget/description_card.dart';
import '../widgets/shared_dropdown.dart';
import '../widgets/primary_button.dart';
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
                      // Tubes Dropdown
                      Obx(
                        () => SharedDropdown(
                          label: 'Tubes',
                          selectedValue: controller.selectedTube.value,
                          items: controller.tubeOptions,
                          hint: '1ft',
                          onChanged: (value) {
                            controller.selectedTube.value = value;
                          },
                        ),
                      ),

                      // Boards Dropdown
                      Obx(
                        () => SharedDropdown(
                          label: 'Boards',
                          selectedValue: controller.selectedBoard.value,
                          items: controller.boardOptions,
                          hint: '3ft',
                          onChanged: (value) {
                            controller.selectedBoard.value = value;
                          },
                        ),
                      ),

                      // Fittings Dropdown
                      Obx(
                        () => SharedDropdown(
                          label: 'Fittings',
                          selectedValue: controller.selectedFitting.value,
                          items: controller.fittingOptions,
                          hint: 'Doubles',
                          onChanged: (value) {
                            controller.selectedFitting.value = value;
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
                              color: SColor.primary,
                              size: 40,
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
