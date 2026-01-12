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

                  // ═══════════════════════════════════════════════════════════
                  // TUBES INPUT PANEL
                  // ═══════════════════════════════════════════════════════════
                  InputPanelCard(
                    title: 'TUBES',
                    trailing: _buildAddButton(
                      context: context,
                      onPressed: () => controller.addTubeInput(),
                      label: 'Add Tube',
                    ),
                    children: [
                      Obx(
                        () => Column(
                          children: controller.tubeInputs.map((tubeInput) {
                            return _buildTubeInputRow(context, tubeInput);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DynamicSize.medium(context)),

                  // ═══════════════════════════════════════════════════════════
                  // BOARDS INPUT PANEL
                  // ═══════════════════════════════════════════════════════════
                  InputPanelCard(
                    title: 'BOARDS',
                    trailing: _buildAddButton(
                      context: context,
                      onPressed: () => controller.addBoardInput(),
                      label: 'Add Board',
                    ),
                    children: [
                      Obx(
                        () => Column(
                          children: controller.boardInputs.map((boardInput) {
                            return _buildBoardInputRow(context, boardInput);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DynamicSize.medium(context)),

                  // ═══════════════════════════════════════════════════════════
                  // FITTINGS INPUT PANEL
                  // ═══════════════════════════════════════════════════════════
                  InputPanelCard(
                    title: 'FITTINGS',
                    trailing: _buildAddButton(
                      context: context,
                      onPressed: () => controller.addFittingInput(),
                      label: 'Add Fitting',
                    ),
                    children: [
                      Obx(
                        () => Column(
                          children: controller.fittingInputs.map((
                            fittingInput,
                          ) {
                            return _buildFittingInputRow(context, fittingInput);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DynamicSize.large(context)),

                  // ═══════════════════════════════════════════════════════════
                  // ACTION BUTTONS
                  // ═══════════════════════════════════════════════════════════
                  Row(
                    children: [
                      // Clear Button
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () => controller.clearAll(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                              color: AppColors.textSecondary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'CLEAR',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: DynamicSize.small(context)),

                      // Calculate Button
                      Expanded(
                        flex: 2,
                        child: Obx(
                          () => PrimaryButton(
                            text: 'CALCULATE WEIGHT',
                            isLoading: controller.isLoading.value,
                            onPressed: () => controller.calculateWeight(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DynamicSize.large(context)),

                  // ═══════════════════════════════════════════════════════════
                  // OUTPUT PANEL
                  // ═══════════════════════════════════════════════════════════
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
                        : const SizedBox.shrink(),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Add Button Widget
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAddButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 18,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Remove Button Widget
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildRemoveButton({
    required VoidCallback onPressed,
    required bool canRemove,
  }) {
    if (!canRemove) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.remove_circle_outline,
          size: 20,
          color: Colors.red,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tube Input Row
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTubeInputRow(BuildContext context, TubeInput tubeInput) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: WeightInputWidget(
                    title:
                        'Tube ${controller.tubeInputs.indexOf(tubeInput) + 1}',
                    type: InputRowType.tubes,
                    selectedValue: tubeInput.selectedTube.value,
                    items: controller.tubeOptions,
                    hint: '1ft',
                    onChanged: (value) {
                      tubeInput.selectedTube.value = value;
                    },
                    selectedWallThickness:
                        tubeInput.selectedWallThickness.value,
                    wallThicknessItems: controller.wallThicknessOptions,
                    wallThicknessHint: '3.2mm',
                    onWallThicknessChanged: (value) {
                      tubeInput.selectedWallThickness.value = value;
                    },
                    quantity: tubeInput.quantity.value,
                    onQuantityChanged: (value) {
                      tubeInput.quantity.value = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _buildRemoveButton(
                  onPressed: () => controller.removeTubeInput(tubeInput.id),
                  canRemove: controller.tubeInputs.length > 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Board Input Row
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBoardInputRow(BuildContext context, BoardInput boardInput) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: WeightInputWidget(
                title:
                    'Board ${controller.boardInputs.indexOf(boardInput) + 1}',
                type: InputRowType.boards,
                selectedValue: boardInput.selectedBoard.value,
                items: controller.boardOptions,
                hint: '3ft',
                onChanged: (value) {
                  boardInput.selectedBoard.value = value;
                },
                quantity: boardInput.quantity.value,
                onQuantityChanged: (value) {
                  boardInput.quantity.value = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            _buildRemoveButton(
              onPressed: () => controller.removeBoardInput(boardInput.id),
              canRemove: controller.boardInputs.length > 1,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fitting Input Row
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFittingInputRow(
    BuildContext context,
    FittingInput fittingInput,
  ) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: WeightInputWidget(
                title:
                    'Fitting ${controller.fittingInputs.indexOf(fittingInput) + 1}',
                type: InputRowType.fittings,
                selectedValue: fittingInput.selectedFitting.value,
                items: controller.fittingOptions,
                hint: 'Double',
                onChanged: (value) {
                  fittingInput.selectedFitting.value = value;
                },
                quantity: fittingInput.quantity.value,
                onQuantityChanged: (value) {
                  fittingInput.quantity.value = value;
                },
              ),
            ),
            const SizedBox(width: 8),
            _buildRemoveButton(
              onPressed: () => controller.removeFittingInput(fittingInput.id),
              canRemove: controller.fittingInputs.length > 1,
            ),
          ],
        ),
      ),
    );
  }
}
