import 'package:flutter/material.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';

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
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
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
                  style: STextTheme.subHeadLine().copyWith(
                    color: SColor.textBlackPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                // SizedBox(height: 4),
                Text(
                  subtitle,
                  style: STextTheme.subHeadLine().copyWith(
                    color: SColor.textSecondary,
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
        color: SColor.textSecondary.withOpacity(0.5),
        size: 24,
      ),
    );
  }
}
