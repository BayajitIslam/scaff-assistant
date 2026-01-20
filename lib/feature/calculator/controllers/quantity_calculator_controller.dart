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
  var selectedPlatformWidth1 = Rxn<String>(); // Main deck boards
  var selectedPlatformWidth2 = Rxn<String>(); // Inside boards
  var selectedBoardedLifts = Rxn<String>();

  // Text field controllers
  final heightController = TextEditingController();
  final totalLengthController = TextEditingController();

  // ===== DROPDOWN OPTIONS =====

  final List<String> scaffoldTypeOptions = ['Independent', 'Tower'];

  final List<String> loadClassOptions = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
  ];

  // Platform width options (main deck: 3, 4, 5 boards)
  final List<String> mainDeckBoardOptions = ['3', '4', '5'];

  // Inside board options (0-3 boards)
  final List<String> insideBoardOptions = ['0', '1', '2', '3'];

  final List<String> boardedLiftsOptions = ['Top lift only', 'All lifts'];

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

  // Legacy outputs (for compatibility)
  var tubesOutput = '-'.obs;
  var totalWeight = '-'.obs;

  // Loading and error states
  var isLoading = false.obs;
  var errorMessage = ''.obs;

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
      final mainDeckBoards = int.parse(selectedPlatformWidth1.value ?? '4');
      final insideBoards = int.parse(selectedPlatformWidth2.value ?? '0');
      final allLiftsBoarded = selectedBoardedLifts.value == 'All lifts';

      // ===== 3. UNIT CONVERSION (Meters → Feet, Round UP) =====
      final lengthFt = UnitConverter.metersToFeetRoundedUp(lengthM);
      final targetHeightFt = UnitConverter.calculateTargetHeight(heightM);

      // ===== 4. GENERATE LIFT STACK =====
      final liftStack = LiftStackGenerator.generateLiftStack(
        targetHeightM: UnitConverter.feetToMeters(targetHeightFt.toDouble()),
        allLiftsBoarded: allLiftsBoarded,
      );

      if (!LiftStackGenerator.validateLiftStack(liftStack)) {
        errorMessage.value = 'Invalid lift configuration generated';
        isLoading.value = false;
        return;
      }

      // ===== 5. RUN CALCULATION CARDS =====

      // Height calculation (per SET of standards)
      final heightResult = CalculationService.calculateHeight(targetHeightFt);
      if (heightResult == null) {
        errorMessage.value =
            'Height calculation failed for ${targetHeightFt}ft';
        isLoading.value = false;
        return;
      }

      // Length calculation (per lift)
      final lengthResult = CalculationService.calculateLength(lengthFt);
      if (lengthResult == null) {
        errorMessage.value = 'Length calculation failed for ${lengthFt}ft';
        isLoading.value = false;
        return;
      }

      // Bay calculation (geometry + per-lift components)
      final bayResult = CalculationService.calculateBay(lengthFt, bayClass);
      if (bayResult == null) {
        errorMessage.value =
            'Bay calculation failed for ${lengthFt}ft, Class $bayClass';
        isLoading.value = false;
        return;
      }

      // Width calculation (deck configuration)
      final widthResult = CalculationService.calculateWidth(
        mainDeckBoards,
        insideBoards,
      );
      if (widthResult == null) {
        errorMessage.value =
            'Width calculation failed for $mainDeckBoards main deck, $insideBoards inside';
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
      );

      // ===== 7. FORMAT OUTPUT =====
      _formatOutput(finalQuantities);

      isLoading.value = false;

      // Auto-show results bottom sheet
    } catch (e) {
      errorMessage.value = 'Calculation error: $e';
      isLoading.value = false;
      print('Calculation error: $e');
    }
  }

  // ===== VALIDATION =====

  bool _validateInputs() {
    if (heightController.text.isEmpty) {
      errorMessage.value = 'Please enter height';
      return false;
    }

    if (totalLengthController.text.isEmpty) {
      errorMessage.value = 'Please enter total length';
      return false;
    }

    if (selectedLoadClass.value == null) {
      errorMessage.value = 'Please select load class';
      return false;
    }

    if (selectedPlatformWidth1.value == null) {
      errorMessage.value = 'Please select main deck boards';
      return false;
    }

    if (selectedPlatformWidth2.value == null) {
      errorMessage.value = 'Please select inside boards';
      return false;
    }

    if (selectedBoardedLifts.value == null) {
      errorMessage.value = 'Please select boarded lifts option';
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

    return true;
  }

  int _parseBayClass(String classString) {
    // Extract number from "Class X"
    final match = RegExp(r'\d+').firstMatch(classString);
    return match != null ? int.parse(match.group(0)!) : 1;
  }

  // ===== OUTPUT FORMATTING =====

  void _formatOutput(FinalQuantities quantities) {
    // Standards
    standardsOutput.value = quantities.formatComponents(quantities.standards);

    // Ledgers
    ledgersOutput.value = quantities.formatComponents(quantities.ledgers);

    // Transoms
    transomsOutput.value = quantities.formatComponents(quantities.transoms);

    // Boards
    boardsOutput.value = quantities.formatComponents(quantities.boards);

    // Handrails
    handrailsOutput.value = quantities.formatComponents(quantities.handrails);

    // Bracing
    final bracingParts = <String>[];
    if (quantities.ledgerBraces.isNotEmpty) {
      bracingParts.add(
        'Ledger: ${quantities.formatComponents(quantities.ledgerBraces)}',
      );
    }
    if (quantities.swayBraces.isNotEmpty) {
      bracingParts.add(
        'Sway: ${quantities.formatComponents(quantities.swayBraces)}',
      );
    }
    bracingOutput.value = bracingParts.isEmpty ? '-' : bracingParts.join(', ');

    // Fittings
    final fittingsParts = <String>[];
    if (quantities.doubles > 0) {
      fittingsParts.add('Doubles: ${quantities.doubles}');
    }
    if (quantities.swivels > 0) {
      fittingsParts.add('Swivels: ${quantities.swivels}');
    }
    if (quantities.sleeves > 0) {
      fittingsParts.add('Sleeves: ${quantities.sleeves}');
    }
    if (quantities.singles > 0) {
      fittingsParts.add('Singles: ${quantities.singles}');
    }
    if (quantities.boardClips > 0) {
      fittingsParts.add('Board clips: ${quantities.boardClips}');
    }
    fittingsOutput.value = fittingsParts.isEmpty
        ? '-'
        : fittingsParts.join(', ');

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

    // Legacy tube output (combine all tube components)
    final tubeParts = <String>[];

    // 1. Standards
    if (quantities.standards.isNotEmpty) {
      tubeParts.add(quantities.formatComponents(quantities.standards));
    }

    // 2. Ledgers
    if (quantities.ledgers.isNotEmpty) {
      tubeParts.add(quantities.formatComponents(quantities.ledgers));
    }

    // 3. Transoms
    if (quantities.transoms.isNotEmpty) {
      tubeParts.add(quantities.formatComponents(quantities.transoms));
    }

    // 4. Handrails
    if (quantities.handrails.isNotEmpty) {
      tubeParts.add(quantities.formatComponents(quantities.handrails));
    }

    // 5. Bracing (Ledger + Sway)
    if (quantities.ledgerBraces.isNotEmpty) {
      tubeParts.add(
        'Ledger Braces: ${quantities.formatComponents(quantities.ledgerBraces)}',
      );
    }
    if (quantities.swayBraces.isNotEmpty) {
      tubeParts.add(
        'Sway Braces: ${quantities.formatComponents(quantities.swayBraces)}',
      );
    }

    // 6. Droppers
    if (quantities.droppers.isNotEmpty) {
      tubeParts.add(
        'Droppers: ${quantities.formatComponents(quantities.droppers)}',
      );
    }

    tubesOutput.value = tubeParts.isEmpty ? '-' : tubeParts.join('\n');

    // Total weight (placeholder - would need actual weight calculation)
    totalWeight.value = 'Calculated';
  }

  @override
  void onClose() {
    heightController.dispose();
    totalLengthController.dispose();
    super.onClose();
  }
}
