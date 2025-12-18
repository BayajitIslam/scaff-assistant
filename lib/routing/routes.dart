import 'package:get/get.dart';
import 'package:scaffassistant/feature/auth/screens/mail_verification_screen.dart';
import 'package:scaffassistant/feature/auth/screens/update_password.dart';
import 'package:scaffassistant/feature/additional_screen/screens/digital_passport_screen.dart';
import 'package:scaffassistant/feature/additional_screen/screens/notifications_screen.dart';
import 'package:scaffassistant/feature/additional_screen/screens/quantity_calculator_screen.dart';
import 'package:scaffassistant/feature/additional_screen/screens/weather_alerts_screen.dart';
import 'package:scaffassistant/feature/additional_screen/screens/weight_calculator_screen.dart';
import 'package:scaffassistant/feature/settings/screens/settings_screen.dart';
import 'package:scaffassistant/routing/route_name.dart';

import '../feature/auth/screens/login_screen.dart';
import '../feature/auth/screens/otp_verification_screen.dart';
import '../feature/auth/screens/signup_screen.dart';
import '../feature/home/screens/home_screen.dart';
import '../feature/legal/screens/terms_privacy_screen.dart';
import '../feature/subscription/pages/subscription_page.dart';

class Routes {
  static final List<GetPage> pages = [
    GetPage(name: RouteNames.login, page: () => LoginScreen()),
    GetPage(name: RouteNames.signup, page: () => SignupScreen()),
    GetPage(
      name: RouteNames.mailVerification,
      page: () => MailVerificationScreen(),
    ),
    GetPage(
      name: RouteNames.otpVerification,
      page: () => OtpVerificationScreen(),
    ),
    GetPage(name: RouteNames.passwordReset, page: () => UpdatePassword()),

    GetPage(name: RouteNames.home, page: () => HomeScreen()),
    GetPage(name: RouteNames.profile, page: () => SettingsScreen()),
    GetPage(
      name: RouteNames.tramsAndPrivacy,
      page: () => TermsAndPrivacyPolicyScreen(),
    ),
    GetPage(name: RouteNames.tramsAndPrivacy, page: () => TermsAndPrivacyPolicyScreen()),

    GetPage(
      name: RouteNames.subscription,
      page: () => SubscriptionPage(),
    ),

    GetPage(
      name: RouteNames.weightCalculatorScreen,
      page: () => WeightCalculatorScreen(),
    ),
    GetPage(
      name: RouteNames.quantityCalculatorScreen,
      page: () => QuantityCalculatorScreen(),
    ),
    GetPage(
      name: RouteNames.weatherAlertsScreen,
      page: () => WeatherAlertsScreen(),
    ),
    GetPage(
      name: RouteNames.notificationScreen,
      page: () => NotificationsScreen(),
    ),
    GetPage(
      name: RouteNames.digitalPassportScreen,
      page: () => DigitalPassportScreen(),
    ),
  ];
}
