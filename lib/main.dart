import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/config/app_initializer.dart';
import 'package:scaffassistant/core/theme/app_theme.dart';
import 'package:scaffassistant/core/services/local_storage/storage_service.dart';
import 'package:scaffassistant/core/widgets/network_wrapper.dart';
import 'package:scaffassistant/feature/subscription/controller/subscription_controller.dart'
    show SubscriptionController;
import 'package:scaffassistant/routing/route_name.dart';
import 'package:scaffassistant/routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all app dependencies
  await AppInitializer.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Check initial route
  final initialRoute = await _getInitialRoute();

  runApp(ScaffAssistantApp(initialRoute: initialRoute));
}

/// Determine initial route based on login and subscription status
Future<String> _getInitialRoute() async {
  final hasToken = StorageService.getAccessToken().isNotEmpty;

  // Not logged in → Login
  if (!hasToken) {
    return RouteNames.login;
  }

  // Logged in → Check subscription from Play Store
  final hasSubscription =
      await SubscriptionController.checkSubscriptionOnStart();

  if (hasSubscription) {
    return RouteNames.scaffoldRevisionTest;
  } else {
    return RouteNames.subscription;
  }
}

class ScaffAssistantApp extends StatelessWidget {
  final String initialRoute;

  const ScaffAssistantApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scaff Assistant',
      debugShowCheckedModeBanner: false,

      // Theme - Light only
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,

      // Routes
      initialRoute: initialRoute,
      getPages: Routes.pages,

      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Network wrapper for no internet screen
      builder: (context, child) {
        return NetworkWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
