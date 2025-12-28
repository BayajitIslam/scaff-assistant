import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/local_storage/user_info.dart';
import 'package:scaffassistant/core/utils/console.dart';

class WeightCalculatorController extends GetxController {
  // Dropdown selections
  var selectedTube = Rxn<String>();
  var selectedBoard = Rxn<String>();
  var selectedFitting = Rxn<String>();
  var selectedWallThickness = Rxn<String>();

  // Default values (same as hints)
  final String defaultTube = '1';
  final String defaultBoard = '3';
  final String defaultFitting = 'Double';
  final String defaultWallThickness = '3.2mm';

  // Editable quantities
  var tubeQuantity = 0.obs;
  var boardQuantity = 0.obs;
  var fittingQuantity = 0.obs;

  // Dropdown options
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

  final List<String> fittingOptions = [
    'Double',
    'Single',
    // 'Swivels',
    // 'Sleeves',
  ];

  final List<String> wallThicknessOptions = ['3.2mm', '4.0mm'];

  // Output values (will come from backend later)
  var tubesTotalWeight = '0kg'.obs;
  var boardsTotalWeight = '0kg'.obs;
  var fittingsTotalWeight = '0kg'.obs;
  var totalWeight = '0KG'.obs;

  // Getters - returns selected value OR default
  int get tubeValue => int.parse(
    (selectedTube.value ?? defaultTube).replaceAll(RegExp(r'[^0-9]'), ''),
  );
  int get boardValue => int.parse(
    (selectedBoard.value ?? defaultTube).replaceAll(RegExp(r'[^0-9]'), ''),
  );
  String get fittingValue => selectedFitting.value ?? defaultFitting;
  String get wallThiknessValue =>
      selectedWallThickness.value ?? defaultWallThickness;
  int get tubeQuantityValue => tubeQuantity.value;
  int get boardQuantityValue => boardQuantity.value;
  int get fittingQuantityyValue => fittingQuantity.value;

  // Build request body
  Map<String, dynamic> buildRequestBody() {
    return {
      "tubes": [
        {
          "length_ft": tubeValue,
          "wall_thickness": wallThiknessValue,
          "quantity": tubeQuantityValue,
        },
      ],
      "boards": [
        {"length_ft": boardValue, "quantity": boardQuantityValue},
      ],
      "fittings": [
        {"fitting_type": fittingValue, "quantity": fittingQuantityyValue},
      ],
    };
  }

  // Loading state for button
  var isLoading = false.obs;

  var errorMessage = ''.obs;

  //initially Output  false
  var showOutput = false.obs;

  void calculateWeight() async {
    final body = buildRequestBody();
    Console.info('Request Body: $body');
    // TODO: Call backend API
    try {
      //loading
      showOutput(false);
      isLoading(true);

      //Api Url
      final String url = APIEndPoint.weightCalculator;
      Console.api('Post URL: $url');
      //Response Post
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: {
          'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );

      //Check Debug Print
      Console.api('Response status: : ${response.statusCode}');
      Console.success('Response Body : ${response.body}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        tubesTotalWeight.value = '${data['total_tubes_weight']}kg';
        boardsTotalWeight.value = '${data['total_boards_weight']}kg';
        fittingsTotalWeight.value = '${data['total_fittings_weight']}kg';
        totalWeight.value = '${data['grand_total_weight']}KG';
        showOutput(true);
      } else {
        isLoading(false);
        Console.error('Fetch failed: ${response.request}');
        errorMessage.value = 'Something went wrong';
      }
    } catch (e) {
      debugPrint('Error Calculation : $e');
      errorMessage.value = 'Something went wrong';
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
