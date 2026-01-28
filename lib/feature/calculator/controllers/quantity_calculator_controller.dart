import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/calculation_models.dart';
import '../services/unit_converter.dart';
import '../services/lift_stack_generator.dart';
import '../services/calculation_service.dart';
import '../services/quantity_assembler.dart';

class QuantityCalculatorController extends GetxController {
  // ===== INPUT FIELDS =====

  // Dropdown selections
  var selectedScaffoldType = Rxn<String>();
  var selectedLoadClass = Rxn<String>(); // Bay Class
  var selectedMainDeckBoards = Rxn<String>(); // Main deck boards (3, 4, 5)
  var selectedInsideBoards = Rxn<String>(); // Inside boards (0, 1, 2, 3)
  var selectedBoardOption = Rxn<String>(); // Board Option (Option 1, Option 2)
  var selectedBoardingMode = Rxn<String>(); // Boarding mode selection

  // Text field controllers
  final heightController = TextEditingController();
  final totalLengthController = TextEditingController();

  // Selected boarded lift heights (in meters)
  var selectedBoardedHeights = <double>[].obs;

  // Available lift heights for selection
  var availableLiftHeights = <double>[].obs;

  // ===== DROPDOWN OPTIONS =====

  final List<String> scaffoldTypeOptions = ['Independent', 'Tower'];

  final List<String> loadClassOptions = [
    'Class 1 (2.7m)',
    'Class 2 (2.4m)',
    'Class 3 (2.0m)',
    'Class 4 (1.8m)',
  ];

  // Platform width options (main deck: 3, 4, 5 boards)
  final List<String> mainDeckBoardOptions = ['3', '4', '5'];

  // Inside board options (0-3 boards)
  final List<String> insideBoardOptions = ['0', '1', '2', '3'];

  // Board options from length card
  final List<String> boardOptionsList = ['Option 1', 'Option 2'];

  // Boarding mode options
  final List<String> boardingModeOptions = [
    'Top lift only',
    'All lifts',
    'User selects',
  ];

  // ===== OUTPUT VALUES =====

  var standardsOutput = '-'.obs;
  var ledgersOutput = '-'.obs;
  var transomsOutput = '-'.obs;
  var boardsOutput = '-'.obs;
  var handrailsOutput = '-'.obs;
  var bracingOutput = '-'.obs;
  var fittingsOutput = '-'.obs;
  var baseSupportOutput = '-'.obs;
  var droppersOutput = '-'.obs;

  // Combined tube output
  var tubesOutput = '-'.obs;

  // Lift stack display
  var liftStackOutput = <Lift>[].obs;

  // Conversion info
  var runLengthFt = 0.obs;
  var heightFt = 0.obs;
  var totalLifts = 0.obs;
  var boardedLiftsCount = 0.obs;
  var setsOfLegs = 0.obs;

  // Golden checks
  var isGoldenHeight = false.obs;
  var isGoldenLength = false.obs;
  var isGoldenWidth = false.obs;
  var liftLogicValid = true.obs;

  // Loading and error states
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // ===== INITIALIZATION =====

  @override
  void onInit() {
    super.onInit();

    // Set default values
    selectedScaffoldType.value = 'Independent';
    selectedLoadClass.value = 'Class 2 (2.4m)';
    selectedMainDeckBoards.value = '5';
    selectedInsideBoards.value = '1';
    selectedBoardOption.value = 'Option 2';
    selectedBoardingMode.value = 'User selects';

    // Listen to height changes to update available lifts
    heightController.addListener(_onHeightChanged);
  }

  void _onHeightChanged() {
    final heightText = heightController.text;
    if (heightText.isNotEmpty) {
      final height = double.tryParse(heightText);
      if (height != null && height > 0) {
        _updateAvailableLiftHeights(height);
      }
    }
  }

  void _updateAvailableLiftHeights(double topBoardedLift) {
    availableLiftHeights.value =
        LiftStackGenerator.getAvailableLiftHeights(topBoardedLift);

    // Update selected heights based on boarding mode
    _applyBoardingMode();
  }

