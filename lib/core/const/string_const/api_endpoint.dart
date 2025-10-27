class APIEndPoint {
  static const String baseUrl = "http://103.186.20.253";
  static const String port = "8001";
  static const String apiBaseUrl = "$baseUrl:$port";

  // Authentication Endpoints
  static const String login = "$apiBaseUrl/auth/login/";
  static const String signup = "$apiBaseUrl/auth/register/";
  static const String mailVerification = "$apiBaseUrl/auth/check-email/";
  static const String otpVerification = "$apiBaseUrl/auth/verify-otp/";
  static const String resendOtp = "$apiBaseUrl/auth/resend-otp/";
  static const String passwordReset = "$apiBaseUrl/auth/password-reset-confirm/";
  static const String logout = "$apiBaseUrl/auth/logout/";

  // Chat
  static const String chatSessions = "$apiBaseUrl/chat/sessions/";
  static const String chatSession = "$apiBaseUrl/chat/sessions";

}