// ============================================================================
// AppColors - Application Color Palette
// ============================================================================
// Purpose: Pura app er shob colors ek jaygay define kora
// Usage: AppColors.primary, AppColors.textPrimary
// Note: Replace all SColor with AppColors in your project
// ============================================================================

import 'package:flutter/material.dart';

/// Application er shob colors centralized
class AppColors {
  // Private constructor - Instance create kora jabe na
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // Primary Brand Colors
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color primary = Color(0xFFe2fa0e);

  // === Text Colors === //

  static const Color textSecondary = Color(0xFF6F6F6F);

  // === Border and Shadow Colors === //
  static const Color borderColor = Color(0xFFE0E0E0);

  static const Color grey = Color(0xFFB9B9B9);

  // ═══════════════════════════════════════════════════════════════════════════
  // Text Colors
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary text color - Dark gray for headings
  static const Color textPrimary = Color(0xFF2B2B2B);

  /// Pure black text (use sparingly)
  static const Color textBlack = Color(0xFF000000);

  /// Secondary text color - Medium gray for body text
  static const Color textBlackPrimary = Color(0xFF000000);

  /// Hint/placeholder text color - Light gray
  static const Color textHint = Color(0xFF9E9E9E);

  /// White text for dark backgrounds
  static const Color textWhite = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // Background Colors
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main background color - Pure white
  static const Color background = Color(0xFFFFFFFF);

  /// Secondary background - Light gray
  static const Color backgroundSecondary = Color(0xFFF5F5F5);

  /// Card/surface background
  static const Color surface = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // Border and Divider Colors
  // ═══════════════════════════════════════════════════════════════════════════

  /// Default border color - Light gray
  static const Color border = Color(0xFFE0E0E0);

  /// Focused border color
  static const Color borderFocused = Color(0xFF2B2B2B);

  /// Error border color
  static const Color borderError = Color(0xFFE53935);

  /// Divider color - Very light gray
  static const Color divider = Color(0xFFEEEEEE);

  // ═══════════════════════════════════════════════════════════════════════════
  // Status Colors
  // ═══════════════════════════════════════════════════════════════════════════

  /// Success color - Green
  static const Color success = Color(0xFF4CAF50);

  /// Warning color - Orange
  static const Color warning = Color(0xFFFFC107);

  /// Error color - Red
  static const Color error = Color(0xFFE53935);

  /// Info color - Blue
  static const Color info = Color(0xFF2196F3);

  // ═══════════════════════════════════════════════════════════════════════════
  // Weather Alert Colors (for weather feature)
  // ═══════════════════════════════════════════════════════════════════════════

  /// High heat alert - Orange
  static const Color alertHeat = Color(0xFFFF9800);

  /// Cold/ice alert - Light blue
  static const Color alertCold = Color(0xFF03A9F4);

  /// High wind alert - Blue gray
  static const Color alertWind = Color(0xFF607D8B);

  /// Rain warning - Blue
  static const Color alertRain = Color(0xFF2196F3);

  // ═══════════════════════════════════════════════════════════════════════════
  // Chat Bubble Colors (for chatbot)
  // ═══════════════════════════════════════════════════════════════════════════

  /// User message bubble - Light blue
  static const Color chatUserBubble = Color(0xFFD1E7FF);

  /// AI/Assistant message bubble - Light gray
  static const Color chatAssistantBubble = Color(0xFFF0F0F0);

  // ═══════════════════════════════════════════════════════════════════════════
  // Gradient Colors (for premium features)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary gradient colors
  static const List<Color> gradientPrimary = [
    Color(0xFFe2fa0e),
    Color(0xFFc5dd0c),
  ];

  /// Warm gradient colors (for subscription/welcome screens)
  static const List<Color> gradientWarm = [
    Color(0xFFFFF9F0),
    Color(0xFFFFEFE0),
    Color(0xFFFFF0F5),
    Color(0xFFF3E5F5),
    Color(0xFFE1D5F0),
  ];

  /// Cool gradient colors
  static const List<Color> gradientCool = [
    Color(0xFFE3F2FD),
    Color(0xFFBBDEFB),
    Color(0xFF90CAF9),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // Utility Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get color with custom opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Check if color is dark (for adaptive text color)
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  /// Get contrasting text color (black or white based on background)
  static Color getContrastingTextColor(Color backgroundColor) {
    return isDark(backgroundColor) ? textWhite : textBlack;
  }
}

// ============================================================================
// Migration Guide (Old SColor → New AppColors)
// ============================================================================
//
// Find & Replace in your project:
// 1. SColor.primary → AppColors.primary
// 2. SColor.textPrimary → AppColors.textPrimary
// 3. SColor.textSecondary → AppColors.textSecondary
// 4. SColor.borderColor → AppColors.border
// 5. SColor.textBlackPrimary → AppColors.textBlack
//
// ============================================================================
