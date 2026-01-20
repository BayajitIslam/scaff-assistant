import '../models/calculation_models.dart';

/// Length calculation data (11ft - 330ft)
/// Defines horizontal components per lift
class LengthCalculationData {
  static final Map<int, LengthCalculationResult> _lengthData = {
    // Sample data - populate with full range 11-330ft

    // 11ft - Minimum length
    11: LengthCalculationResult(
      lengthFt: 11,
      boardingOptions: [
        BoardingOption(
          optionId: '11_option1',
          boards: [ComponentQuantity(size: 10, quantity: 6)],
          transomCount: 3,
          transomSingles: 12,
          toeBoardSingles: 12,
          isGolden: true,
        ),
      ],
      selectedBoardingOptionId: '11_option1',
      primaryLedgers: [ComponentQuantity(size: 10, quantity: 2)],
      staggeredLedgers: [ComponentQuantity(size: 10, quantity: 2)],
      ledgerSleeves: 0,
      topHandrails: [ComponentQuantity(size: 10, quantity: 2)],
      bottomHandrails: [ComponentQuantity(size: 10, quantity: 2)],
      handrailSleeves: 0,
      shortBoardSizes: [], // No short boards
      isGolden: true,
    ),

    // 20ft - Example with short boards
    20: LengthCalculationResult(
      lengthFt: 20,
      boardingOptions: [
        BoardingOption(
          optionId: '20_option1',
          boards: [
            ComponentQuantity(size: 13, quantity: 4),
            ComponentQuantity(size: 6, quantity: 2), // Short board
          ],
          transomCount: 4,
          transomSingles: 16,
          toeBoardSingles: 16,
          isGolden: true,
        ),
      ],
      selectedBoardingOptionId: '20_option1',
      primaryLedgers: [
        ComponentQuantity(size: 10, quantity: 2),
        ComponentQuantity(size: 10, quantity: 2),
      ],
      staggeredLedgers: [
        ComponentQuantity(size: 13, quantity: 2),
        ComponentQuantity(size: 6, quantity: 2),
      ],
      ledgerSleeves: 2,
      topHandrails: [
        ComponentQuantity(size: 10, quantity: 2),
        ComponentQuantity(size: 10, quantity: 2),
      ],
      bottomHandrails: [
        ComponentQuantity(size: 10, quantity: 2),
        ComponentQuantity(size: 10, quantity: 2),
      ],
      handrailSleeves: 2,
      shortBoardSizes: [6], // Flagged for board clips/droppers
      isGolden: true,
    ),

    // 30ft - Example with multiple boarding options
    30: LengthCalculationResult(
      lengthFt: 30,
      boardingOptions: [
        BoardingOption(
          optionId: '30_option1',
          boards: [
            ComponentQuantity(size: 13, quantity: 6),
            ComponentQuantity(size: 3, quantity: 2),
          ],
          transomCount: 5,
          transomSingles: 20,
          toeBoardSingles: 20,
          isGolden: true,
        ),
        BoardingOption(
          optionId: '30_option2',
          boards: [ComponentQuantity(size: 10, quantity: 8)],
          transomCount: 5,
          transomSingles: 20,
          toeBoardSingles: 20,
          isGolden: false,
        ),
      ],
      selectedBoardingOptionId: '30_option1', // Default to golden
      primaryLedgers: [
        ComponentQuantity(size: 13, quantity: 2),
        ComponentQuantity(size: 13, quantity: 2),
        ComponentQuantity(size: 3, quantity: 2),
      ],
      staggeredLedgers: [
        ComponentQuantity(size: 21, quantity: 2),
        ComponentQuantity(size: 8, quantity: 2),
      ],
      ledgerSleeves: 4,
      topHandrails: [
        ComponentQuantity(size: 13, quantity: 2),
        ComponentQuantity(size: 13, quantity: 2),
        ComponentQuantity(size: 3, quantity: 2),
      ],
      bottomHandrails: [
        ComponentQuantity(size: 13, quantity: 2),
        ComponentQuantity(size: 13, quantity: 2),
        ComponentQuantity(size: 3, quantity: 2),
      ],
      handrailSleeves: 4,
      shortBoardSizes: [3], // Flagged
      isGolden: true,
    ),

    // Add more lengths as needed (11-330ft)
    // TODO: Populate full length range with actual calculation data
  };

  /// Get length calculation for a specific length in feet
  static LengthCalculationResult? getLengthCalculation(int lengthFt) {
    return _lengthData[lengthFt];
  }

  /// Get the nearest available length (rounds up)
  static LengthCalculationResult? getNearestLength(int lengthFt) {
    if (_lengthData.containsKey(lengthFt)) {
      return _lengthData[lengthFt];
    }

    final availableLengths = _lengthData.keys.toList()..sort();
    for (final length in availableLengths) {
      if (length >= lengthFt) {
        return _lengthData[length];
      }
    }

    if (availableLengths.isNotEmpty) {
      return _lengthData[availableLengths.last];
    }

    return null;
  }

  /// Get all golden combinations
  static List<LengthCalculationResult> getGoldenCombinations() {
    return _lengthData.values.where((result) => result.isGolden).toList();
  }

  /// Check if a length is a golden combination
  static bool isGoldenLength(int lengthFt) {
    final result = _lengthData[lengthFt];
    return result?.isGolden ?? false;
  }
}
