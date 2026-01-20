import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/calculator/widgets/output_panel.dart';
import 'package:scaffassistant/feature/calculator/widgets/quantity_calculator_widget/double_dropdown.dart';
import 'package:scaffassistant/feature/calculator/widgets/quantity_calculator_widget/text_field_with_label.dart';
import 'package:scaffassistant/feature/calculator/widgets/shared_dropdown.dart';
import 'package:scaffassistant/feature/calculator/widgets/weight_calculator_widget/input_panel_card.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/custom_appbar.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/primary_button.dart';
import '../controllers/quantity_calculator_controller.dart';

class QuantityCalculatorScreen extends StatelessWidget {
  QuantityCalculatorScreen({super.key});

  final controller = Get.put(QuantityCalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          CustomAppBar(
            title: 'CALCULATOR - QUANTITY',
            onBackPressed: () => Get.back(),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DynamicSize.medium(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Panel
                  InputPanelCard(
                    title: 'INPUT PANEL',
                    children: [
                      // Scaffold Type Dropdown
                      Obx(
                        () => SharedDropdown(
                          label: 'Scaffold type',
                          selectedValue: controller.selectedScaffoldType.value,
                          items: controller.scaffoldTypeOptions,
                          hint: 'Independent',
                          onChanged: (value) {
                            controller.selectedScaffoldType.value = value;
                          },
                        ),
                      ),

                      // Load Class Dropdown
                      Obx(
                        () => SharedDropdown(
                          label: 'Load Class',
                          selectedValue: controller.selectedLoadClass.value,
                          items: controller.loadClassOptions,
                          hint: 'Class 1',
                          onChanged: (value) {
                            controller.selectedLoadClass.value = value;
                          },
                        ),
                      ),

                      // Height to Top TextField
                      TextFieldWithLabel(
                        label: 'Height to Top',
                        secondaryLabel: 'Boarded Lift',
                        hint: '15',
                        suffix: 'm',
                        controller: controller.heightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      // Total Length TextField
                      TextFieldWithLabel(
                        label: 'Total Length',
                        hint: '15',
                        suffix: 'm',
                        controller: controller.totalLengthController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),

                      SizedBox(height: DynamicSize.small(context)),

                      // Platform Width - Double Dropdown with left border
                      Obx(
                        () => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x2E000000),
                                blurRadius: 2,
                                spreadRadius: 1.3,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(left: 2, right: 16),
                          child: DoubleDropdown(
                            label: 'Platform Width',
                            selectedValue1:
                                controller.selectedPlatformWidth1.value,
                            selectedValue2:
                                controller.selectedPlatformWidth2.value,
                            items1: controller.mainDeckBoardOptions,
                            items2: controller.insideBoardOptions,
                            hint1: 'Main deck',
                            hint2: 'Inside boards',
                            onChanged1: (value) {
                              controller.selectedPlatformWidth1.value = value;
                            },
                            onChanged2: (value) {
                              controller.selectedPlatformWidth2.value = value;
                            },
                          ),
                        ),
                      ),

                      // Boarded Lifts Dropdown
                      Obx(
                        () => SharedDropdown(
                          label: 'Boarded Lifts',
                          selectedValue: controller.selectedBoardedLifts.value,
                          items: controller.boardedLiftsOptions,
                          hint: 'Top lift only',
                          onChanged: (value) {
                            controller.selectedBoardedLifts.value = value;
                          },
                        ),
                      ),

                      // Tube Type Selector removed as per requirements
                      SizedBox(height: DynamicSize.medium(context)),

                      // Error Message
                      Obx(
                        () => controller.errorMessage.value.isNotEmpty
                            ? Container(
                                margin: EdgeInsets.only(
                                  bottom: DynamicSize.medium(context),
                                ),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFFCDD2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: const Color(0xFFD32F2F),
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        controller.errorMessage.value,
                                        style: TextStyle(
                                          color: const Color(0xFFD32F2F),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                      ),

                      // Calculate Button
                      Obx(
                        () => PrimaryButton(
                          text: 'CALCULATE QUANTITIES',
                          isLoading: controller.isLoading.value,
                          onPressed: () {
                            controller.errorMessage.value =
                                ''; // Clear previous error
                            controller.calculateQuantities();
                          },
                        ),
                      ),
                    ],
                  ),

                  // Output Panel (Only visible after calculation)
                  Obx(
                    () => controller.tubesOutput.value != '-'
                        ? Padding(
                            padding: EdgeInsets.only(
                              top: DynamicSize.medium(context),
                            ),
                            child: OutputPanel(
                              title: 'OUTPUT PANEL',
                              items: [
                                OutputPanelItem(
                                  label: 'Tubes :',
                                  value: controller.tubesOutput.value,
                                ),
                                OutputPanelItem(
                                  label: 'Boards :',
                                  value: controller.boardsOutput.value,
                                ),
                                OutputPanelItem(
                                  label: 'Fittings :',
                                  value: controller.fittingsOutput.value,
                                ),
                                OutputPanelItem(
                                  label: 'Base Support :',
                                  value: controller.baseSupportOutput.value,
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