  void _applyBoardingMode() {
    final heightText = heightController.text;
    if (heightText.isEmpty) return;

    final height = double.tryParse(heightText);
    if (height == null || height <= 0) return;

    switch (selectedBoardingMode.value) {
      case 'Top lift only':
        selectedBoardedHeights.value =
            LiftStackGenerator.getDefaultBoardedHeights(height);
        break;
      case 'All lifts':
        selectedBoardedHeights.value =
            LiftStackGenerator.getAllBoardedHeights(height);
        break;
      case 'User selects':
        // Keep current selection, but ensure it's valid
        selectedBoardedHeights.value = selectedBoardedHeights
            .where((h) => availableLiftHeights.contains(h))
            .toList();
        // If empty, default to top lift
        if (selectedBoardedHeights.isEmpty && availableLiftHeights.isNotEmpty) {
          selectedBoardedHeights.add(availableLiftHeights.last);
        }
        break;
    }
  }

  void onBoardingModeChanged(String? mode) {
    selectedBoardingMode.value = mode;
    _applyBoardingMode();
  }

  void toggleBoardedHeight(double height) {
    if (selectedBoardingMode.value != 'User selects') return;

    if (selectedBoardedHeights.contains(height)) {
      // Don't allow removing the last boarded lift
      if (selectedBoardedHeights.length > 1) {
        selectedBoardedHeights.remove(height);
      }
    } else {
      selectedBoardedHeights.add(height);
      selectedBoardedHeights.sort();
    }
  }

  // ===== MASTER CALCULATION FLOW =====

