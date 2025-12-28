import 'package:get/get.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/bindings/count_tool_binding.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/screens/count_tool_camara.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/screens/count_tool_image_preview.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/screens/count_tool_result_screen.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/screens/count_tool_screen.dart';
import 'package:scaffassistant/feature/Measure/Level/Screens/level_screen.dart';
import 'package:scaffassistant/feature/Measure/Measure/Screens/measure_screen.dart';
import 'package:scaffassistant/feature/Measure/measure_main_Screen.dart';
import 'package:scaffassistant/feature/calculator/screens/quantity_calculator_screen.dart';
import 'package:scaffassistant/feature/calculator/screens/weight_calculator_screen.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/bindings/quiz_binding.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/screens/quiz_result_screen.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/screens/quiz_screen.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/screens/quiz_selection_screen.dart';
import 'package:scaffassistant/feature/wether%20alert%20&%20notification/screens/notifications_screen.dart';
import 'package:scaffassistant/feature/wether%20alert%20&%20notification/screens/weather_alerts_screen.dart';
import 'package:scaffassistant/feature/auth/screens/mail_verification_screen.dart';
import 'package:scaffassistant/feature/auth/screens/update_password.dart';
import 'package:scaffassistant/feature/digital%20passport/screens/digital_passport_screen.dart';
import 'package:scaffassistant/feature/settings/screens/settings_screen.dart';
import 'package:scaffassistant/routing/route_name.dart';
import '../feature/auth/screens/login_screen.dart';
import '../feature/auth/screens/otp_verification_screen.dart';
import '../feature/auth/screens/signup_screen.dart';
import '../feature/home/screens/home_screen.dart';
import '../feature/legal/screens/terms_privacy_screen.dart';
import '../feature/subscription/pages/subscription_screen.dart';

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
    GetPage(
      name: RouteNames.tramsAndPrivacy,
      page: () => TermsAndPrivacyPolicyScreen(),
    ),

    GetPage(name: RouteNames.subscription, page: () => SubscriptionScreen()),

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
    GetPage(
      name: RouteNames.measureMainScreen,
      page: () => MeasureMainScreen(),
    ),
    GetPage(name: RouteNames.measureScreen, page: () => MeasureView()),
    GetPage(name: RouteNames.levelScreen, page: () => LevelView()),
    GetPage(
      name: RouteNames.scaffoldRevisionTest,
      page: () => QuizSelectionScreen(),
      binding: QuizeBinding(),
    ),
    GetPage(
      name: RouteNames.quizScreen,
      page: () => QuizScreen(),
      binding: QuizeBinding(),
    ),

    GetPage(
      name: RouteNames.quizResult,
      page: () => QuizResultScreen(),
      transition: Transition.noTransition,
      binding: QuizeBinding(),
    ),

    GetPage(
      name: RouteNames.countToolScreen,
      page: () => CountToolScreen(),
      binding: CountToolBinding(),
    ),
    GetPage(
      name: RouteNames.countToolCamera,
      page: () => CountToolCamara(),
      transition: Transition.noTransition,
      binding: CountToolBinding(),
    ),
    GetPage(
      name: RouteNames.countToolImagePreview,
      page: () => CountToolImagePreview(),
      transition: Transition.noTransition,
      binding: CountToolBinding(),
    ),
    GetPage(
      name: RouteNames.countToolResult,
      page: () => CountToolResultScreen(),
      transition: Transition.noTransition,
      binding: CountToolBinding(),
    ),
  ];
}
