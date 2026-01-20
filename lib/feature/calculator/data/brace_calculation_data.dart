import '../models/calculation_models.dart';

/// Brace sizing calculation data
/// Determines correct brace sizes based on width, bay class, and lift type
class BraceCalculationData {
  /// Sway brace sizing table
  /// Key format: "bayClass_liftType"
  static final Map<String, double> _swayBraceSizes = {
    // Bay Class 1
    '1_base': 10.0,
    '1_boarded': 10.0,
    '1_unboarded': 10.0,
    '1_remainder': 8.0,

    // Bay Class 2
    '2_base': 13.0,
    '2_boarded': 13.0,
    '2_unboarded': 13.0,
    '2_remainder': 10.0,

    // Bay Class 3
    '3_base': 13.0,
    '3_boarded': 13.0,
    '3_unboarded': 13.0,
    '3_remainder': 10.0,

    // Bay Class 4
    '4_base': 16.0,
    '4_boarded': 16.0,
    '4_unboarded': 16.0,
    '4_remainder': 13.0,
  };

  /// Ledger brace sizing table
  /// Key format: "mainDeckBoards_liftType"
  static final Map<String, double> _ledgerBraceSizes = {
    // 3 boards wide
    '3_base': 8.0,
    '3_boarded': 8.0,
    '3_unboarded': 8.0,
    '3_remainder': 6.0,

    // 4 boards wide
    '4_base': 10.0,
    '4_boarded': 10.0,
    '4_unboarded': 10.0,
    '4_remainder': 8.0,

    // 5 boards wide
    '5_base': 10.0,
    '5_boarded': 10.0,
    '5_unboarded': 10.0,
    '5_remainder': 8.0,
  };

  /// Get sway brace size based on bay class and lift type
  static double getSwayBraceSize(int bayClass, LiftType liftType) {
    final liftCategory = _getLiftCategory(liftType);
    final key = '${bayClass}_$liftCategory';
    return _swayBraceSizes[key] ?? 10.0; // Default to 10ft if not found
  }

  /// Get ledger brace size based on width configuration and lift type
  static double getLedgerBraceSize(int mainDeckBoards, LiftType liftType) {
    final liftCategory = _getLiftCategory(liftType);
    final key = '${mainDeckBoards}_$liftCategory';
    return _ledgerBraceSizes[key] ?? 8.0; // Default to 8ft if not found
  }

  /// Get complete brace calculation result
  static BraceCalculationResult getBraceCalculation({
    required int bayClass,
    required int mainDeckBoards,
    required LiftType liftType,
  }) {
    return BraceCalculationResult(
      ledgerBraceSize: getLedgerBraceSize(mainDeckBoards, liftType),
      swayBraceSize: getSwayBraceSize(bayClass, liftType),
    );
  }

  /// Convert lift type to category for brace sizing
  static String _getLiftCategory(LiftType liftType) {
    switch (liftType) {
      case LiftType.base2mBoarded:
      case LiftType.baseWithBoardedAbove:
        return 'base';

      case LiftType.from2mBoarded:
      case LiftType.from2mUnboardedToBoarded:
        return 'boarded';

      case LiftType.intermediateUnboarded:
      case LiftType.unboardedWithRemainderAbove:
        return 'unboarded';

      case LiftType.remainder15mBoarded:
      case LiftType.remainder10mBoarded:
      case LiftType.remainder05mBoarded:
        return 'remainder';
    }
  }
}
