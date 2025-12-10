import 'package:get/get.dart';

class WeatherAlertsController extends GetxController {
  // Location toggle
  var isLocationEnabled = true.obs;

  // Alert type toggles
  var isHighHeatEnabled = true.obs;
  var isColdIceEnabled = true.obs;
  var isHighWindEnabled = true.obs;
  var isRainWarningEnabled = true.obs;

  // Alert data (will come from backend later)
  final Map<String, Map<String, String>> alertData = {
    'highHeat': {
      'title': 'High heat',
      'trigger': 'Trigger : above 28°C',
      'message':
          "Message: 'It's getting hot today. Stay hydrated, avoid direct sun, take breaks, and stop work if needed.'",
    },
    'coldIce': {
      'title': 'Cold / Ice',
      'trigger': 'Trigger: 0°C or below',
      'message':
          "Message: 'Ice warning. Roads and scaffold surfaces may be slippery. Take extra care when driving or working at height.'",
    },
    'highWind': {
      'title': 'High wind',
      'trigger': 'Trigger: 25-30 mph caution, 30+ mph danger',
      'message':
          "Message: 'Strong winds today. Be cautious at height and consider postponing unsafe activities.'",
    },
    'rainWarning': {
      'title': 'Rain warning',
      'trigger': 'Trigger: Rain forecast within 1 hour',
      'message':
          "Message: 'Rain incoming. Surfaces may be slippery — be cautious on the scaffold.'",
    },
  };
}
