import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/utils/dynamic_size.dart';
import 'package:scaffassistant/feature/calculator/widgets/weight_calculator_widget/description_card.dart';
import 'package:scaffassistant/feature/wether%20alert%20&%20notification/widgets/weather_alerts_widget/alert_item.dart';
import 'package:scaffassistant/feature/wether%20alert%20&%20notification/widgets/weather_alerts_widget/toggle_card.dart';
import 'package:scaffassistant/feature/digital%20passport/widgets/custom_appbar.dart';
import '../controllers/weather_alerts_controller.dart';

import '../widgets/weather_alerts_widget/alert_types_card.dart';

class WeatherAlertsScreen extends StatelessWidget {
  WeatherAlertsScreen({super.key});

  final controller = Get.put(WeatherAlertsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          CustomAppBar(
            title: 'WEATHER ALERTS',
            onBackPressed: () => Get.back(),
          ),

          // Content
          Expanded(
            child: Obx(() {
              // Loading State
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(DynamicSize.medium(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description Card
                    DescriptionCard(
                      text:
                          'Automatic, location-based safety alerts . Checks every 60 min . On-screen notifications only',
                    ),

                    SizedBox(height: DynamicSize.medium(context)),

                    // Location Card
                    Obx(
                      () => ToggleCard(
                        title: 'LOCATION',
                        subtitle: 'User current location',
                        description: 'For site - specific weather checks',
                        isEnabled: controller.isLocationEnabled.value,
                        onToggleChanged: controller.isUpdating.value
                            ? null
                            : (value) => controller.toggleLocation(value),
                      ),
                    ),

                    SizedBox(height: DynamicSize.medium(context)),

                    // Alert Types Card
                    Obx(
                      () => AlertTypesCard(
                        title: 'ALERT TYPES',
                        children: [
                          Divider(color: Colors.grey.shade300, thickness: 1),

                          // High Heat
                          AlertItem(
                            icon: Icons.wb_sunny_rounded,
                            iconColor: Colors.orange,
                            title: controller.alertData['highHeat']!['title']!,
                            trigger:
                                controller.alertData['highHeat']!['trigger']!,
                            message:
                                controller.alertData['highHeat']!['message']!,
                            isEnabled: controller.isHighHeatEnabled.value,
                            onToggleChanged: controller.isUpdating.value
                                ? null
                                : (value) =>
                                      controller.toggleAlert('highHeat', value),
                          ),

                          Divider(color: Colors.grey.shade300, thickness: 1),

                          // Cold / Ice
                          AlertItem(
                            icon: Icons.ac_unit_rounded,
                            iconColor: Colors.lightBlue,
                            title: controller.alertData['coldIce']!['title']!,
                            trigger:
                                controller.alertData['coldIce']!['trigger']!,
                            message:
                                controller.alertData['coldIce']!['message']!,
                            isEnabled: controller.isColdIceEnabled.value,
                            onToggleChanged: controller.isUpdating.value
                                ? null
                                : (value) =>
                                      controller.toggleAlert('coldIce', value),
                          ),

                          Divider(color: Colors.grey.shade300, thickness: 1),

                          // High Wind
                          AlertItem(
                            icon: Icons.air_rounded,
                            iconColor: Colors.blueGrey,
                            title: controller.alertData['highWind']!['title']!,
                            trigger:
                                controller.alertData['highWind']!['trigger']!,
                            message:
                                controller.alertData['highWind']!['message']!,
                            isEnabled: controller.isHighWindEnabled.value,
                            onToggleChanged: controller.isUpdating.value
                                ? null
                                : (value) =>
                                      controller.toggleAlert('highWind', value),
                          ),

                          Divider(color: Colors.grey.shade300, thickness: 1),

                          // Rain Warning
                          AlertItem(
                            icon: Icons.water_drop_rounded,
                            iconColor: Colors.blue,
                            title:
                                controller.alertData['rainWarning']!['title']!,
                            trigger: controller
                                .alertData['rainWarning']!['trigger']!,
                            message: controller
                                .alertData['rainWarning']!['message']!,
                            isEnabled: controller.isRainWarningEnabled.value,
                            onToggleChanged: controller.isUpdating.value
                                ? null
                                : (value) => controller.toggleAlert(
                                    'rainWarning',
                                    value,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 17),
        ],
      ),
    );
  }
}
