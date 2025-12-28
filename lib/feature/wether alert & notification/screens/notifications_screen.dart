import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/wether%20alert%20&%20notification/widgets/notification_widget/notification_item.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/custom_appbar.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          CustomAppBar(title: 'NOTIFICATIONS', onBackPressed: () => Get.back()),

          // Divider line below app bar
          Container(height: 1, color: AppColors.borderColor),

          // Content
          Expanded(
            child: Obx(() {
              // Loading State
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // Error State
              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.5),
                      ),
                      SizedBox(height: DynamicSize.medium(context)),
                      Text(
                        controller.errorMessage.value,
                        style: AppTextStyles.subHeadLine().copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: DynamicSize.medium(context)),
                      ElevatedButton(
                        onPressed: () => controller.fetchNotifications(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Empty State
              if (controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: DynamicSize.medium(context)),
                      Text(
                        'No notifications yet',
                        style: AppTextStyles.subHeadLine().copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Notifications List
              return RefreshIndicator(
                onRefresh: () => controller.refreshNotifications(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount:
                      controller.notifications.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == controller.notifications.length) {
                      controller.loadMore();
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final notification = controller.notifications[index];
                    return NotificationItem(
                      icon: notification.icon,
                      iconColor: notification.iconColor,
                      title: notification.title,
                      date: notification.date,
                      time: notification.time,
                      message: notification.message,
                      // isRead: notification.isRead,
                      onTap: () {
                        if (!notification.isRead) {
                          controller.markAsRead(notification.id);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
