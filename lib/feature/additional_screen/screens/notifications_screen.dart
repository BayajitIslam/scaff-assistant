import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/size_const/dynamic_size.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import 'package:scaffassistant/core/theme/text_theme.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/custom_appbar.dart';
import 'package:scaffassistant/feature/additional_screen/widgets/notification_widget/notification_item.dart';
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
          Container(height: 1, color: SColor.borderColor),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: SColor.primary),
                );
              }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: SColor.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: DynamicSize.medium(context)),
                      Text(
                        'No notifications yet',
                        style: STextTheme.subHeadLine().copyWith(
                          color: SColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  return NotificationItem(
                    icon: Icons.circle,
                    iconColor: notification.iconColor,
                    title: notification.title,
                    date: notification.date,
                    time: notification.time,
                    message: notification.message,
                    onTap: () {
                      // TODO: Handle notification tap
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
