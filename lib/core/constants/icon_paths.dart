/// ═══════════════════════════════════════════════════════════════════════════
/// ICON PATHS
/// Centralized icon asset paths
/// ═══════════════════════════════════════════════════════════════════════════
class IconPaths {
  // ─────────────────────────────────────────────────────────────────────────
  // Navigation Icons
  // ─────────────────────────────────────────────────────────────────────────

  static const String menu = 'assets/icons/menu.png';
  static const String back = 'assets/icons/back.png';
  static const String close = 'assets/icons/close.png';
  static const String home = 'assets/icons/home.png';

  // ─────────────────────────────────────────────────────────────────────────
  // Settings Icons
  // ─────────────────────────────────────────────────────────────────────────

  static const String email = 'assets/icons/email.png';
  static const String shield = 'assets/icons/shild.png';
  static const String exit = 'assets/icons/exit.png';
  static const String settings = 'assets/icons/settings.png';
  static const String profile = 'assets/icons/profile.png';

  // ─────────────────────────────────────────────────────────────────────────
  // Feature Icons
  // ─────────────────────────────────────────────────────────────────────────

  static const String note = 'assets/icons/note.png';
  static const String calculator = 'assets/icons/calculator.png';
  static const String weather = 'assets/icons/weather.png';
  static const String chat = 'assets/icons/chat.png';
  static const String notification = 'assets/icons/notification.png';
  static const String passport = 'assets/icons/passport.png';
  static const String camera = 'assets/icons/camera.png';

  // ─────────────────────────────────────────────────────────────────────────
  // Action Icons
  // ─────────────────────────────────────────────────────────────────────────

  static const String add = 'assets/icons/add.png';
  static const String edit = 'assets/icons/edit.png';
  static const String delete = 'assets/icons/delete.png';
  static const String search = 'assets/icons/search.png';
  static const String filter = 'assets/icons/filter.png';
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY SUPPORT
// ═══════════════════════════════════════════════════════════════════════════
/// @deprecated Use IconPaths instead
class IconPath {
  static const String menuIcon = IconPaths.menu;
  static const String emailIcon = IconPaths.email;
  static const String shildIcon = IconPaths.shield;
  static const String exitIcon = IconPaths.exit;
  static const String noteIcon = IconPaths.note;
}
