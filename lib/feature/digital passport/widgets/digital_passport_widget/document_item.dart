import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';

class DocumentItem extends StatelessWidget {
  final String? imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DocumentItem({
    super.key,
    this.imagePath,
    required this.title,
    required this.subtitle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Debug log
    Console.cyan('DocumentItem imagePath: $imagePath');

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Image/Preview
          Container(
            width: 143,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x2E000000),
                  blurRadius: 1.64,
                  spreadRadius: 1.07,
                ),
              ],
            ),
            child: imagePath != null && imagePath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imagePath!,
                      fit: BoxFit.cover,
                      headers: {'Accept': '*/*'},
                      errorBuilder: (context, error, stackTrace) {
                        Console.red('Image load error: $error');
                        Console.red('Stack: $stackTrace');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 24,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Failed',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : _buildPlaceholder(),
          ),

          SizedBox(width: DynamicSize.horizontalMedium(context)),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textBlackPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textSecondary.withOpacity(0.5),
        size: 24,
      ),
    );
  }
}
