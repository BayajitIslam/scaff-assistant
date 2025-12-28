import 'package:get/get.dart';
import 'package:scaffassistant/feature/Camera%20Based%20Count%20Tool/controller/count_tool_controller.dart';

class CountToolBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CountToolController(), fenix: true);
  }
}
