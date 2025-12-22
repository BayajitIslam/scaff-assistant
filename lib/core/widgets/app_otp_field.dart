// ============================================================================
// AppOTPField - OTP/Pin Input Field
// ============================================================================
// Purpose: Beautiful OTP input with auto-focus and validation
// Replaces: SOTPField
// Usage: AppOTPField(length: 6, controller: otpController)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';

/// OTP/Pin input field widget
class AppOTPField extends StatefulWidget {
  /// Number of OTP digits
  final int length;

  /// Combined controller for all digits
  final TextEditingController controller;

  /// Width of each box
  final double boxWidth;

  /// Height of each box
  final double boxHeight;

  /// Spacing between boxes
  final double spacing;

  /// Border radius
  final double borderRadius;

  /// Box border color
  final Color? borderColor;

  /// Box focused border color
  final Color? focusedBorderColor;

  /// Box fill color
  final Color? fillColor;

  /// Text style
  final TextStyle? textStyle;

  /// On completed callback (called when all digits filled)
  final void Function(String)? onCompleted;

  const AppOTPField({
    super.key,
    required this.length,
    required this.controller,
    this.boxWidth = 55,
    this.boxHeight = 60,
    this.spacing = 10,
    this.borderRadius = 10,
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.textStyle,
    this.onCompleted,
  }) : assert(length > 0, 'Length must be greater than 0');

  @override
  State<AppOTPField> createState() => _AppOTPFieldState();
}

class _AppOTPFieldState extends State<AppOTPField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _textControllers;

  @override
  void initState() {
    super.initState();
    _createFields(widget.length);

    // Sync combined controller with individual controllers
    widget.controller.text = _textControllers.map((c) => c.text).join();

    // Auto-focus first field
    if (_focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AppOTPField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      // Preserve existing values
      final oldText = _textControllers.map((c) => c.text).toList();

      // Dispose old nodes/controllers
      _disposeAll();

      // Recreate with new length
      _createFields(widget.length);

      // Restore texts where possible
      for (var i = 0; i < oldText.length && i < _textControllers.length; i++) {
        _textControllers[i].text = oldText[i];
      }

      // Update combined controller
      widget.controller.text = _textControllers.map((c) => c.text).join();

      // Focus on first empty field
      _focusOnFirstEmpty();
      setState(() {});
    }
  }

  /// Create focus nodes and text controllers
  void _createFields(int length) {
    _focusNodes = List.generate(length, (_) => FocusNode());
    _textControllers = List.generate(length, (_) => TextEditingController());
  }

  /// Dispose all resources
  void _disposeAll() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var ctrl in _textControllers) {
      ctrl.dispose();
    }
  }

  /// Focus on first empty field
  void _focusOnFirstEmpty() {
    if (_focusNodes.isEmpty) return;
    final firstEmpty = _textControllers.indexWhere((c) => c.text.isEmpty);
    final index = (firstEmpty == -1) ? (_focusNodes.length - 1) : firstEmpty;
    _focusNodes[index].requestFocus();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  /// Handle text change for a specific field
  void _onChanged(int index, String value) {
    if (index < 0 || index >= _textControllers.length) return;

    // If multiple characters pasted, keep only the last one
    if (value.length > 1) {
      final char = value[value.length - 1];
      _textControllers[index].text = char;
    }

    // Move focus forward when a digit is entered
    if (value.isNotEmpty && index + 1 < _focusNodes.length) {
      _focusNodes[index + 1].requestFocus();
    }

    // Move focus back on delete
    if (value.isEmpty && index - 1 >= 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Update combined controller
    final otp = _textControllers.map((c) => c.text).join();
    widget.controller.text = otp;

    // Call onCompleted if all fields filled
    if (otp.length == widget.length && widget.onCompleted != null) {
      widget.onCompleted!(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: widget.boxWidth,
          height: widget.boxHeight,
          margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: TextField(
            controller: _textControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style:
                widget.textStyle ??
                const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            // Only allow digits
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '', // Hide character counter
              filled: true,
              fillColor: widget.fillColor ?? Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.border,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.borderColor ?? AppColors.border,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: widget.focusedBorderColor ?? AppColors.textPrimary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) => _onChanged(index, value),
          ),
        );
      }),
    );
  }
}

// ============================================================================
// Usage Examples
// ============================================================================
//
// 1. Basic OTP field (6 digits):
// ```dart
// final otpController = TextEditingController();
// 
// AppOTPField(
//   length: 6,
//   controller: otpController,
// )
// ```
//
// 2. With completion callback:
// ```dart
// AppOTPField(
//   length: 6,
//   controller: otpController,
//   onCompleted: (otp) {
//     print('OTP entered: $otp');
//     controller.verifyOTP(otp);
//   },
// )
// ```
//
// 3. Custom styling:
// ```dart
// AppOTPField(
//   length: 4,
//   controller: pinController,
//   boxWidth: 60,
//   boxHeight: 70,
//   spacing: 15,
//   borderRadius: 15,
//   borderColor: AppColors.border,
//   focusedBorderColor: AppColors.primary,
//   fillColor: AppColors.backgroundSecondary,
//   textStyle: TextStyle(
//     fontSize: 28,
//     fontWeight: FontWeight.w700,
//     color: AppColors.textPrimary,
//   ),
// )
// ```
//
// 4. Get OTP value:
// ```dart
// String otp = otpController.text;
// print('Current OTP: $otp'); // "123456"
// ```
//
// 5. Clear OTP:
// ```dart
// otpController.clear(); // Clears all fields
// ```
//
// ============================================================================