import '../models/calculation_models.dart';
import '../data/lift_calculation_data.dart';

/// Generates lift stack to reach target height
/// Uses 2m increments with remainders (1.5m, 1.0m, 0.5m)
class LiftStackGenerator {
  /// Generate lift stack to reach target height
  /// Returns list of lift configurations in bottom-to-top order
  static List<LiftConfiguration> generateLiftStack({
    required double targetHeightM,
    required bool allLiftsBoarded,
  }) {
    final lifts = <LiftConfiguration>[];
    double currentHeight = 0.0;
    int liftNumber = 1;

    // First lift is always base
    final baseType = allLiftsBoarded
        ? LiftType.base2mBoarded
        : LiftType.baseWithBoardedAbove;

    lifts.add(
      LiftConfiguration(
        liftNumber: liftNumber++,
        liftType: baseType,
        heightM: 2.0,
        permissions: LiftCalculationData.getPermissions(baseType),
      ),
    );
    currentHeight += 2.0;

    // Add 2m lifts until we're close to target
    while (currentHeight + 2.0 <= targetHeightM) {
      final liftType = allLiftsBoarded
          ? LiftType.from2mBoarded
          : LiftType.intermediateUnboarded;

      lifts.add(
        LiftConfiguration(
          liftNumber: liftNumber++,
          liftType: liftType,
          heightM: 2.0,
          permissions: LiftCalculationData.getPermissions(liftType),
        ),
      );
      currentHeight += 2.0;
    }

    // Add remainder lift if needed
    final remainingHeight = targetHeightM - currentHeight;
    if (remainingHeight > 0.0) {
      final remainderLiftType = _getRemainderLiftType(
        remainingHeight,
        allLiftsBoarded,
      );
      final remainderHeight = _getRemainderHeight(remainingHeight);

      lifts.add(
        LiftConfiguration(
          liftNumber: liftNumber,
          liftType: remainderLiftType,
          heightM: remainderHeight,
          permissions: LiftCalculationData.getPermissions(remainderLiftType),
        ),
      );
    }

    return lifts;
  }

  /// Determine remainder lift type based on remaining height
  static LiftType _getRemainderLiftType(double remainingHeight, bool boarded) {
    if (!boarded) {
      return LiftType.unboardedWithRemainderAbove;
    }

    if (remainingHeight >= 1.25) {
      return LiftType.remainder15mBoarded;
    } else if (remainingHeight >= 0.75) {
      return LiftType.remainder10mBoarded;
    } else {
      return LiftType.remainder05mBoarded;
    }
  }

  /// Get actual remainder height (1.5m, 1.0m, or 0.5m)
  static double _getRemainderHeight(double remainingHeight) {
    if (remainingHeight >= 1.25) {
      return 1.5;
    } else if (remainingHeight >= 0.75) {
      return 1.0;
    } else {
      return 0.5;
    }
  }

  /// Calculate total height of lift stack
  static double calculateTotalHeight(List<LiftConfiguration> lifts) {
    return lifts.fold(0.0, (sum, lift) => sum + lift.heightM);
  }

  /// Count boarded lifts in stack
  static int countBoardedLifts(List<LiftConfiguration> lifts) {
    return lifts.where((lift) => lift.isBoarded).length;
  }

  /// Count lifts with handrails
  static int countHandrailLifts(List<LiftConfiguration> lifts) {
    return lifts.where((lift) => lift.hasHandrails).length;
  }

  /// Validate lift stack configuration
  static bool validateLiftStack(List<LiftConfiguration> lifts) {
    if (lifts.isEmpty) return false;

    // First lift must be a base
    final firstLift = lifts.first;
    if (firstLift.liftType != LiftType.base2mBoarded &&
        firstLift.liftType != LiftType.baseWithBoardedAbove) {
      return false;
    }

    // Lift numbers should be sequential
    for (int i = 0; i < lifts.length; i++) {
      if (lifts[i].liftNumber != i + 1) {
        return false;
      }
    }

    // Only last lift can be a remainder
    for (int i = 0; i < lifts.length - 1; i++) {
      final liftType = lifts[i].liftType;
      if (liftType == LiftType.remainder15mBoarded ||
          liftType == LiftType.remainder10mBoarded ||
          liftType == LiftType.remainder05mBoarded) {
        return false;
      }
    }

    return true;
  }
}
