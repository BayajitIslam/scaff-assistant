/// ═══════════════════════════════════════════════════════════════════════════
/// IMAGE PATHS
/// Centralized image asset paths
/// ═══════════════════════════════════════════════════════════════════════════
class ImagePaths {
  // ─────────────────────────────────────────────────────────────────────────
  // Branding
  // ─────────────────────────────────────────────────────────────────────────

  static const String logo = 'assets/branding/logo.png';
  static const String logoIcon = 'assets/branding/logo_icon.png';
  static const String logoWhite = 'assets/branding/logo_white.png';
  static const String splashLogo = 'assets/branding/splash_logo.png';

  // ─────────────────────────────────────────────────────────────────────────
  // Social Login
  // ─────────────────────────────────────────────────────────────────────────

  static const String google = 'assets/images/google.png';
  static const String apple = 'assets/images/apple.png';
  static const String facebook = 'assets/images/facebook.png';

  // ─────────────────────────────────────────────────────────────────────────
  // Illustrations
  // ─────────────────────────────────────────────────────────────────────────

  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';
  static const String noInternet = 'assets/images/no_internet.png';
  static const String success = 'assets/images/success.png';

  // ─────────────────────────────────────────────────────────────────────────
  // Feature Images
  // ─────────────────────────────────────────────────────────────────────────

  static const String weatherBg = 'assets/images/weather_bg.png';
  static const String calculatorBg = 'assets/images/calculator_bg.png';
  static const String chatBg = 'assets/images/chat_bg.png';
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY SUPPORT
// ═══════════════════════════════════════════════════════════════════════════
/// @deprecated Use ImagePaths instead
typedef ImagePath = ImagePaths;
