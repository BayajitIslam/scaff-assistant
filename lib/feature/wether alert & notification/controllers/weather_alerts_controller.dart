import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';

class WeatherAlertsController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Loading States
  // ─────────────────────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final isUpdating = false.obs;

  var errorMessage = ''.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Location toggle
  // ─────────────────────────────────────────────────────────────────────────
  var isLocationEnabled = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Alert type toggles
  // ─────────────────────────────────────────────────────────────────────────
  var isHighHeatEnabled = true.obs;
  var isColdIceEnabled = true.obs;
  var isHighWindEnabled = true.obs;
  var isRainWarningEnabled = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Settings ID
  // ─────────────────────────────────────────────────────────────────────────
  int? settingsId;

  // ─────────────────────────────────────────────────────────────────────────
  // Alert Data (Dynamic from API)
  // ─────────────────────────────────────────────────────────────────────────
  final alertData = <String, Map<String, String>>{
    'highHeat': {
      'title': 'High heat',
      'trigger': 'Trigger : above 28°C',
      'message':
          "Message: 'It's getting hot today. Stay hydrated, avoid direct sun, take breaks, and stop work if needed.'",
    },
    'coldIce': {
      'title': 'Cold / Ice',
      'trigger': 'Trigger: 0°C or below',
      'message':
          "Message: 'Ice warning. Roads and scaffold surfaces may be slippery. Take extra care when driving or working at height.'",
    },
    'highWind': {
      'title': 'High wind',
      'trigger': 'Trigger: 25-30 mph caution, 30+ mph danger',
      'message':
          "Message: 'Strong winds today. Be cautious at height and consider postponing unsafe activities.'",
    },
    'rainWarning': {
      'title': 'Rain warning',
      'trigger': 'Trigger: Rain forecast within 1 hour',
      'message':
          "Message: 'Rain incoming. Surfaces may be slippery — be cautious on the scaffold.'",
    },
  }.obs;

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await fetchPreferences();
    await _checkLocationPermissionStatus();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. FETCH PREFERENCES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchPreferences() async {
    Console.divider(label: 'FETCH WEATHER PREFERENCES');
    isLoading.value = true;

    try {
      final response = await ApiService.getAuth(
        ApiEndpoints.weatherPreferences,
      );

      Console.info('Response status: ${response.statusCode}');

      if (response.success && response.data != null) {
        // Get nested data
        final responseData = response.data as Map<String, dynamic>;
        final data =
            responseData['data'] as Map<String, dynamic>? ?? responseData;

        // Parse settings
        if (data['settings'] != null) {
          settingsId = data['settings']['id'];
          final useLocation = data['settings']['use_location'] ?? false;
          isLocationEnabled.value = useLocation;
          Console.info('Settings ID: $settingsId');
          Console.info('Location enabled: $useLocation');
        }

        // Parse preferences
        if (data['preferences'] != null) {
          final prefs = data['preferences'] as List<dynamic>;

          for (var pref in prefs) {
            final typeName = pref['alert_type_name']?.toString();
            final isEnabled = pref['is_enabled'] == true;

            Console.info('Parsing: $typeName = $isEnabled');

            switch (typeName) {
              case 'high_heat':
                isHighHeatEnabled.value = isEnabled;
                _updateAlertData('highHeat', pref);
                break;
              case 'cold_ice':
                isColdIceEnabled.value = isEnabled;
                _updateAlertData('coldIce', pref);
                break;
              case 'high_wind':
                isHighWindEnabled.value = isEnabled;
                _updateAlertData('highWind', pref);
                break;
              case 'rain_warning':
                isRainWarningEnabled.value = isEnabled;
                _updateAlertData('rainWarning', pref);
                break;
            }
          }
        }

        // Force UI refresh
        alertData.refresh();

        Console.success('Weather preferences loaded');
      } else {
        Console.error('Fetch failed: ${response.message}');
        errorMessage.value = response.message ?? 'Failed to load Wether Alert';
      }
    } catch (e) {
      Console.error('Weather exception: $e');
      errorMessage.value = 'Failed to load preferences';
      SnackbarService.error('Failed to load preferences');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE ALERT DATA FROM API
  // ═══════════════════════════════════════════════════════════════════════════

  void _updateAlertData(String key, Map<String, dynamic> pref) {
    String trigger = '';
    String message = '';

    switch (pref['alert_type_name']) {
      case 'high_heat':
        final threshold = pref['high_heat_threshold'] ?? '28.00';
        trigger =
            'Trigger : above ${double.parse(threshold.toString()).toInt()}°C';
        message = "Message: '${pref['high_heat_message'] ?? ''}'";
        break;
      case 'cold_ice':
        final threshold = pref['cold_threshold'] ?? '0.00';
        trigger =
            'Trigger: ${double.parse(threshold.toString()).toInt()}°C or below';
        message = "Message: '${pref['cold_message'] ?? ''}'";
        break;
      case 'high_wind':
        final caution = pref['wind_caution_threshold'] ?? '25.00';
        final danger = pref['wind_danger_threshold'] ?? '30.00';
        trigger =
            'Trigger: ${double.parse(caution.toString()).toInt()}-${double.parse(danger.toString()).toInt()} mph caution, ${double.parse(danger.toString()).toInt()}+ mph danger';
        message = "Message: '${pref['wind_message'] ?? ''}'";
        break;
      case 'rain_warning':
        final hours = pref['rain_forecast_hours'] ?? 1;
        trigger = 'Trigger: Rain forecast within $hours hour';
        message = "Message: '${pref['rain_message'] ?? ''}'";
        break;
    }

    alertData[key] = {
      'title': pref['alert_type_display'] ?? alertData[key]!['title']!,
      'trigger': trigger,
      'message': message,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. TOGGLE ALERT
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleAlert(String alertType, bool value) async {
    // Convert to API format
    String apiAlertType;

    switch (alertType) {
      case 'highHeat':
        apiAlertType = 'high_heat';
        break;
      case 'coldIce':
        apiAlertType = 'cold_ice';
        break;
      case 'highWind':
        apiAlertType = 'high_wind';
        break;
      case 'rainWarning':
        apiAlertType = 'rain_warning';
        break;
      default:
        Console.error('Unknown alert type: $alertType');
        return;
    }

    // Update local state FIRST (optimistic update)
    _updateLocalToggle(alertType, value);

    Console.info('Toggle $apiAlertType: $value');
    isUpdating.value = true;

    try {
      final response = await ApiService.putAuth(
        '${ApiEndpoints.weatherPreferences}$apiAlertType/',
        body: {'is_enabled': value},
      );

      if (response.success) {
        Console.success('Alert $apiAlertType updated');
      } else {
        // Revert on failure
        _updateLocalToggle(alertType, !value);
        SnackbarService.error(response.message ?? 'Failed to update');
      }
    } catch (e) {
      // Revert on error
      _updateLocalToggle(alertType, !value);
      Console.error('Toggle alert error: $e');
      SnackbarService.error('Failed to update');
    } finally {
      isUpdating.value = false;
    }
  }

  // Helper to update local toggle state
  void _updateLocalToggle(String alertType, bool value) {
    switch (alertType) {
      case 'highHeat':
        isHighHeatEnabled.value = value;
        break;
      case 'coldIce':
        isColdIceEnabled.value = value;
        break;
      case 'highWind':
        isHighWindEnabled.value = value;
        break;
      case 'rainWarning':
        isRainWarningEnabled.value = value;
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. TOGGLE LOCATION
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleLocation(bool value) async {
    Console.divider(label: 'TOGGLE LOCATION: $value');

    if (value) {
      // ─────────────────────────────────────────────────────────────────────
      // ENABLE LOCATION
      // ─────────────────────────────────────────────────────────────────────

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Console.warning('Location service disabled');
        _showLocationServiceDialog();
        return;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      Console.info('Current permission: $permission');

      if (permission == LocationPermission.deniedForever) {
        Console.warning('Permission denied forever');
        _showLocationSettingsDialog();
        return;
      }

      if (permission == LocationPermission.denied) {
        Console.info('Requesting permission...');
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          Console.warning('Permission denied');
          SnackbarService.error('Location permission denied');
          return;
        }

        if (permission == LocationPermission.deniedForever) {
          Console.warning('Permission denied forever');
          _showLocationSettingsDialog();
          return;
        }
      }

      // Permission granted - get location
      Console.info('Permission granted, getting location...');
      isLocationEnabled.value = true;
      isUpdating.value = true;

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );

        Console.info('Location: ${position.latitude}, ${position.longitude}');
        Console.info('Updating backend...');

        final response = await ApiService.putAuth(
          ApiEndpoints.weatherUpdateLocation,
          body: {
            'use_location': true,
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );

        Console.info('Response success: ${response.success}');
        Console.info('Response data: ${response.data}');

        if (response.success) {
          Console.success('Location enabled successfully');
          SnackbarService.success('Location enabled');
        } else {
          Console.error('Backend update failed: ${response.message}');
          isLocationEnabled.value = false;
          SnackbarService.error(response.message ?? 'Failed to update');
        }
      } catch (e) {
        Console.error('Location error: $e');
        isLocationEnabled.value = false;
        SnackbarService.error('Failed to get location');
      } finally {
        isUpdating.value = false;
      }
    } else {
      // ─────────────────────────────────────────────────────────────────────
      // DISABLE LOCATION
      // ─────────────────────────────────────────────────────────────────────

      Console.info('Disabling location...');
      isLocationEnabled.value = false;
      isUpdating.value = true;

      try {
        final response = await ApiService.putAuth(
          ApiEndpoints.weatherUpdateLocation,
          body: {'use_location': false},
        );

        Console.info('Response success: ${response.success}');

        if (response.success) {
          Console.success('Location disabled successfully');
          SnackbarService.success('Location disabled');
        } else {
          Console.error('Backend update failed: ${response.message}');
          isLocationEnabled.value = true;
          SnackbarService.error(response.message ?? 'Failed to update');
        }
      } catch (e) {
        Console.error('Disable location error: $e');
        isLocationEnabled.value = true;
        SnackbarService.error('Failed to update');
      } finally {
        isUpdating.value = false;
      }
    }

    Console.divider();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECK LOCATION PERMISSION STATUS (ON SCREEN LOAD)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _checkLocationPermissionStatus() async {
    // Only check if backend says location is enabled
    if (!isLocationEnabled.value) return;

    Console.info('Checking location permission status...');

    // Check service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Console.warning('Location service disabled - syncing with backend');
      await _disableLocationOnBackend();
      return;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Console.warning('Location permission revoked - syncing with backend');
      await _disableLocationOnBackend();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISABLE LOCATION ON BACKEND
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _disableLocationOnBackend() async {
    isLocationEnabled.value = false;

    try {
      await ApiService.putAuth(
        ApiEndpoints.weatherUpdateLocation,
        body: {'use_location': false},
      );
      Console.info('Backend synced - location disabled');
    } catch (e) {
      Console.error('Backend sync error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  // Show Location Settings Dialog (Permission Denied Forever)
  void _showLocationSettingsDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Location Permission'),
          ],
        ),
        content: const Text(
          'Location permission is required for weather alerts based on your location.\n\n'
          'Please enable location permission in app settings.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Show Location Service Dialog (GPS Disabled)
  void _showLocationServiceDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.gps_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Location Service'),
          ],
        ),
        content: const Text(
          'Location service (GPS) is disabled on your device.\n\n'
          'Please enable it to use location-based weather alerts.',
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
              ),
              Flexible(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Geolocator.openLocationSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
