// ============================================================================
// AppTextStyles - Application Typography System
// ============================================================================
// Purpose: Pura app er text styles centralized and consistent
// Usage: Text('Hello', style: AppTextStyles.heading1)
// Note: Replace all STextTheme with AppTextStyles
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Application er shob text styles
class AppTextStyles {
  // Private constructor
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════════
  // Heading Styles (H1 - H6)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Heading 1 - Largest heading (32px)
  /// Usage: Page titles, main headings
  static TextStyle headLine() {
    return TextStyle(
      fontFamily: 'LemonMilk',
      color: AppColors.primary,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle subHeadLine() {
    return GoogleFonts.roboto(
      color: AppColors.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }
}

// ============================================================================
// Usage Examples
// ============================================================================
//
// 1. Heading:
//    Text('Welcome', style: AppTextStyles.heading1())
//
// 2. Body text:
//    Text('Description here', style: AppTextStyles.bodyMedium())
//
// 3. Custom color:
//    Text('Error', style: AppTextStyles.bodyMedium(color: AppColors.error))
//
// 4. Legacy support:
//    Text('Old code', style: AppTextStyles.headLine())
//
// ============================================================================

// ============================================================================
// Migration Guide (Old STextTheme → New AppTextStyles)
// ============================================================================
//
// Find & Replace:
// 1. STextTheme.headLine() → AppTextStyles.headLine()
// 2. STextTheme.subHeadLine() → AppTextStyles.subHeadLine()
//
// Better alternatives:
// 3. STextTheme.headLine() → AppTextStyles.heading1/2/3()
// 4. STextTheme.subHeadLine() → AppTextStyles.bodyMedium()
//
// ============================================================================
