import 'package:flutter/material.dart';
import 'package:scaffassistant/core/constants/app_colors.dart';
import 'package:scaffassistant/core/constants/app_text_styles.dart';
import 'package:scaffassistant/core/constants/icon_paths.dart';
import 'package:scaffassistant/core/constants/image_paths.dart';
import 'package:scaffassistant/core/services/local_storage/user_status.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/auth/controllers/logout_controller.dart';
import 'package:scaffassistant/feature/home/models/chat_session_model.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/routing/route_name.dart';
import '../controllers/chat_controller.dart';
import 'login_note.dart';

class SDrawer extends StatelessWidget {
  final List<ChatSessionModel> chatHistory;
  SDrawer({required this.chatHistory, super.key});

  final RxBool isHistoryExpanded = true.obs;

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = UserStatus.getIsLoggedIn();

    return Drawer(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DynamicSize.medium(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Menu icon + Logo
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).closeDrawer(),
                    child: Image.asset(
                      IconPath.menuIcon,
                      height: 24,
                      width: 24,
                    ),
                  ),
                  SizedBox(width: DynamicSize.horizontalMedium(context)),
                  Image.asset(ImagePath.logoIcon, height: 28),
                ],
              ),

              SizedBox(height: DynamicSize.large(context)),

              // New Chat Button
              _buildNewChatButton(context, isLoggedIn),

              SizedBox(height: DynamicSize.medium(context)),

              // Menu Items
              Expanded(
                child: isLoggedIn
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weather Alerts
                            _buildMenuItem(
                              context: context,
                              title: 'Weather Alerts',
                              onTap: () {
                                Scaffold.of(context).closeDrawer();
                                Get.toNamed(RouteNames.weatherAlertsScreen);
                              },
                            ),

                            // Weight Calculator
                            _buildMenuItem(
                              context: context,
                              title: 'Weight Calculator',
                              onTap: () {
                                Scaffold.of(context).closeDrawer();
                                Get.toNamed(RouteNames.weightCalculatorScreen);
                              },
                            ),

                            // Scaffold Calculator
                            _buildMenuItem(
                              context: context,
                              title: 'Scaffold Calculator',
                              onTap: () {
                                Scaffold.of(context).closeDrawer();
                                Get.toNamed(
                                  RouteNames.quantityCalculatorScreen,
                                );
                              },
                            ),

                            // Digital Scaffold Passport
                            _buildMenuItem(
                              context: context,
                              title: 'Digital Scaffold Passport',
                              onTap: () {
                                Scaffold.of(context).closeDrawer();
                                Get.toNamed(RouteNames.digitalPassportScreen);
                              },
                            ),

                            // Notifications
                            _buildMenuItem(
                              context: context,
                              title: 'Notifications',
                              onTap: () {
                                Scaffold.of(context).closeDrawer();
                                Get.toNamed(RouteNames.notificationScreen);
                              },
                            ),

                            // History Section (Expandable)
                            _buildHistorySection(context),
                          ],
                        ),
                      )
                    : const LoginNote(),
              ),

              // Sign Out Button
              if (isLoggedIn) ...[_buildSignOutButton(context)],
            ],
          ),
        ),
      ),
    );
  }

  // New Chat Button
  Widget _buildNewChatButton(BuildContext context, bool isLoggedIn) {
    return ElevatedButton(
      onPressed: isLoggedIn
          ? () {
              final chatController = Get.put(ChatController());
              chatController.clearChat();
              Scaffold.of(context).closeDrawer();
            }
          : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            'NEW CHAT',
            style: AppTextStyles.headLine().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Menu Item
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: DynamicSize.medium(context),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.subHeadLine().copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: AppColors.textSecondary.withOpacity(0.3),
          thickness: 1,
          height: 1,
        ),
      ],
    );
  }

  // History Section (Expandable)
  Widget _buildHistorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // History Header with expand/collapse
        InkWell(
          onTap: () {
            isHistoryExpanded.value = !isHistoryExpanded.value;
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: DynamicSize.medium(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: AppTextStyles.subHeadLine().copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Obx(
                  () => Icon(
                    isHistoryExpanded.value
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),

        // History Items (Expandable)
        Obx(() {
          if (!isHistoryExpanded.value) {
            return SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: DynamicSize.small(context)),
              ...chatHistory.map((chat) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: DynamicSize.small(context) * 1.5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final chatController = Get.put(ChatController());
                      chatController.sessionId.value = chat.id;
                      chatController.fetchChatMessages(chat.id);
                      Scaffold.of(context).closeDrawer();
                      print('Selected chat session ID: ${chat.id}');
                    },
                    child: Text(
                      chat.title,
                      style: AppTextStyles.subHeadLine().copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }),
      ],
    );
  }

  // Sign Out Button
  Widget _buildSignOutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        LogoutController logoutController = Get.put(LogoutController());
        logoutController.logout();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'SIGN OUT',
        style: AppTextStyles.headLine().copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
