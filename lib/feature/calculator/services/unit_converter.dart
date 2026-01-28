/// =====================================================
/// UNIT CONVERTER SERVICE
/// Handles all unit conversions as per calculation logic
/// =====================================================

class UnitConverter {
  /// Conversion constants
  static const double feetPerMeter = 3.28084;
  static const double metersPerFoot = 0.3048;

  /// Convert meters to feet and round UP to nearest whole foot
  /// Used for run length conversion
  static int metersToFeetRoundedUp(double meters) {
    final feet = meters * feetPerMeter;
    return feet.ceil();
  }

  /// Convert meters to feet (no rounding)
  static double metersToFeet(double meters) {
    return meters * feetPerMeter;
  }

  /// Convert feet to meters
  static double feetToMeters(double feet) {
    return feet * metersPerFoot;
  }

  /// Calculate target scaffold height
  /// Takes top boarded lift in meters, converts to feet, rounds up, adds 4ft for handrail
  static int calculateTargetHeight(double topBoardedLiftM) {
    final heightFt = metersToFeetRoundedUp(topBoardedLiftM);
    return heightFt + 4; // +4ft for top handrail allowance
  }

  /// Get the height card key to use for a given target height
  /// Returns the nearest valid height card value
  static int getHeightCardKey(int targetHeightFt) {
    // Available height card values (would be expanded in full implementation)
    final availableHeights = [
      10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 46, 49, 52,
      55, 58, 61, 64, 67, 70, 73, 76, 79, 82, 85, 88, 91, 94, 97,
      100, 103, 106, 109, 112, 115, 118, 121, 124, 127, 130, 133,
      136, 139, 142, 145, 148, 151, 154, 157, 160, 163, 165
    ];

    // Find the smallest height card value >= target height
    for (final h in availableHeights) {
      if (h >= targetHeightFt) {
        return h;
      }
    }

    // If target exceeds all values, return max
    return availableHeights.last;
  }

  /// Get the length/bay card key to use for a given run length
  static int getLengthCardKey(int runLengthFt) {
    // Available length card values (11ft to 330ft)
    // For now, return the exact value if within range
    if (runLengthFt < 11) return 11;
    if (runLengthFt > 330) return 330;
    return runLengthFt;
  }
}