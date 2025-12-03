import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationModel {
  final String id;
  final String title;
  final String date;
  final String time;
  final String message;
  final String type; // highHeat, coldIce, highWind, rainWarning
  final Color iconColor;

  NotificationModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.message,
    required this.type,
    required this.iconColor,
  });
}

class NotificationsController extends GetxController {
  // Notifications list (will come from backend later)
  var notifications = <NotificationModel>[].obs;

  // Loading state
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Dummy data for UI
    loadDummyNotifications();
  }

  void loadDummyNotifications() {
    notifications.value = [
      NotificationModel(
        id: '1',
        title: 'High heat',
        date: 'Today',
        time: '11:30 am',
        message:
            "Message: 'It's getting hot today. Stay hydrated, avoid direct sun, take breaks, and stop work if needed.'",
        type: 'highHeat',
        iconColor: Colors.orange,
      ),
      NotificationModel(
        id: '2',
        title: 'High heat',
        date: 'Today',
        time: '10:30 am',
        message:
            "Message: 'It's getting hot today. Stay hydrated, avoid direct sun, take breaks, and stop work if needed.'",
        type: 'highHeat',
        iconColor: Colors.orange,
      ),
    ];
  }

  void fetchNotifications() {
    // TODO: Call backend API
  }
}
