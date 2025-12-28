import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/routing/route_name.dart';

class CountToolController extends GetxController {
  //Variables
  RxList componentTypes = ["Tubes", "Boards", "Fittings"].obs;
  RxInt selectedComponentIndex = 0.obs;

  //Open Camera Function
  void openCamara() {
    Console.nav("Navigating to Camera Screen");
    Get.toNamed(
      RouteNames.countToolCamera,
      arguments: componentTypes[selectedComponentIndex.value],
    );
  }
}
