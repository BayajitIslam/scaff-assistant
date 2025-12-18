import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/string_const/api_endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/local_storage/user_info.dart';

class WeightCalculatorController extends GetxController {
  // Dropdown selections
  var selectedTube = Rxn<String>();
  var selectedBoard = Rxn<String>();
  var selectedFitting = Rxn<String>();

  // Default values (same as hints)
  final String defaultTube = '1';
  final String defaultBoard = '3';
  final String defaultFitting = 'Double';

  // Dropdown options
  final List<String> tubeOptions = ['1ft', '8ft', '13ft'];

  final List<String> boardOptions = ['3ft', '10ft'];

  final List<String> fittingOptions = ['Double', 'Single'];

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

  // Build request body
  Map<String, dynamic> buildRequestBody() {
    return {
      "tubes": [
        {
          "length_ft": tubeValue, // ← Changes (1, 8, or 13)
          "wall_thickness": "3.2mm", // ← Permanent
          "quantity": 28, // ← Permanent
        },
      ],
      "boards": [
        {
          "length_ft": boardValue, // ← Changes (3 or 10)
          "quantity": 15, // ← Permanent
        },
      ],
      "fittings": [
        {
          "fitting_type": fittingValue, // ← Changes (Double or Single)
          "quantity": 100, // ← Permanent
        },
      ],
    };
  }

  // Loading state for button
  var isLoading = false.obs;

  //initially Output  false
  var showOutput = false.obs;

  void calculateWeight() async {
    final body = buildRequestBody();
    debugPrint('Request Body: $body');
    // TODO: Call backend API
    try {
      //loading
      showOutput(false);
      isLoading(true);

      //Api Url
      final String url = APIEndPoint.weightCalculator;
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
      debugPrint('StatusCode : ${response.statusCode}');
      debugPrint('StatusCode : ${response.body}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        tubesTotalWeight.value = '${data['total_tubes_weight']}kg';
        boardsTotalWeight.value = '${data['total_boards_weight']}kg';
        fittingsTotalWeight.value = '${data['total_fittings_weight']}kg';
        totalWeight.value = '${data['grand_total_weight']}KG';
        showOutput(true);
      }
    } catch (e) {
      debugPrint('Error Calculation : $e');
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
