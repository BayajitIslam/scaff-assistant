import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/fcm_service.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/feature/subscription/controller/subscription_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GOOGLE SIGN IN SERVICE
/// Handles Google authentication for both login and signup
/// ═══════════════════════════════════════════════════════════════════════════
class GoogleSignInService {
  // ─────────────────────────────────────────────────────────────────────────
  // Configuration
  // ─────────────────────────────────────────────────────────────────────────

  /// Google OAuth Client ID (Web Client ID from Google Console)
  static const String _serverClientId =
      '594391332991-ddau3boono9g5c2acl9p80pt065c1uq0.apps.googleusercontent.com';

  /// Required OAuth scopes
  static const List<String> _scopes = ['email', 'profile', 'openid'];

  // ─────────────────────────────────────────────────────────────────────────
  // Google Sign In (Main Method)
  // ─────────────────────────────────────────────────────────────────────────

  /// Sign in with Google and authenticate with backend
  /// Returns true if successful, false otherwise
  static Future<bool> signIn() async {
    Console.divider(label: 'GOOGLE SIGN IN');
    Console.auth('Starting Google Sign-In process...');

    try {
      // Step 1: Initialize Google Sign-In
      await _initializeGoogleSignIn();

      // Step 2: Check platform support
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        Console.error('Google Sign-In not supported on this platform');
        SnackbarService.error('Google Sign-In not supported on this device');
        return false;
      }

      // Step 3: Authenticate with Google
      final account = await _authenticateWithGoogle();
      if (account == null) return false;

      // Step 4: Get tokens
      final tokens = await _getAuthorizationTokens(account);
      if (tokens == null) return false;

      // Step 5: Send to backend
      final success = await _authenticateWithBackend(tokens, account);
      // Register device for push notifications
      FcmService.registerDevice();

      Console.divider();
      return success;
    } on GoogleSignInException catch (e) {
      _handleGoogleSignInException(e);
      return false;
    } catch (e) {
      Console.error('Unexpected error: $e');
      SnackbarService.error('An unexpected error occurred');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Initialize Google Sign-In
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _initializeGoogleSignIn() async {
    Console.auth('Initializing Google Sign-In...');

    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);

    Console.success('Google Sign-In initialized');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Authenticate with Google
  // ─────────────────────────────────────────────────────────────────────────

  static Future<GoogleSignInAccount?> _authenticateWithGoogle() async {
    Console.auth('Authenticating with Google...');

    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();

      Console.success('Google authentication successful');
      Console.info('User: ${account.email}');
      Console.info('Name: ${account.displayName}');

      return account;
    } catch (e) {
      Console.error('Google authentication failed: $e');
      SnackbarService.error('Google authentication failed');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Get Authorization Tokens
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, String?>?> _getAuthorizationTokens(
    GoogleSignInAccount account,
  ) async {
    Console.auth('Getting authorization tokens...');

    try {
      final GoogleSignInClientAuthorization authorization = await account
          .authorizationClient
          .authorizeScopes(_scopes);

      final String? accessToken = authorization.accessToken;
      final String? idToken = authorization.accessToken; // Use as ID token

      if (idToken == null || idToken.isEmpty) {
        Console.error('Failed to get Google ID token');
        SnackbarService.error('Failed to get Google authentication token');
        return null;
      }

      Console.success('Tokens received');
      Console.auth('ID Token: ${idToken.substring(0, 20)}...');

      return {'accessToken': accessToken, 'idToken': idToken};
    } catch (e) {
      Console.error('Authorization error: $e');
      SnackbarService.error('Google authorization failed');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Authenticate with Backend
  // ─────────────────────────────────────────────────────────────────────────

  static Future<bool> _authenticateWithBackend(
    Map<String, String?> tokens,
    GoogleSignInAccount account,
  ) async {
    Console.auth('Sending token to backend...');
    Console.api('POST ${ApiEndpoints.googleLogin}');

    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.googleLogin),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'access_token': tokens['idToken']}),
          )
          .timeout(const Duration(seconds: 10));

      Console.api('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Console.success('Backend authentication successful');

        // Save user session
        _saveUserSession(responseData, account);

        // Navigate based on subscription
        await _navigateAfterLogin();

        return true;
      } else {
        Console.error('Backend authentication failed: ${response.body}');

        try {
          final errorData = jsonDecode(response.body);
          SnackbarService.error(errorData['error'] ?? 'Google login failed');
        } catch (_) {
          SnackbarService.error('Google login failed');
        }

        return false;
      }
    } catch (e) {
      Console.error('Backend request failed: $e');
      SnackbarService.error('Connection error. Please try again.');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Save User Session
  // ─────────────────────────────────────────────────────────────────────────

  static void _saveUserSession(
    Map<String, dynamic> responseData,
    GoogleSignInAccount account,
  ) {
    Console.storage('Saving user session...');

    StorageService.saveUserSession(
      userName:
          responseData['full_name'] ??
          responseData['username'] ??
          account.displayName ??
          '',
      email: responseData['email'] ?? account.email,
      accessToken: responseData['access_token']?['access'] ?? '',
      refreshToken: responseData['access_token']?['refresh'],
      userId: responseData['id']?.toString(),
    );
    Console.info('Access token: ${responseData['access_token']?['access']}');
    Console.success('User session saved');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigate After Login
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _navigateAfterLogin() async {
    // Check subscription from Play Store and navigate
    Console.nav('Login success → Checking subscription');
    await SubscriptionController.checkAndNavigateAfterLogin();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handle Google Sign-In Exception
  // ─────────────────────────────────────────────────────────────────────────

  static void _handleGoogleSignInException(GoogleSignInException e) {
    String errorMessage;

    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        errorMessage = 'Google sign-in was cancelled';
        Console.warning('User cancelled Google sign-in');
        break;
      case GoogleSignInExceptionCode.clientConfigurationError:
        errorMessage = 'Google sign-in configuration error';
        Console.error('Client configuration error: ${e.description}');
        break;
      default:
        errorMessage = 'Google sign-in error: ${e.description}';
        Console.error('GoogleSignInException: ${e.code} - ${e.description}');
    }

    SnackbarService.error(errorMessage);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────────────────────────────

  /// Sign out from Google
  static Future<void> signOut() async {
    Console.auth('Signing out from Google...');

    try {
      await GoogleSignIn.instance.signOut();
      Console.success('Google sign out successful');
    } catch (e) {
      Console.error('Google sign out failed: $e');
    }
  }
}
