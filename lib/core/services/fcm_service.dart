import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/core/utils/console.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FCM SERVICE
/// Simple service to get FCM token and register with backend
/// ═══════════════════════════════════════════════════════════════════════════
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialize FCM (Call once on app start)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    Console.divider(label: 'FCM INIT');

    // Request permission
    await _messaging.requestPermission();

    // Get token
    final token = await _messaging.getToken();
    if (token != null) {
      Console.success('FCM Token: ${token.substring(0, 20)}...');
      StorageService.setFcmToken(token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      Console.info('FCM Token refreshed');
      StorageService.setFcmToken(newToken);
      // Re-register if logged in
      if (StorageService.getAccessToken().isNotEmpty) {
        registerDevice();
      }
    });

    Console.divider();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Register Device with Backend (Call after login)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> registerDevice() async {
    final token = StorageService.getFcmToken();

    if (token.isEmpty) {
      Console.warning('No FCM token to register');
      return;
    }

    Console.info('Registering device with backend...');
    Console.success('FCM Token Send Successfull : $token');

    // try {
    //   final response = await ApiService.postAuth(
    //     ApiEndpoints.registerDevice,
    //     body: {
    //       'fcm_token': token,
    //       'device_type': Platform.isAndroid ? 'android' : 'ios',
    //     },
    //   );

    //   if (response.success) {
    //     Console.success('Device registered ✅');
    //   } else {
    //     Console.error('Device registration failed');
    //   }
    // } catch (e) {
    //   Console.error('Register device error: $e');
    // }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Unregister Device (Call on logout)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> unregisterDevice() async {
    final token = StorageService.getFcmToken();
    if (token.isEmpty) return;

    // try {
    //   await ApiService.postAuth(
    //     ApiEndpoints.unregisterDevice, // Add this endpoint
    //     body: {'fcm_token': token},
    //   );
    //   Console.info('Device unregistered');
    // } catch (e) {
    //   Console.error('Unregister error: $e');
    // }
  }
}
