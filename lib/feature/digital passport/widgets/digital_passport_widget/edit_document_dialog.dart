import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart' show DynamicSize;

class EditDocumentDialog extends StatelessWidget {
  final String? frontImagePath;
  final String? backImagePath;
  final TextEditingController nameController;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const EditDocumentDialog({
    super.key,
    this.frontImagePath,
    this.backImagePath,
    required this.nameController,
    this.onCancel,
    this.onSave,
  });

  /// Show dialog
  static Future<void> show({
    required BuildContext context,
    String? frontImagePath,
    String? backImagePath,
    required TextEditingController nameController,
    VoidCallback? onCancel,
    VoidCallback? onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => EditDocumentDialog(
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
        nameController: nameController,
        onCancel: onCancel ?? () => Navigator.pop(context),
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: DynamicSize.horizontalMedium(context),
        vertical: DynamicSize.large(context),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onCancel,
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: DynamicSize.medium(context)),

            // Card Images Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Front Card
                _buildCardPreview(
                  context: context,
                  label: 'Card : front',
                  imagePath: frontImagePath,
                ),

                // Back Card
                _buildCardPreview(
                  context: context,
                  label: 'Card : back',
                  imagePath: backImagePath,
                ),
              ],
            ),

            SizedBox(height: DynamicSize.medium(context)),

            // Name/Label Input
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(DynamicSize.medium(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x2E000000),
                    blurRadius: 2,
                    spreadRadius: 1.3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NAME /LABEL',
                    style: AppTextStyles.headLine().copyWith(
                      color: AppColors.textBlackPrimary,

                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: DynamicSize.small(context)),
                  TextField(
                    controller: nameController,
                    style: AppTextStyles.subHeadLine().copyWith(
                      color: AppColors.textSecondary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter name or label',
                      hintStyle: AppTextStyles.subHeadLine().copyWith(
                        color: AppColors.textBlackPrimary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: DynamicSize.medium(context)),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 39,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x2E000000),
                            blurRadius: 2,
                            spreadRadius: 1.3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'CANCEL',
                          style: AppTextStyles.headLine().copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: DynamicSize.horizontalLarge(context)),

                // Save Button
                Expanded(
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      height: 39,

                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x2E000000),
                            blurRadius: 2,
                            spreadRadius: 1.3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'SAVE',
                          style: AppTextStyles.headLine().copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview({
    required BuildContext context,
    required String label,
    String? imagePath,
  }) {
    return Column(
      children: [
        // Dashed border container
        CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.textSecondary,
            strokeWidth: 1,
            gap: 6,
            radius: 8,
          ),
          child: Stack(
            children: [
              //Container
              Container(
                width: 153,
                height: 103,
                decoration: BoxDecoration(
                  // color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            width: 153,
                            height: 103,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          ),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),

              //Text
              Positioned(
                bottom: 4,
                left: 40,
                child:
                    // Label
                    Text(
                      label,
                      style: AppTextStyles.subHeadLine().copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Icon(
      Icons.image_outlined,
      color: Colors.lightBlue.shade300,
      size: 32,
    );
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    this.radius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    // Draw dashed path
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = 6.0; // dash length
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += length + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
