import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scaffassistant/core/services/connectivity_service.dart';
import 'package:scaffassistant/core/utils/console.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP INITIALIZER
/// Handles all app initialization in one centralized place
/// ═══════════════════════════════════════════════════════════════════════════
class AppInitializer {
  static late SharedPreferences prefs;

  /// Initialize all app dependencies
  static Future<void> init() async {
    Console.divider(label: 'APP INITIALIZATION');

    try {
      // ─────────────────────────────────────────────────────────────────────
      // Storage Initialization
      // ─────────────────────────────────────────────────────────────────────
      await GetStorage.init();
      Console.success('GetStorage initialized');

      prefs = await SharedPreferences.getInstance();
      Console.success('SharedPreferences initialized');

      // ─────────────────────────────────────────────────────────────────────
      // Connectivity Service (No Internet Dialog)
      // ─────────────────────────────────────────────────────────────────────
      final connectivityService = ConnectivityService();
      Get.put(connectivityService, permanent: true);
      await connectivityService.init();

      // ─────────────────────────────────────────────────────────────────────

      Console.success('App initialization complete ✅');
      Console.divider();
    } catch (e) {
      Console.error('Initialization failed: $e');
      rethrow;
    }
  }
}
