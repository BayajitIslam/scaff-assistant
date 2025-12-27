import 'package:get/get.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/controller/quiz_controller.dart';

class QuizeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QuizController(), fenix: true);
  }
}
