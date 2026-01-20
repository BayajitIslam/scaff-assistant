import '../models/calculation_models.dart';

/// Bay calculation data (11ft - 330ft, 4 classes)
/// Defines bay geometry and per-lift structural components
class BayCalculationData {
  // Key format: "length_class" (e.g., "20_1" for 20ft Class 1)
  static final Map<String, BayCalculationResult> _bayData = {
    // Sample data for different bay classes

    // 20ft - Class 1
    '20_1': BayCalculationResult(
      lengthFt: 20,
      bayClass: 1,
      setsOfLegs: 3, // One-time: 3 sets along 20ft
      numberOfBays: 2,
      bayDimensions: [10, 10],
      endBaySplitDescription: 'Equal bays: 10ft + 10ft',
      ledgerDoubles: 8,
      handrailDoubles: 4,
      aberdeenDoubles: 6,
      ledgerBraces: 4,
      swayBraces: 2,
      swivelsForLedgerBraces: 8,
      swivelsForSwayBraces: 4,
      isGolden: true,
    ),

    // 20ft - Class 2
    '20_2': BayCalculationResult(
      lengthFt: 20,
      bayClass: 2,
      setsOfLegs: 3,
      numberOfBays: 2,
      bayDimensions: [10, 10],
      endBaySplitDescription: 'Equal bays: 10ft + 10ft',
      ledgerDoubles: 10,
      handrailDoubles: 5,
      aberdeenDoubles: 8,
      ledgerBraces: 6,
      swayBraces: 3,
      swivelsForLedgerBraces: 12,
      swivelsForSwayBraces: 6,
      isGolden: true,
    ),

    // 30ft - Class 1
    '30_1': BayCalculationResult(
      lengthFt: 30,
      bayClass: 1,
      setsOfLegs: 4,
      numberOfBays: 3,
      bayDimensions: [10, 10, 10],
      endBaySplitDescription: 'Equal bays: 10ft + 10ft + 10ft',
      ledgerDoubles: 12,
      handrailDoubles: 6,
      aberdeenDoubles: 9,
      ledgerBraces: 6,
      swayBraces: 3,
      swivelsForLedgerBraces: 12,
      swivelsForSwayBraces: 6,
      isGolden: true,
    ),

    // 30ft - Class 3
    '30_3': BayCalculationResult(
      lengthFt: 30,
      bayClass: 3,
      setsOfLegs: 5, // More legs for higher class
      numberOfBays: 4,
      bayDimensions: [8, 7, 7, 8],
      endBaySplitDescription: 'Adjusted end bays: 8ft + 7ft + 7ft + 8ft',
      ledgerDoubles: 16,
      handrailDoubles: 8,
      aberdeenDoubles: 12,
      ledgerBraces: 10,
      swayBraces: 5,
      swivelsForLedgerBraces: 20,
      swivelsForSwayBraces: 10,
      isGolden: false,
    ),

    // 50ft - Class 1
    '50_1': BayCalculationResult(
      lengthFt: 50,
      bayClass: 1,
      setsOfLegs: 6,
      numberOfBays: 5,
      bayDimensions: [10, 10, 10, 10, 10],
      endBaySplitDescription: 'Equal bays: 5 × 10ft',
      ledgerDoubles: 20,
      handrailDoubles: 10,
      aberdeenDoubles: 15,
      ledgerBraces: 10,
      swayBraces: 5,
      swivelsForLedgerBraces: 20,
      swivelsForSwayBraces: 10,
      isGolden: true,
    ),

    // Add more bay configurations as needed
    // TODO: Populate full range (11-330ft) × 4 classes
  };

  /// Get bay calculation for a specific length and class
  static BayCalculationResult? getBayCalculation(int lengthFt, int bayClass) {
    final key = '${lengthFt}_$bayClass';
    return _bayData[key];
  }

  /// Get the nearest available bay configuration (rounds up length)
  static BayCalculationResult? getNearestBay(int lengthFt, int bayClass) {
    // Try exact match first
    final exact = getBayCalculation(lengthFt, bayClass);
    if (exact != null) return exact;

    // Find next higher length for this class
    final availableLengths =
        _bayData.keys
            .where((key) => key.endsWith('_$bayClass'))
            .map((key) => int.parse(key.split('_')[0]))
            .toList()
          ..sort();

    for (final length in availableLengths) {
      if (length >= lengthFt) {
        return getBayCalculation(length, bayClass);
      }
    }

    // Return highest available for this class
    if (availableLengths.isNotEmpty) {
      return getBayCalculation(availableLengths.last, bayClass);
    }

    return null;
  }

  /// Get all golden combinations for a specific class
  static List<BayCalculationResult> getGoldenCombinations(int bayClass) {
    return _bayData.values
        .where((result) => result.bayClass == bayClass && result.isGolden)
        .toList();
  }

  /// Check if a length/class combination is golden
  static bool isGoldenBay(int lengthFt, int bayClass) {
    final result = getBayCalculation(lengthFt, bayClass);
    return result?.isGolden ?? false;
  }
}
