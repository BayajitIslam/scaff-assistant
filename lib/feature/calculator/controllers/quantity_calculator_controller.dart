import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuantityCalculatorController extends GetxController {
  // Dropdown selections
  var selectedScaffoldType = Rxn<String>();
  var selectedLoadClass = Rxn<String>();
  var selectedPlatformWidth1 = Rxn<String>();
  var selectedPlatformWidth2 = Rxn<String>();
  var selectedBoardedLifts = Rxn<String>();

  // Text field controllers
  final heightController = TextEditingController();
  final totalLengthController = TextEditingController();

  // Toggle state (false = 3.2mm, true = 4.0mm)
  var isTubeType4mm = false.obs;

  // Dropdown options
  final List<String> scaffoldTypeOptions = ['Independent', 'Birdcage', 'Tower'];

  final List<String> loadClassOptions = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
  ];

  final List<String> platformWidthOptions = [
    'Main deck',
    'Inside boards',
    'Outside boards',
  ];

  final List<String> boardedLiftsOptions = [
    'Top lift only',
    'All lifts',
    'Alternate lifts',
  ];

  // Output values (will come from backend later)
  var tubesOutput = '21ft × 24, 16ft × 8, 10ft × 6'.obs;
  var boardsOutput = '13ft × 60, 10ft × 12'.obs;
  var fittingsOutput = 'Doubles 120'.obs;
  var baseSupportOutput = 'Sole boards 24'.obs;
  var totalWeight = '1,240KG'.obs;

  // Loading state
  var isLoading = false.obs;

  void calculateQuantities() {
    // TODO: Call backend API
  }

  @override
  void onClose() {
    heightController.dispose();
    totalLengthController.dispose();
    super.onClose();
  }
}
