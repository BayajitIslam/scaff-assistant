import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/local_storage/user_info.dart';
import 'package:scaffassistant/core/utils/console.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// TUBE INPUT MODEL
/// ═══════════════════════════════════════════════════════════════════════════
class TubeInput {
  final int id;
  Rxn<String> selectedTube = Rxn<String>();
  Rxn<String> selectedWallThickness = Rxn<String>();
  RxInt quantity = 0.obs;

  TubeInput({required this.id});

  Map<String, dynamic> toJson(String defaultTube, String defaultWallThickness) {
    final tubeValue = int.parse(
      (selectedTube.value ?? defaultTube).replaceAll(RegExp(r'[^0-9]'), ''),
    );
    return {
      "length_ft": tubeValue,
      "wall_thickness": selectedWallThickness.value ?? defaultWallThickness,
      "quantity": quantity.value,
    };
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// BOARD INPUT MODEL
/// ═══════════════════════════════════════════════════════════════════════════
class BoardInput {
  final int id;
  Rxn<String> selectedBoard = Rxn<String>();
  RxInt quantity = 0.obs;

  BoardInput({required this.id});

  Map<String, dynamic> toJson(String defaultBoard) {
    final boardValue = int.parse(
      (selectedBoard.value ?? defaultBoard).replaceAll(RegExp(r'[^0-9]'), ''),
    );
    return {"length_ft": boardValue, "quantity": quantity.value};
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// FITTING INPUT MODEL
/// ═══════════════════════════════════════════════════════════════════════════
class FittingInput {
  final int id;
  Rxn<String> selectedFitting = Rxn<String>();
  RxInt quantity = 0.obs;

  FittingInput({required this.id});

  Map<String, dynamic> toJson(String defaultFitting) {
    return {
      "fitting_type": selectedFitting.value ?? defaultFitting,
      "quantity": quantity.value,
    };
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// WEIGHT CALCULATOR CONTROLLER
/// ═══════════════════════════════════════════════════════════════════════════
class WeightCalculatorController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Multiple Input Lists
  // ─────────────────────────────────────────────────────────────────────────

  final RxList<TubeInput> tubeInputs = <TubeInput>[].obs;
  final RxList<BoardInput> boardInputs = <BoardInput>[].obs;
  final RxList<FittingInput> fittingInputs = <FittingInput>[].obs;

  // ID counters for unique keys
  int _tubeIdCounter = 0;
  int _boardIdCounter = 0;
  int _fittingIdCounter = 0;

  // ─────────────────────────────────────────────────────────────────────────
  // Default values (same as hints)
  // ─────────────────────────────────────────────────────────────────────────

  final String defaultTube = '1';
  final String defaultBoard = '3';
  final String defaultFitting = 'Double';
  final String defaultWallThickness = '3.2mm';

  // ─────────────────────────────────────────────────────────────────────────
  // Dropdown options
  // ─────────────────────────────────────────────────────────────────────────

  final List<String> tubeOptions = [
    '1ft',
    '2ft',
    '3ft',
    '4ft',
    '5ft',
    '6ft',
    '7ft',
    '8ft',
    '10ft',
    '13ft',
    '16ft',
    '21ft',
  ];

  final List<String> boardOptions = [
    '3ft',
    '4ft',
    '5ft',
    '6ft',
    '7ft',
    '8ft',
    '10ft',
    '13ft',
  ];

  final List<String> fittingOptions = ['Double', 'Single', 'Swivel', 'Sleeve'];

  final List<String> wallThicknessOptions = ['3.2mm', '4.0mm'];

  // ─────────────────────────────────────────────────────────────────────────
  // Output values
  // ─────────────────────────────────────────────────────────────────────────

  var tubesTotalWeight = '0kg'.obs;
  var boardsTotalWeight = '0kg'.obs;
  var fittingsTotalWeight = '0kg'.obs;
  var totalWeight = '0KG'.obs;

  // Loading state
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var showOutput = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Add initial rows
    addTubeInput();
    addBoardInput();
    addFittingInput();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Add Input Methods
  // ─────────────────────────────────────────────────────────────────────────

  void addTubeInput() {
    tubeInputs.add(TubeInput(id: _tubeIdCounter++));
  }

  void addBoardInput() {
    boardInputs.add(BoardInput(id: _boardIdCounter++));
  }

  void addFittingInput() {
    fittingInputs.add(FittingInput(id: _fittingIdCounter++));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Remove Input Methods
  // ─────────────────────────────────────────────────────────────────────────

  void removeTubeInput(int id) {
    if (tubeInputs.length > 1) {
      tubeInputs.removeWhere((input) => input.id == id);
    }
  }

  void removeBoardInput(int id) {
    if (boardInputs.length > 1) {
      boardInputs.removeWhere((input) => input.id == id);
    }
  }

  void removeFittingInput(int id) {
    if (fittingInputs.length > 1) {
      fittingInputs.removeWhere((input) => input.id == id);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build request body
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> buildRequestBody() {
    return {
      "tubes": tubeInputs
          .map((input) => input.toJson(defaultTube, defaultWallThickness))
          .toList(),
      "boards": boardInputs.map((input) => input.toJson(defaultBoard)).toList(),
      "fittings": fittingInputs
          .map((input) => input.toJson(defaultFitting))
          .toList(),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Calculate Weight
  // ─────────────────────────────────────────────────────────────────────────

  void calculateWeight() async {
    final body = buildRequestBody();
    Console.info('Request Body: $body');

    try {
      showOutput(false);
      isLoading(true);
      errorMessage.value = '';

      final String url = APIEndPoint.weightCalculator;
      Console.api('Post URL: $url');

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );

      Console.api('Response status: ${response.statusCode}');
      Console.success('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parse and format to 2 decimal places
        double tubesWeight = _parseDouble(data['total_tubes_weight']);
        double boardsWeight = _parseDouble(data['total_boards_weight']);
        double fittingsWeight = _parseDouble(data['total_fittings_weight']);
        double grandTotal = _parseDouble(data['grand_total_weight']);

        tubesTotalWeight.value = '${tubesWeight.toStringAsFixed(2)}kg';
        boardsTotalWeight.value = '${boardsWeight.toStringAsFixed(2)}kg';
        fittingsTotalWeight.value = '${fittingsWeight.toStringAsFixed(2)}kg';
        totalWeight.value = '${grandTotal.toStringAsFixed(2)}KG';
        showOutput(true);
      } else {
        Console.error('Fetch failed: ${response.request}');
        errorMessage.value = 'Something went wrong';
      }
    } catch (e) {
      debugPrint('Error Calculation: $e');
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear All
  // ─────────────────────────────────────────────────────────────────────────

  void clearAll() {
    tubeInputs.clear();
    boardInputs.clear();
    fittingInputs.clear();

    _tubeIdCounter = 0;
    _boardIdCounter = 0;
    _fittingIdCounter = 0;

    addTubeInput();
    addBoardInput();
    addFittingInput();

    showOutput(false);
    errorMessage.value = '';
  }

  // Helper method to safely parse double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
