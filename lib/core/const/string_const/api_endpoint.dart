class APIEndPoint {
  // static const String baseUrl = "https://scaffapi.dsrt321.online";
  static const String baseUrl = "http://165.101.214.252:8001";
  static const String port = "8001";
  static const String apiBaseUrl = baseUrl;

  // Authentication Endpoints
  static const String login = "$apiBaseUrl/auth/login/";
  static const String signup = "$apiBaseUrl/auth/register/";
  static const String mailVerification = "$apiBaseUrl/auth/check-email/";
  static const String otpVerification = "$apiBaseUrl/auth/verify-otp/";
  static const String resendOtp = "$apiBaseUrl/auth/resend-otp/";
  static const String passwordReset = "$apiBaseUrl/auth/password-reset-confirm/";
  static const String logout = "$apiBaseUrl/auth/logout/";
  static const String googleLogin = "$apiBaseUrl/auth/google-login/";

  // Chat
  static const String chatMessages = "$apiBaseUrl/chat/ask/";
  static const String chatSessions = "$apiBaseUrl/chat/sessions/";
  static const String chatSession = "$apiBaseUrl/chat/sessions";

}