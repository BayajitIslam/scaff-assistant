import '../models/calculation_models.dart';

/// Height calculation data (1ft - 165ft)
/// Each entry represents one SET of standards (2 legs)
class HeightCalculationData {
  static final Map<int, HeightCalculationResult> _heightData = {
    // Sample data - populate with full range 1-165ft

    // 8ft - Golden combination example
    8: HeightCalculationResult(
      heightFt: 8,
      primaryStandards: [ComponentQuantity(size: 8, quantity: 1)],
      staggeredStandards: [ComponentQuantity(size: 8, quantity: 1)],
      sleeves: 0, // No joins at 8ft
      soleBoards: 2,
      baseplates: 2,
      isGolden: true,
    ),

    // 13ft - Example with sleeves
    13: HeightCalculationResult(
      heightFt: 13,
      primaryStandards: [ComponentQuantity(size: 13, quantity: 1)],
      staggeredStandards: [
        ComponentQuantity(size: 8, quantity: 1),
        ComponentQuantity(size: 5, quantity: 1),
      ],
      sleeves: 1, // One join in staggered
      soleBoards: 2,
      baseplates: 2,
      isGolden: false,
    ),

    // 21ft - Golden combination example
    21: HeightCalculationResult(
      heightFt: 21,
      primaryStandards: [ComponentQuantity(size: 21, quantity: 1)],
      staggeredStandards: [
        ComponentQuantity(size: 13, quantity: 1),
        ComponentQuantity(size: 8, quantity: 1),
      ],
      sleeves: 1,
      soleBoards: 2,
      baseplates: 2,
      isGolden: true,
    ),

    // 26ft - Example with multiple components
    26: HeightCalculationResult(
      heightFt: 26,
      primaryStandards: [ComponentQuantity(size: 13, quantity: 2)],
      staggeredStandards: [
        ComponentQuantity(size: 21, quantity: 1),
        ComponentQuantity(size: 5, quantity: 1),
      ],
      sleeves: 2, // One in primary, one in staggered
      soleBoards: 2,
      baseplates: 2,
      isGolden: false,
    ),

    // 50ft - Golden combination example
    50: HeightCalculationResult(
      heightFt: 50,
      primaryStandards: [
        ComponentQuantity(size: 21, quantity: 2),
        ComponentQuantity(size: 8, quantity: 1),
      ],
      staggeredStandards: [
        ComponentQuantity(size: 21, quantity: 1),
        ComponentQuantity(size: 13, quantity: 1),
        ComponentQuantity(size: 13, quantity: 1),
        ComponentQuantity(size: 3, quantity: 1),
      ],
      sleeves: 4, // Multiple joins
      soleBoards: 2,
      baseplates: 2,
      isGolden: true,
    ),

    // Add more heights as needed (1-165ft)
    // TODO: Populate full height range with actual calculation data
  };

  /// Get height calculation for a specific height in feet
  /// Returns null if height not found
  static HeightCalculationResult? getHeightCalculation(int heightFt) {
    return _heightData[heightFt];
  }

  /// Get the nearest available height (rounds up)
  static HeightCalculationResult? getNearestHeight(int heightFt) {
    // If exact match exists, return it
    if (_heightData.containsKey(heightFt)) {
      return _heightData[heightFt];
    }

    // Find next higher height
    final availableHeights = _heightData.keys.toList()..sort();
    for (final height in availableHeights) {
      if (height >= heightFt) {
        return _heightData[height];
      }
    }

    // If no higher height found, return the highest available
    if (availableHeights.isNotEmpty) {
      return _heightData[availableHeights.last];
    }

    return null;
  }

  /// Get all golden combinations
  static List<HeightCalculationResult> getGoldenCombinations() {
    return _heightData.values.where((result) => result.isGolden).toList();
  }

  /// Check if a height is a golden combination
  static bool isGoldenHeight(int heightFt) {
    final result = _heightData[heightFt];
    return result?.isGolden ?? false;
  }
}
