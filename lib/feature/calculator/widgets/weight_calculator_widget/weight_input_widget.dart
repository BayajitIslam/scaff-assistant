import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

enum InputRowType {
  tubes, // Length + Wall thickness + Quantity
  boards, // Length + Quantity
  fittings, // Fitting type + Quantity
}

class WeightInputWidget extends StatefulWidget {
  final String title;
  final InputRowType type;

  // First dropdown (Length or Fitting type)
  final String? selectedValue;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;

  // Wall thickness dropdown (only for tubes)
  final String? selectedWallThickness;
  final List<String> wallThicknessItems;
  final String wallThicknessHint;
  final ValueChanged<String?>? onWallThicknessChanged;

  // Quantity
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const WeightInputWidget({
    super.key,
    required this.title,
    required this.type,
    required this.selectedValue,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.selectedWallThickness,
    this.wallThicknessItems = const ['3.2mm', '4.0mm'],
    this.wallThicknessHint = '3.2mm',
    this.onWallThicknessChanged,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<WeightInputWidget> createState() => _WeightInputWidgetState();
}

class _WeightInputWidgetState extends State<WeightInputWidget> {
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.quantity.toString(),
    );
  }

  @override
  void didUpdateWidget(WeightInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if quantity changed externally (from +/- buttons)
    if (widget.quantity != oldWidget.quantity) {
      _quantityController.text = widget.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DynamicSize.small(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with underline
          Text(
            widget.title,
            style: AppTextStyles.subHeadLine().copyWith(
              color: AppColors.textBlackPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            height: 1,
            color: AppColors.textBlackPrimary.withOpacity(0.3),
            margin: EdgeInsets.only(top: 4, bottom: 12),
          ),

          // Labels Row
          _buildLabelsRow(),

          SizedBox(height: 8),

          // Input Fields Row
          _buildInputRow(context),
        ],
      ),
    );
  }

  Widget _buildLabelsRow() {
    switch (widget.type) {
      case InputRowType.tubes:
        return Row(
          children: [
            Expanded(flex: 2, child: _labelText('Length')),
            SizedBox(width: 8),
            Expanded(flex: 2, child: _labelText('Wall thickness')),
            SizedBox(width: 8),
            Expanded(flex: 2, child: _labelText('Quantity')),
          ],
        );
      case InputRowType.boards:
        return Row(
          children: [
            Expanded(flex: 2, child: _labelText('Length')),
            SizedBox(width: 8),
            Expanded(flex: 2, child: _labelText('Quantity')),
          ],
        );
      case InputRowType.fittings:
        return Row(
          children: [
            Expanded(flex: 2, child: _labelText('Fitting type')),
            SizedBox(width: 8),
            Expanded(flex: 2, child: _labelText('Quantity')),
          ],
        );
    }
  }

  Widget _buildInputRow(BuildContext context) {
    switch (widget.type) {
      case InputRowType.tubes:
        return Row(
          children: [
            // Length Dropdown
            Expanded(
              flex: 2,
              child: _buildDropdown(
                value: widget.selectedValue,
                items: widget.items,
                hint: widget.hint,
                onChanged: widget.onChanged,
              ),
            ),
            SizedBox(width: 8),
            // Wall Thickness Dropdown
            Expanded(
              flex: 2,
              child: _buildDropdown(
                value: widget.selectedWallThickness,
                items: widget.wallThicknessItems,
                hint: widget.wallThicknessHint,
                onChanged: widget.onWallThicknessChanged ?? (_) {},
              ),
            ),
            SizedBox(width: 8),
            // Quantity Input
            Expanded(flex: 2, child: _buildQuantityInput()),
          ],
        );
      case InputRowType.boards:
      case InputRowType.fittings:
        return Row(
          children: [
            // Dropdown (Length or Fitting type)
            Expanded(
              flex: 2,
              child: _buildDropdown(
                value: widget.selectedValue,
                items: widget.items,
                hint: widget.hint,
                onChanged: widget.onChanged,
              ),
            ),
            SizedBox(width: 8),
            // Quantity Input
            Expanded(flex: 2, child: _buildQuantityInput()),
          ],
        );
    }
  }

  Widget _labelText(String text) {
    return Text(
      text,
      style: AppTextStyles.subHeadLine().copyWith(
        color: AppColors.textBlackPrimary.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 36,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.subHeadLine().copyWith(
              color: AppColors.textBlackPrimary,
              fontSize: 14,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textBlackPrimary.withOpacity(0.6),
            size: 20,
          ),
          isExpanded: true,
          style: AppTextStyles.subHeadLine().copyWith(
            color: AppColors.textBlackPrimary,
            fontSize: 14,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(6),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: AppTextStyles.subHeadLine().copyWith(
                  color: AppColors.textBlackPrimary,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity text field
          Expanded(
            child: TextField(
              controller: _quantityController,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.subHeadLine().copyWith(
                color: AppColors.textBlackPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                // isDense: true
              ),
              onChanged: (value) {
                final intValue = int.tryParse(value) ?? 0;
                widget.onQuantityChanged(intValue);
              },
            ),
          ),

          // Up/Down arrows on the right
          SizedBox(
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Up arrow (increment)
                GestureDetector(
                  onTap: () {
                    int current = int.tryParse(_quantityController.text) ?? 0;
                    _quantityController.text = (current + 1).toString();
                    widget.onQuantityChanged(current + 1);
                  },
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 18,
                    color: AppColors.textBlackPrimary.withOpacity(0.5),
                  ),
                ),
                // Down arrow (decrement)
                GestureDetector(
                  onTap: () {
                    int current = int.tryParse(_quantityController.text) ?? 0;
                    if (current > 0) {
                      _quantityController.text = (current - 1).toString();
                      widget.onQuantityChanged(current - 1);
                    }
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.textBlackPrimary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 4),
        ],
      ),
    );
  }
}
