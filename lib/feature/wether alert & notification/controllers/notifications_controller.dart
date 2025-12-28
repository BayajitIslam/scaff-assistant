import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFICATION MODEL
// ═══════════════════════════════════════════════════════════════════════════

class NotificationModel {
  final int id;
  final String notificationType;
  final String notificationTypeDisplay;
  final String title;
  final String message;
  final String status;
  final String? temperature;
  final String? windSpeed;
  final String? weatherCondition;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String timeAgo;
  final String formattedDate;
  final Map<String, dynamic>? dataPayload;

  NotificationModel({
    required this.id,
    required this.notificationType,
    required this.notificationTypeDisplay,
    required this.title,
    required this.message,
    required this.status,
    this.temperature,
    this.windSpeed,
    this.weatherCondition,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.timeAgo,
    required this.formattedDate,
    this.dataPayload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      notificationType: json['notification_type'] ?? 'general',
      notificationTypeDisplay: json['notification_type_display'] ?? 'General',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      temperature: json['temperature'],
      windSpeed: json['wind_speed'],
      weatherCondition: json['weather_condition'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      timeAgo: json['time_ago'] ?? '',
      formattedDate: json['formatted_date'] ?? '',
      dataPayload: json['data_payload'],
    );
  }

  // Get alert type from data_payload
  String get alertType {
    return dataPayload?['alert_type'] ?? notificationType;
  }

  // Get icon color based on alert type
  Color get iconColor {
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

  // Get icon based on alert type
  IconData get icon {
    switch (alertType) {
      case 'high_heat':
        return Icons.wb_sunny_rounded;
      case 'cold_ice':
        return Icons.ac_unit_rounded;
      case 'high_wind':
        return Icons.air_rounded;
      case 'rain_warning':
        return Icons.water_drop_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  // Get date part from formatted_date (e.g., "Today" from "Today . 11:09 am")
  String get date {
    if (formattedDate.contains('.')) {
      return formattedDate.split('.').first.trim();
    }
    return formattedDate;
  }

  // Get time part from formatted_date (e.g., "11:09 am" from "Today . 11:09 am")
  String get time {
    if (formattedDate.contains('.')) {
      return formattedDate.split('.').last.trim();
    }
    return timeAgo;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

class NotificationsController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // States
  // ─────────────────────────────────────────────────────────────────────────
  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var errorMessage = ''.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────────────────────────────────
  var totalCount = 0.obs;
  var unreadCount = 0.obs;
  var currentPage = 1.obs;
  var hasMore = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch Notifications
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchNotifications({bool refresh = false}) async {
    Console.divider(label: 'FETCH NOTIFICATIONS');

    if (refresh) {
      currentPage.value = 1;
      isLoading.value = true;
    } else if (currentPage.value == 1) {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      final response = await ApiService.getAuth(
        // '${ApiEndpoints.notifications}?page=${currentPage.value}',
        ApiEndpoints.notifications,
      );

      Console.info('Response status: ${response.statusCode}');

      if (response.success && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] ?? responseData;

        // Parse pagination info
        totalCount.value = data['total_count'] ?? 0;
        unreadCount.value = data['unread_count'] ?? 0;
        hasMore.value = data['has_more'] ?? false;

        Console.info('Total: ${totalCount.value}');
        Console.info('Unread: ${unreadCount.value}');
        Console.info('Has More: ${hasMore.value}');

        // Parse notifications
        final notificationsList = data['notifications'] as List<dynamic>? ?? [];

        final parsedNotifications = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        if (refresh || currentPage.value == 1) {
          notifications.value = parsedNotifications;
        } else {
          notifications.addAll(parsedNotifications);
        }

        Console.success('Notifications loaded: ${notifications.length}');
      } else {
        Console.error('Fetch failed: ${response.message}');
        errorMessage.value = response.message ?? 'Failed to load notifications';
      }
    } catch (e) {
      Console.error('Notifications exception: $e');
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Refresh Notifications
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Load More (Pagination)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    Console.info('Loading more notifications...');
    isLoadingMore.value = true;
    currentPage.value++;
    await fetchNotifications();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mark as Read
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> markAsRead(int notificationId) async {
    Console.info('Marking notification $notificationId as read');

    // Optimistic update
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final old = notifications[index];
    if (old.isRead) return; // Already read

    notifications[index] = NotificationModel(
      id: old.id,
      notificationType: old.notificationType,
      notificationTypeDisplay: old.notificationTypeDisplay,
      title: old.title,
      message: old.message,
      status: old.status,
      temperature: old.temperature,
      windSpeed: old.windSpeed,
      weatherCondition: old.weatherCondition,
      isRead: true,
      readAt: DateTime.now().toIso8601String(),
      createdAt: old.createdAt,
      timeAgo: old.timeAgo,
      formattedDate: old.formattedDate,
      dataPayload: old.dataPayload,
    );

    if (unreadCount.value > 0) {
      unreadCount.value--;
    }

    try {
      final response = await ApiService.putAuth(
        '${ApiEndpoints.notifications}$notificationId/read/',
        body: {'is_read': true},
      );

      if (response.success) {
        Console.success('Notification marked as read');
      } else {
        // Revert on failure
        notifications[index] = old;
        unreadCount.value++;
      }
    } catch (e) {
      Console.error('Mark as read error: $e');
      // Revert on error
      notifications[index] = old;
      unreadCount.value++;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mark All as Read
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    Console.info('Marking all notifications as read');

    try {
      final response = await ApiService.putAuth(
        '${ApiEndpoints.notifications}read-all/',
        body: {},
      );

      if (response.success) {
        // Update local state
        notifications.value = notifications
            .map(
              (n) => NotificationModel(
                id: n.id,
                notificationType: n.notificationType,
                notificationTypeDisplay: n.notificationTypeDisplay,
                title: n.title,
                message: n.message,
                status: n.status,
                temperature: n.temperature,
                windSpeed: n.windSpeed,
                weatherCondition: n.weatherCondition,
                isRead: true,
                readAt: DateTime.now().toIso8601String(),
                createdAt: n.createdAt,
                timeAgo: n.timeAgo,
                formattedDate: n.formattedDate,
                dataPayload: n.dataPayload,
              ),
            )
            .toList();

        unreadCount.value = 0;

        Console.success('All notifications marked as read');
        SnackbarService.success('All marked as read');
      }
    } catch (e) {
      Console.error('Mark all as read error: $e');
      SnackbarService.error('Failed to mark as read');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete Notification
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> deleteNotification(int notificationId) async {
    Console.info('Deleting notification $notificationId');

    // Store for revert
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final deletedNotification = notifications[index];

    // Optimistic delete
    notifications.removeAt(index);
    totalCount.value--;
    if (!deletedNotification.isRead && unreadCount.value > 0) {
      unreadCount.value--;
    }

    try {
      final response = await ApiService.deleteAuth(
        '${ApiEndpoints.notifications}$notificationId/',
      );

      if (response.success) {
        Console.success('Notification deleted');
        SnackbarService.success('Notification deleted');
      } else {
        // Revert on failure
        notifications.insert(index, deletedNotification);
        totalCount.value++;
        if (!deletedNotification.isRead) {
          unreadCount.value++;
        }
        SnackbarService.error('Failed to delete');
      }
    } catch (e) {
      Console.error('Delete notification error: $e');
      // Revert on error
      notifications.insert(index, deletedNotification);
      totalCount.value++;
      if (!deletedNotification.isRead) {
        unreadCount.value++;
      }
      SnackbarService.error('Failed to delete');
    }
  }
}
