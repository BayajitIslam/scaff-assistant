/// ═══════════════════════════════════════════════════════════════════════════
/// API ENDPOINTS
/// Centralized API endpoint definitions
/// ═══════════════════════════════════════════════════════════════════════════
class ApiEndpoints {
  // ─────────────────────────────────────────────────────────────────────────
  // Base URL Configuration
  // ─────────────────────────────────────────────────────────────────────────

  //   static const String baseUrl = 'http://165.101.214.252:9001';
  static const String baseUrl = 'https://scaffapi.dsrt321.online';

  // ─────────────────────────────────────────────────────────────────────────
  // Authentication Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String login = '$baseUrl/auth/login/';
  static const String signup = '$baseUrl/auth/register/';
  static const String mailVerification = '$baseUrl/auth/check-email/';
  static const String otpVerification = '$baseUrl/auth/verify-otp/';
  static const String resendOtp = '$baseUrl/auth/resend-otp/';
  static const String passwordReset = '$baseUrl/auth/password-reset-confirm/';
  static const String logout = '$baseUrl/auth/logout/';
  static const String googleLogin = '$baseUrl/auth/google-login/';
  static const String appleLogin = '$baseUrl/auth/apple-login/';

  // ─────────────────────────────────────────────────────────────────────────
  // Chat / AI Assistant Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String chatAsk = '$baseUrl/chat/ask/';
  static const String chatSessions = '$baseUrl/chat/sessions/';
  static const String chatSession = '$baseUrl/chat/sessions'; // + /{id}/
  static const String chatHistory =
      '$baseUrl/chat/history/'; // + ?session_id=xxx

  // ─────────────────────────────────────────────────────────────────────────
  // Calculator Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String weightCalculator =
      '$baseUrl/calculator/calculate-weight/';
  static const String quantityCalculator =
      '$baseUrl/calculator/calculate-quantity/';

  // ─────────────────────────────────────────────────────────────────────────
  // Digital Passport Endpoints
  // ─────────────────────────────────────────────────────────────────────────

  static const String digitalPassportUpload = '$baseUrl/doc/cards/upload/';
  static const String digitalPassportFetchAll = '$baseUrl/doc/cards/';
  // PATCH/DELETE: digitalPassportFetchAll + {id}/

  // ─────────────────────────────────────────────────────────────────────────
  // Weather Endpoints (Future)
  // ─────────────────────────────────────────────────────────────────────────

  static const String weatherPreferences = '$baseUrl/weather/preferences/';
  static const String weatherUpdateLocation = '$baseUrl/weather/location/';
  static const String weatherUpdatePreference = '$baseUrl/weather/preferences/';
  static const String weatherAlerts = '$baseUrl/weather/alerts/';
  static const String fcmToken = '$baseUrl/weather/fcm-token/';

  // ─────────────────────────────────────────────────────────────────────────
  // Notification Endpoints (Future)
  // ─────────────────────────────────────────────────────────────────────────

  static const String notifications = '$baseUrl/weather/notifications';

  // ─────────────────────────────────────────────────────────────────────────
  // User Profile Endpoints (Future)
  // ─────────────────────────────────────────────────────────────────────────

  static const String profile = '$baseUrl/user/profile/';
  static const String profileUpdate = '$baseUrl/user/profile/update/';
  static const String profileAvatar = '$baseUrl/user/profile/avatar/';

  // ─────────────────────────────────────────────────────────────────────────
  // FAQ Endpoints (Future)
  // ─────────────────────────────────────────────────────────────────────────

  static const String faqList = '$baseUrl/faq/';
  static const String faqSearch = '$baseUrl/faq/search/';
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY SUPPORT - For backward compatibility
// ═══════════════════════════════════════════════════════════════════════════
/// @deprecated Use ApiEndpoints instead
class APIEndPoint {
  static const String baseUrl = ApiEndpoints.baseUrl;
  static const String apiBaseUrl = baseUrl;

  // Auth
  static const String login = ApiEndpoints.login;
  static const String signup = ApiEndpoints.signup;
  static const String mailVerification = ApiEndpoints.mailVerification;
  static const String otpVerification = ApiEndpoints.otpVerification;
  static const String resendOtp = ApiEndpoints.resendOtp;
  static const String passwordReset = ApiEndpoints.passwordReset;
  static const String logout = ApiEndpoints.logout;
  static const String googleLogin = ApiEndpoints.googleLogin;

  // Chat
  static const String chatMessages = ApiEndpoints.chatAsk;
  static const String chatSessions = ApiEndpoints.chatSessions;
  static const String chatSession = ApiEndpoints.chatSession;

  // Calculator
  static const String weightCalculator = ApiEndpoints.weightCalculator;

  // Digital Passport
  static const String digitalPassportUpload =
      ApiEndpoints.digitalPassportUpload;
  static const String digitalPassportFetchAll =
      ApiEndpoints.digitalPassportFetchAll;
}