  void calculateQuantities() {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // ===== 1. VALIDATE INPUTS =====
      if (!_validateInputs()) {
        isLoading.value = false;
        return;
      }

      // ===== 2. PARSE INPUTS =====
      final heightM = double.parse(heightController.text);
      final lengthM = double.parse(totalLengthController.text);
      final bayClass = _parseBayClass(selectedLoadClass.value!);
      final mainDeckBoards = int.parse(selectedMainDeckBoards.value ?? '5');
      final insideBoards = int.parse(selectedInsideBoards.value ?? '1');
      final boardOption = selectedBoardOption.value == 'Option 2' ? 2 : 1;

      // ===== 3. UNIT CONVERSION (Meters → Feet, Round UP) =====
      final lengthFtValue = UnitConverter.metersToFeetRoundedUp(lengthM);
      final targetHeightFtValue = UnitConverter.calculateTargetHeight(heightM);

      runLengthFt.value = lengthFtValue;
      heightFt.value = targetHeightFtValue;

      // ===== 4. GENERATE LIFT STACK =====
      final liftStack = LiftStackGenerator.generateLiftStack(
        targetHeightM: heightM,
        selectedBoardedHeights: selectedBoardedHeights.toList(),
      );

      if (!LiftStackGenerator.validateLiftStack(liftStack)) {
        errorMessage.value = 'Invalid lift configuration. Please select at least one boarded lift.';
        isLoading.value = false;
        return;
      }

      liftStackOutput.value = liftStack.lifts;
      totalLifts.value = liftStack.totalLifts;
      boardedLiftsCount.value = liftStack.boardedLifts;

      // ===== 5. RUN CALCULATION CARDS =====

      // Height calculation (per SET of standards)
      final heightResult = CalculationService.calculateHeight(targetHeightFtValue);
      if (heightResult == null) {
        errorMessage.value = 'Height calculation failed for ${targetHeightFtValue}ft';
        isLoading.value = false;
        return;
      }

      // Length calculation (per lift)
      final lengthResult = CalculationService.calculateLength(lengthFtValue);
      if (lengthResult == null) {
        errorMessage.value = 'Length calculation failed for ${lengthFtValue}ft';
        isLoading.value = false;
        return;
      }

      // Bay calculation (geometry + per-lift components)
      final bayResult = CalculationService.calculateBay(lengthFtValue, bayClass);
      if (bayResult == null) {
        errorMessage.value = 'Bay calculation failed for ${lengthFtValue}ft, Class $bayClass';
        isLoading.value = false;
        return;
      }

      setsOfLegs.value = bayResult.setsOfLegs;

      // Width calculation (deck configuration)
      final widthResult = CalculationService.calculateWidth(
        mainDeckBoards,
        insideBoards,
      );
      if (widthResult == null) {
        errorMessage.value = 'Width calculation failed for $mainDeckBoards main deck, $insideBoards inside';
        isLoading.value = false;
        return;
      }

      // ===== 6. ASSEMBLE FINAL QUANTITIES =====
      final finalQuantities = QuantityAssembler.assembleFinalQuantities(
        heightResult: heightResult,
        lengthResult: lengthResult,
        bayResult: bayResult,
        widthResult: widthResult,
        liftStack: liftStack,
        bayClass: bayClass,
        mainDeckBoards: mainDeckBoards,
        boardOption: boardOption,
      );

      // Update golden checks
      isGoldenHeight.value = finalQuantities.isGoldenHeight;
      isGoldenLength.value = finalQuantities.isGoldenLength;
      isGoldenWidth.value = finalQuantities.isGoldenWidth;
      liftLogicValid.value = finalQuantities.liftLogicValid;

      // ===== 7. FORMAT OUTPUT =====
      _formatOutput(finalQuantities);

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Calculation error: $e';
      isLoading.value = false;
      print('Calculation error: $e');
    }
  }

  // ===== VALIDATION =====

  bool _validateInputs() {
    if (heightController.text.isEmpty) {
      errorMessage.value = 'Please enter height to top boarded lift';
      return false;
    }

    if (totalLengthController.text.isEmpty) {
      errorMessage.value = 'Please enter run length';
      return false;
    }

    if (selectedLoadClass.value == null) {
      errorMessage.value = 'Please select bay class';
      return false;
    }

    if (selectedMainDeckBoards.value == null) {
      errorMessage.value = 'Please select main deck boards';
      return false;
    }

    if (selectedInsideBoards.value == null) {
      errorMessage.value = 'Please select inside boards';
      return false;
    }

    if (selectedBoardOption.value == null) {
      errorMessage.value = 'Please select board option';
      return false;
    }

    if (selectedBoardedHeights.isEmpty) {
      errorMessage.value = 'Please select at least one boarded lift';
      return false;
    }

    // Validate numeric inputs
    final height = double.tryParse(heightController.text);
    if (height == null || height <= 0) {
      errorMessage.value = 'Invalid height value';
      return false;
    }

    final length = double.tryParse(totalLengthController.text);
    if (length == null || length <= 0) {
      errorMessage.value = 'Invalid length value';
      return false;
    }

    // Height must be at least 2m (minimum for 1 lift)
    if (height < 2) {
      errorMessage.value = 'Height must be at least 2m';
      return false;
    }

    return true;
  }

  int _parseBayClass(String classString) {
    // Extract number from "Class X (Y.Ym)"
    final match = RegExp(r'Class\s*(\d+)').firstMatch(classString);
    return match != null ? int.parse(match.group(1)!) : 2;
  }

  // ===== OUTPUT FORMATTING =====

  void _formatOutput(FinalQuantities quantities) {
    // Standards
    standardsOutput.value = quantities.formatComponents(quantities.standards);

    // Ledgers (combine with aberdeens)
    final ledgerComponents = <String, int>{};
    ledgerComponents.addAll(quantities.ledgers);
    ledgersOutput.value = quantities.formatComponents(ledgerComponents);

    // Transoms
    transomsOutput.value = quantities.formatComponents(quantities.transoms);

    // Boards
    boardsOutput.value = quantities.formatComponents(quantities.boards);

    // Handrails
    handrailsOutput.value = quantities.formatComponents(quantities.handrails);

    // Bracing
    final bracingParts = <String>[];
    if (quantities.ledgerBraces.isNotEmpty) {
      bracingParts.add('Ledger: ${quantities.formatComponents(quantities.ledgerBraces)}');
    }
    if (quantities.swayBraces.isNotEmpty) {
      bracingParts.add('Sway: ${quantities.formatComponents(quantities.swayBraces)}');
    }
    bracingOutput.value = bracingParts.isEmpty ? '-' : bracingParts.join('\n');

    // Fittings
    final fittingsParts = <String>[];
    if (quantities.doubles > 0) {
      fittingsParts.add('Doubles: ${quantities.doubles}');
    }
    if (quantities.swivels > 0) {
      fittingsParts.add('Swivels: ${quantities.swivels}');
    }
    if (quantities.sleeves + quantities.ledgerSleeves + quantities.handrailSleeves > 0) {
      final totalSleeves =
          quantities.sleeves + quantities.ledgerSleeves + quantities.handrailSleeves;
      fittingsParts.add('Sleeves: $totalSleeves');
    }
    if (quantities.singles > 0) {
      fittingsParts.add('Singles: ${quantities.singles}');
    }
    if (quantities.boardClips > 0) {
      fittingsParts.add('Board clips: ${quantities.boardClips}');
    }
    fittingsOutput.value = fittingsParts.isEmpty ? '-' : fittingsParts.join('\n');

    // Base support
    final baseParts = <String>[];
    if (quantities.soleBoards > 0) {
      baseParts.add('Sole boards: ${quantities.soleBoards}');
    }
    if (quantities.baseplates > 0) {
      baseParts.add('Baseplates: ${quantities.baseplates}');
    }
    baseSupportOutput.value = baseParts.isEmpty ? '-' : baseParts.join(', ');

    // Droppers
    droppersOutput.value = quantities.formatComponents(quantities.droppers);

    // Combined tubes output
    final tubeParts = <String>[];

    // Standards
    if (quantities.standards.isNotEmpty) {
      tubeParts.add('Standards: ${quantities.formatComponents(quantities.standards)}');
    }

    // Ledgers
    if (quantities.ledgers.isNotEmpty) {
      tubeParts.add('Ledgers: ${quantities.formatComponents(quantities.ledgers)}');
    }

    // Transoms
    if (quantities.transoms.isNotEmpty) {
      tubeParts.add('Transoms: ${quantities.formatComponents(quantities.transoms)}');
    }

    // Aberdeens
    if (quantities.aberdeens.isNotEmpty) {
      tubeParts.add('Aberdeens: ${quantities.formatComponents(quantities.aberdeens)}');
    }

    // Handrails
    if (quantities.handrails.isNotEmpty) {
      tubeParts.add('Handrails: ${quantities.formatComponents(quantities.handrails)}');
    }

    // Bracing
    if (quantities.ledgerBraces.isNotEmpty) {
      tubeParts.add('Ledger Braces: ${quantities.formatComponents(quantities.ledgerBraces)}');
    }
    if (quantities.swayBraces.isNotEmpty) {
      tubeParts.add('Sway Braces: ${quantities.formatComponents(quantities.swayBraces)}');
    }

    // Droppers
    if (quantities.droppers.isNotEmpty) {
      tubeParts.add('Droppers: ${quantities.formatComponents(quantities.droppers)}');
    }

    tubesOutput.value = tubeParts.isEmpty ? '-' : tubeParts.join('\n');
  }

  // ===== RESET =====

  void resetCalculator() {
    heightController.clear();
    totalLengthController.clear();
    selectedBoardedHeights.clear();
    availableLiftHeights.clear();
    liftStackOutput.clear();

    standardsOutput.value = '-';
    ledgersOutput.value = '-';
    transomsOutput.value = '-';
    boardsOutput.value = '-';
    handrailsOutput.value = '-';
    bracingOutput.value = '-';
    fittingsOutput.value = '-';
    baseSupportOutput.value = '-';
    droppersOutput.value = '-';
    tubesOutput.value = '-';

    runLengthFt.value = 0;
    heightFt.value = 0;
    totalLifts.value = 0;
    boardedLiftsCount.value = 0;
    setsOfLegs.value = 0;

    isGoldenHeight.value = false;
    isGoldenLength.value = false;
    isGoldenWidth.value = false;
    liftLogicValid.value = true;

    errorMessage.value = '';
  }

  @override
  void onClose() {
    heightController.removeListener(_onHeightChanged);
    heightController.dispose();
    totalLengthController.dispose();
    super.onClose();
  }
}