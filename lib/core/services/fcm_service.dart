// lib/core/services/fcm_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND MESSAGE HANDLER (Must be top-level)
// ═══════════════════════════════════════════════════════════════════════════
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 Background message received: ${message.messageId}');
}

// ═══════════════════════════════════════════════════════════════════════════
// FCM SERVICE
// ═══════════════════════════════════════════════════════════════════════════
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android Notification Channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'weather_alerts_channel',
    'Weather Alerts',
    description: 'Weather alert notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // INITIALIZE FCM
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> init() async {
    Console.divider(label: 'FCM INIT');

    try {
      // 1. Set background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Request permission
      await _requestPermission();

      // 3. Initialize local notifications
      await _initLocalNotifications();

      // 4. Get FCM token
      await _getAndSaveToken();

      // 5. Listen for token refresh
      _messaging.onTokenRefresh.listen((token) {
        Console.info('FCM Token refreshed');
        _saveToken(token);
        _registerIfLoggedIn();
      });

      // 6. Handle foreground messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // 7. Handle notification tap (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

      // 8. Handle notification tap (app terminated)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(seconds: 1), () {
          _onNotificationTap(initialMessage);
        });
      }

      Console.success('FCM initialized successfully');
    } catch (e) {
      Console.error('FCM init error: $e');
    }

    Console.divider();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REQUEST PERMISSION
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    Console.info('Notification permission: ${settings.authorizationStatus}');

    // For iOS foreground presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INITIALIZE LOCAL NOTIFICATIONS
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> _initLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channel for Android - FIXED LINE
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    Console.info('Local notifications initialized');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET AND SAVE FCM TOKEN
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        Console.info('FCM Token: ${token.substring(0, 30)}...');
        await _saveToken(token);
      }
    } catch (e) {
      Console.error('Get FCM token error: $e');
    }
  }

  static Future<void> _saveToken(String token) async {
    StorageService.setFcmToken(token);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REGISTER DEVICE WITH BACKEND
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> registerDevice() async {
    Console.divider(label: 'REGISTER FCM DEVICE');

    final token = StorageService.getFcmToken();
    if (token.isEmpty) {
      Console.warning('No FCM token available');
      Console.divider();
      return;
    }

    try {
      final response = await ApiService.postAuth(
        ApiEndpoints.fcmToken,
        body: {
          'token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        },
      );

      Console.auth('Response status: ${response.statusCode}');
      if (response.success) {
        Console.success('Device registered with backend');
      } else {
        Console.error('Register failed: ${response.message}');
      }
    } catch (e) {
      Console.error('Register device error: $e');
    }

    Console.divider();
  }

  static Future<void> _registerIfLoggedIn() async {
    final token = StorageService.getAccessToken();
    if (token.isNotEmpty) {
      await registerDevice();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UNREGISTER DEVICE FROM BACKEND
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> unregisterDevice() async {
    Console.divider(label: 'UNREGISTER FCM DEVICE');

    final token = StorageService.getFcmToken();
    if (token.isEmpty) {
      Console.warning('No FCM token to unregister');
      Console.divider();
      return;
    }

    try {
      final response = await ApiService.postAuth(
        ApiEndpoints.fcmToken,
        body: {'token': token},
      );

      if (response.success) {
        Console.success('Device unregistered from backend');
      } else {
        Console.error('Unregister failed: ${response.message}');
      }
    } catch (e) {
      Console.error('Unregister device error: $e');
    }

    Console.divider();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HANDLE FOREGROUND MESSAGE
  // ─────────────────────────────────────────────────────────────────────────
  static void _onForegroundMessage(RemoteMessage message) {
    Console.divider(label: '📩 FOREGROUND MESSAGE');
    Console.info('Title: ${message.notification?.title}');
    Console.info('Body: ${message.notification?.body}');
    Console.info('Data: ${message.data}');
    Console.divider();

    // Show local notification when app is in foreground
    _showLocalNotification(message);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHOW LOCAL NOTIFICATION
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title'] ?? 'Weather Alert';
    final body = notification?.body ?? data['message'] ?? '';
    final alertType = data['alert_type'] ?? 'general';

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: _getAlertColor(alertType),
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  // Get color based on alert type
  static Color _getAlertColor(String alertType) {
    switch (alertType) {
      case 'high_heat':
        return Colors.orange;
      case 'cold_ice':
        return Colors.lightBlue;
      case 'high_wind':
        return Colors.blueGrey;
      case 'rain_warning':
        return Colors.blue;
      default:
        return Colors.amber;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HANDLE NOTIFICATION TAP
  // ─────────────────────────────────────────────────────────────────────────
  static void _onNotificationTap(RemoteMessage message) {
    Console.info('🔔 Notification tapped');
    Console.info('Data: ${message.data}');

    _navigateToNotifications();
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    Console.info('🔔 Local notification tapped');
    Console.info('Payload: ${response.payload}');

    _navigateToNotifications();
  }

  static void _navigateToNotifications() {
    if (Get.currentRoute != RouteNames.notificationScreen) {
      Get.toNamed(RouteNames.notificationScreen);
    }
  }
}
