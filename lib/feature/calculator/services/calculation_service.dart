import '../models/calculation_models.dart';
import '../data/height_calculation_data.dart';
import '../data/length_calculation_data.dart';
import '../data/bay_calculation_data.dart';
import '../data/width_calculation_data.dart';
import '../data/brace_calculation_data.dart';

/// Service for running individual calculation cards
class CalculationService {
  /// Run height calculation
  static HeightCalculationResult? calculateHeight(int heightFt) {
    return HeightCalculationData.getNearestHeight(heightFt);
  }

  /// Run length calculation
  static LengthCalculationResult? calculateLength(int lengthFt) {
    return LengthCalculationData.getNearestLength(lengthFt);
  }

  /// Run bay calculation
  static BayCalculationResult? calculateBay(int lengthFt, int bayClass) {
    return BayCalculationData.getNearestBay(lengthFt, bayClass);
  }

  /// Run width calculation
  static WidthCalculationResult? calculateWidth(
    int mainDeckBoards,
    int insideBoards,
  ) {
    return WidthCalculationData.getWidthCalculation(
      mainDeckBoards,
      insideBoards,
    );
  }

  /// Run brace calculation
  static BraceCalculationResult calculateBrace({
    required int bayClass,
    required int mainDeckBoards,
    required LiftType liftType,
  }) {
    return BraceCalculationData.getBraceCalculation(
      bayClass: bayClass,
      mainDeckBoards: mainDeckBoards,
      liftType: liftType,
    );
  }
}
