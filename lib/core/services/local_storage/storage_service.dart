import 'package:get_storage/get_storage.dart';
import 'package:scaffassistant/core/utils/console.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// STORAGE SERVICE
/// Unified local storage service (combines UserInfo + UserStatus)
/// ═══════════════════════════════════════════════════════════════════════════
class StorageService {
  static final GetStorage _box = GetStorage();

  // ─────────────────────────────────────────────────────────────────────────
  // Storage Keys
  // ─────────────────────────────────────────────────────────────────────────

  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserId = 'userId';
  static const String _keyAccessToken = 'accessToken';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyIsFirstTimeUser = 'isFirstTimeUser';
  static const String _keyIsPremium = 'premium';
  static const String _keyFcmToken = 'fcmToken';

  // ─────────────────────────────────────────────────────────────────────────
  // User Information
  // ─────────────────────────────────────────────────────────────────────────

  /// Set user name
  static void setUserName(String name) {
    _box.write(_keyUserName, name);
    Console.storage('User name saved: $name');
  }

  /// Get user name
  static String getUserName() {
    return _box.read(_keyUserName) ?? '';
  }

  /// Set user email
  static void setUserEmail(String email) {
    _box.write(_keyUserEmail, email);
  }

  /// Get user email
  static String getUserEmail() {
    return _box.read(_keyUserEmail) ?? '';
  }

  /// Set user ID
  static void setUserId(String id) {
    _box.write(_keyUserId, id);
  }

  /// Get user ID
  static String getUserId() {
    return _box.read(_keyUserId) ?? '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Authentication Tokens
  // ─────────────────────────────────────────────────────────────────────────

  /// Set access token
  static void setAccessToken(String token) {
    _box.write(_keyAccessToken, token);
    Console.storage('Access token saved');
  }

  /// Get access token
  static String getAccessToken() {
    return _box.read(_keyAccessToken) ?? '';
  }

  /// Set refresh token
  static void setRefreshToken(String token) {
    _box.write(_keyRefreshToken, token);
  }

  /// Get refresh token
  static String getRefreshToken() {
    return _box.read(_keyRefreshToken) ?? '';
  }

  /// Check if user has valid token
  static bool hasValidToken() {
    return getAccessToken().isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // User Status
  // ─────────────────────────────────────────────────────────────────────────

  /// Set logged in status
  static void setIsLoggedIn(bool status) {
    _box.write(_keyIsLoggedIn, status);
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _box.read(_keyIsLoggedIn) ?? false;
  }

  /// Set first time user status
  static void setIsFirstTimeUser(bool status) {
    _box.write(_keyIsFirstTimeUser, status);
  }

  /// Check if first time user
  static bool isFirstTimeUser() {
    return _box.read(_keyIsFirstTimeUser) ?? true;
  }

  /// Set premium status
  static void setIsPremium(bool status) {
    _box.write(_keyIsPremium, status);
  }

  /// Check if user is premium
  static bool isPremium() {
    return _box.read(_keyIsPremium) ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session Management
  // ─────────────────────────────────────────────────────────────────────────

  /// Save complete user session after login
  static void saveUserSession({
    required String userName,
    required String email,
    required String accessToken,
    String? refreshToken,
    String? userId,
  }) {
    setUserName(userName);
    setUserEmail(email);
    setAccessToken(accessToken);
    if (refreshToken != null) setRefreshToken(refreshToken);
    if (userId != null) setUserId(userId);
    setIsLoggedIn(true);
    setIsFirstTimeUser(false);
    Console.success('User session saved');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FCM Token
  // ─────────────────────────────────────────────────────────────────────────

  /// Set FCM token
  static void setFcmToken(String token) {
    _box.write(_keyFcmToken, token);
  }

  /// Get FCM token
  static String getFcmToken() {
    return _box.read(_keyFcmToken) ?? '';
  }

  /// Clear user session on logout
  static void clearUserSession() {
    _box.remove(_keyUserName);
    _box.remove(_keyUserEmail);
    _box.remove(_keyUserId);
    _box.remove(_keyAccessToken);
    _box.remove(_keyRefreshToken);
    _box.remove(_keyIsLoggedIn);
    Console.info('User session cleared');
  }

  /// Clear all app data
  static void clearAll() {
    _box.erase();
    Console.warning('All storage cleared');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY SUPPORT - For backward compatibility
// ═══════════════════════════════════════════════════════════════════════════

/// @deprecated Use StorageService instead
class UserInfo {
  static void setUserName(String name) => StorageService.setUserName(name);
  static String getUserName() => StorageService.getUserName();
  static void setUserEmail(String email) => StorageService.setUserEmail(email);
  static String getUserEmail() => StorageService.getUserEmail();
  static void setAccessToken(String token) =>
      StorageService.setAccessToken(token);
  static String getAccessToken() => StorageService.getAccessToken();
  static void clearUserInfo() => StorageService.clearUserSession();
}

/// @deprecated Use StorageService instead
class UserStatus {
  static void setIsLoggedIn(bool status) =>
      StorageService.setIsLoggedIn(status);
  static bool getIsLoggedIn() => StorageService.isLoggedIn();
  static void setIsFirstTimeUser(bool status) =>
      StorageService.setIsFirstTimeUser(status);
  static bool getIsFirstTimeUser() => StorageService.isFirstTimeUser();
}
