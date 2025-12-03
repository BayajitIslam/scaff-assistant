import 'package:get/get.dart';

class WeightCalculatorController extends GetxController {
  // Dropdown selections
  var selectedTube = Rxn<String>();
  var selectedBoard = Rxn<String>();
  var selectedFitting = Rxn<String>();

  // Dropdown options
  final List<String> tubeOptions = [
    '1ft tube',
    '2ft tube',
    '3ft tube',
    '4ft tube',
    '5ft tube',
    '6ft tube',
  ];

  final List<String> boardOptions = [
    '1ft tube',
    '2ft tube',
    '3ft tube',
    '4ft tube',
  ];

  final List<String> fittingOptions = [
    'Doubles',
    'Singles',
    'Swivels',
    'Sleeves',
  ];

  // Output values (will come from backend later)
  var tubesTotalWeight = '50kg'.obs;
  var boardsTotalWeight = '50kg'.obs;
  var fittingsTotalWeight = '50kg'.obs;
  var totalWeight = '150KG'.obs;

  // Loading state for button
  var isLoading = false.obs;

  void calculateWeight() {
    // TODO: Call backend API
  }
}
