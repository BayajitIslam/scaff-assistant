import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';

import '../controllers/quantity_calculator_controller.dart';

class QuantityCalculatorScreen extends StatelessWidget {
  QuantityCalculatorScreen({super.key});

  final controller = Get.put(QuantityCalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'SCAFFOLD CALCULATOR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.resetCalculator(),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Panel
            _buildInputPanel(context),

            const SizedBox(height: 16),

            // Calculate Button
            _buildCalculateButton(context),

            const SizedBox(height: 16),

            // Error Message
            Obx(
              () => controller.errorMessage.value.isNotEmpty
                  ? _buildErrorMessage(context)
                  : const SizedBox.shrink(),
            ),

            // Results Section
            Obx(
              () => controller.tubesOutput.value != '-'
                  ? _buildResultsSection(context)
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'INPUT PARAMETERS',
              style: TextStyle(
                color: AppColors.textBlackPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Scaffold Type + Bay Class
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Scaffold Type',
                        value: controller.selectedScaffoldType,
                        items: controller.scaffoldTypeOptions,
                        hint: 'Select type',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Bay Class',
                        value: controller.selectedLoadClass,
                        items: controller.loadClassOptions,
                        hint: 'Select class',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Row 2: Height + Run Length
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Top Boarded Lift',
                        hint: '9',
                        suffix: 'm',
                        controller: controller.heightController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Run Length',
                        hint: '41.5',
                        suffix: 'm',
                        controller: controller.totalLengthController,
                        allowDecimal: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Row 3: Main Deck + Inside Boards
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Main Deck Boards',
                        value: controller.selectedMainDeckBoards,
                        items: controller.mainDeckBoardOptions,
                        hint: 'Select',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Inside Boards',
                        value: controller.selectedInsideBoards,
                        items: controller.insideBoardOptions,
                        hint: 'Select',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Row 4: Board Option + Boarding Mode
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Board Option',
                        value: controller.selectedBoardOption,
                        items: controller.boardOptionsList,
                        hint: 'Select',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Boarded Lifts',
                        value: controller.selectedBoardingMode,
                        items: controller.boardingModeOptions,
                        hint: 'Select',
                        onChanged: controller.onBoardingModeChanged,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Lift Height Selection (when User selects mode)
                Obx(() {
                  if (controller.selectedBoardingMode.value == 'User selects' &&
                      controller.availableLiftHeights.isNotEmpty) {
                    return _buildLiftHeightSelector(context);
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required Rxn<String> value,
    required List<String> items,
    required String hint,
    void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value.value,
                hint: Text(
                  hint,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                borderRadius: BorderRadius.circular(8),
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: onChanged ?? (val) => value.value = val,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String suffix,
    required TextEditingController controller,
    bool allowDecimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(
              decimal: allowDecimal,
            ),
            inputFormatters: [
              allowDecimal
                  ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiftHeightSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Boarded Lift Heights',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableLiftHeights.map((height) {
              final isSelected = controller.selectedBoardedHeights.contains(
                height,
              );
              return GestureDetector(
                onTap: () => controller.toggleBoardedHeight(height),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00d4ff)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00d4ff)
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${height}m',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            'Selected: ${controller.selectedBoardedHeights.map((h) => "${h}m").join(", ")}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  controller.errorMessage.value = '';
                  controller.calculateQuantities();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'CALCULATE QUANTITIES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conversion Info Card
        _buildConversionInfoCard(context),

        const SizedBox(height: 16),

        // Lift Stack Card
        _buildLiftStackCard(context),

        const SizedBox(height: 16),

        // Output Cards
        _buildOutputCard(
          title: 'TUBES',
          content: controller.tubesOutput,
          icon: Icons.straighten,
        ),

        const SizedBox(height: 12),

        _buildOutputCard(
          title: 'BOARDS',
          content: controller.boardsOutput,
          icon: Icons.view_module,
        ),

        const SizedBox(height: 12),

        _buildOutputCard(
          title: 'FITTINGS',
          content: controller.fittingsOutput,
          icon: Icons.build,
        ),

        const SizedBox(height: 12),

        _buildOutputCard(
          title: 'BASE SUPPORT',
          content: controller.baseSupportOutput,
          icon: Icons.foundation,
        ),

        const SizedBox(height: 16),

        // Validation Card
        _buildValidationCard(context),
      ],
    );
  }

  Widget _buildConversionInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF000100), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem('Run Length', '${controller.runLengthFt.value}ft'),
            _buildInfoItem('Height', '${controller.heightFt.value}ft'),
            _buildInfoItem('Total Lifts', '${controller.totalLifts.value}'),
            _buildInfoItem('Boarded', '${controller.boardedLiftsCount.value}'),
            _buildInfoItem('Leg Sets', '${controller.setsOfLegs.value}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildLiftStackCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a2e),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.layers, color: Color(0xFF00d4ff), size: 18),
                SizedBox(width: 8),
                Text(
                  'LIFT STACK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.liftStackOutput.isEmpty
                ? const Padding(padding: EdgeInsets.all(16), child: Text('-'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey[50],
                      ),
                      dataRowMinHeight: 36,
                      dataRowMaxHeight: 36,
                      headingRowHeight: 40,
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'No.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Height Range',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Lift Type',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Boarded',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      rows: controller.liftStackOutput.map((lift) {
                        return DataRow(
                          color: MaterialStateProperty.resolveWith((states) {
                            return lift.isBoarded
                                ? const Color(0xFF00d4ff).withOpacity(0.1)
                                : null;
                          }),
                          cells: [
                            DataCell(
                              Text(
                                '${lift.number}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Text(
                                lift.rangeDisplay,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Text(
                                lift.type.displayName,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: lift.isBoarded
                                      ? const Color(0xFF22c55e).withOpacity(0.2)
                                      : const Color(
                                          0xFFef4444,
                                        ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lift.isBoarded ? 'YES' : 'NO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: lift.isBoarded
                                        ? const Color(0xFF22c55e)
                                        : const Color(0xFFef4444),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputCard({
    required String title,
    required RxString content,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF7c3aed), size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Text(
                content.value,
                style: const TextStyle(fontSize: 13, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF22c55e),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'VALIDATION',
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildValidationItem(
                    'Golden Height',
                    controller.isGoldenHeight.value,
                  ),
                  _buildValidationItem(
                    'Golden Length',
                    controller.isGoldenLength.value,
                  ),
                  _buildValidationItem(
                    'Golden Width',
                    controller.isGoldenWidth.value,
                  ),
                  _buildValidationItem(
                    'Lift Logic',
                    controller.liftLogicValid.value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationItem(String label, bool isValid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isValid
                ? const Color(0xFF22c55e).withOpacity(0.2)
                : const Color(0xFFef4444).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isValid ? 'YES' : 'NO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isValid
                  ? const Color(0xFF22c55e)
                  : const Color(0xFFef4444),
            ),
          ),
        ),
      ],
    );
  }
}
