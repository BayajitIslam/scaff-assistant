/// =====================================================
/// LIFT STACK GENERATOR SERVICE
/// Generates valid lift configurations based on target height
/// =====================================================

import '../models/calculation_models.dart';

class LiftStackGenerator {
  /// Generate a lift stack for the given target height
  /// 
  /// Rules:
  /// - All lifts built in 2m increments where possible
  /// - Remainder lifts (1.5m, 1.0m, 0.5m) used only if needed
  /// - Base lift is always first
  /// - Remainders exist solely to achieve exact target height
  static LiftStack generateLiftStack({
    required double targetHeightM,
    required List<double> selectedBoardedHeights,
  }) {
    final lifts = <Lift>[];
    double currentHeight = 0;
    int liftNumber = 1;

    // Start with 2m base lift
    final baseBoarded = selectedBoardedHeights.contains(2.0);
    lifts.add(Lift(
      number: liftNumber++,
      startHeight: 0,
      endHeight: 2,
      type: LiftType.base2m,
      isBoarded: baseBoarded,
    ));
    currentHeight = 2;

    // Build remaining lifts
    while (currentHeight < targetHeightM) {
      final remaining = targetHeightM - currentHeight;
      final prevLift = lifts.last;

      if (remaining >= 2) {
        // Full 2m lift
        final endHeight = currentHeight + 2;
        final isBoarded = selectedBoardedHeights.contains(endHeight);
        
        LiftType liftType;
        if (prevLift.isBoarded) {
          liftType = LiftType.fromBoarded2m;
        } else {
          liftType = LiftType.fromUnboarded2m;
        }

        lifts.add(Lift(
          number: liftNumber++,
          startHeight: currentHeight,
          endHeight: endHeight,
          type: liftType,
          isBoarded: isBoarded,
        ));
        currentHeight = endHeight;
      } else if (remaining >= 1.5) {
        // 1.5m remainder
        final endHeight = currentHeight + 1.5;
        final isBoarded = selectedBoardedHeights.contains(endHeight);

        lifts.add(Lift(
          number: liftNumber++,
          startHeight: currentHeight,
          endHeight: endHeight,
          type: LiftType.remainder1_5m,
          isBoarded: isBoarded,
        ));
        currentHeight = endHeight;
      } else if (remaining >= 1) {
        // 1m remainder
        final endHeight = currentHeight + 1;
        final isBoarded = selectedBoardedHeights.contains(endHeight);

        lifts.add(Lift(
          number: liftNumber++,
          startHeight: currentHeight,
          endHeight: endHeight,
          type: LiftType.remainder1m,
          isBoarded: isBoarded,
        ));
        currentHeight = endHeight;
      } else if (remaining >= 0.5) {
        // 0.5m remainder
        final endHeight = currentHeight + 0.5;
        final isBoarded = selectedBoardedHeights.contains(endHeight);

        lifts.add(Lift(
          number: liftNumber++,
          startHeight: currentHeight,
          endHeight: endHeight,
          type: LiftType.remainder0_5m,
          isBoarded: isBoarded,
        ));
        currentHeight = endHeight;
      } else {
        break;
      }
    }

    return LiftStack(lifts);
  }

  /// Generate available lift heights for user selection
  /// Returns list of heights where lifts end (in meters)
  static List<double> getAvailableLiftHeights(double topBoardedLift) {
    final heights = <double>[];
    double currentHeight = 0;

    while (currentHeight < topBoardedLift) {
      final remaining = topBoardedLift - currentHeight;

      if (remaining >= 2) {
        currentHeight += 2;
        heights.add(currentHeight);
      } else if (remaining >= 1.5) {
        currentHeight += 1.5;
        heights.add(currentHeight);
      } else if (remaining >= 1) {
        currentHeight += 1;
        heights.add(currentHeight);
      } else if (remaining >= 0.5) {
        currentHeight += 0.5;
        heights.add(currentHeight);
      } else {
        break;
      }
    }

    return heights;
  }

  /// Validate a lift stack
  static bool validateLiftStack(LiftStack stack) {
    if (stack.lifts.isEmpty) return false;

    // First lift must be base lift
    if (stack.lifts.first.type != LiftType.base2m) return false;

    // Check continuity
    for (int i = 1; i < stack.lifts.length; i++) {
      final prev = stack.lifts[i - 1];
      final curr = stack.lifts[i];
      
      // End of previous should equal start of current
      if ((prev.endHeight - curr.startHeight).abs() > 0.001) {
        return false;
      }
    }

    // Must have at least one boarded lift
    if (stack.boardedLifts == 0) return false;

    return true;
  }

  /// Generate default boarded heights (top lift only)
  static List<double> getDefaultBoardedHeights(double topBoardedLift) {
    return [topBoardedLift];
  }

  /// Generate all lifts boarded heights
  static List<double> getAllBoardedHeights(double topBoardedLift) {
    return getAvailableLiftHeights(topBoardedLift);
  }
}