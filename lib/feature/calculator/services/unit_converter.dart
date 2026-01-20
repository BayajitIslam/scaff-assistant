/// Unit conversion utilities for scaffold calculations
class UnitConverter {
  /// Converts meters to feet and rounds UP to nearest whole foot
  /// This ensures material quantities are never under-estimated
  static int metersToFeetRoundedUp(double meters) {
    const feetPerMeter = 3.28084;
    final feet = meters * feetPerMeter;
    return feet.ceil(); // Always round up
  }

  /// Calculate target scaffold height
  /// Converts user height input + adds 4ft for top handrail
  static int calculateTargetHeight(double heightMeters) {
    final heightFt = metersToFeetRoundedUp(heightMeters);
    return heightFt + 4; // Add 4ft for top handrail compliance
  }

  /// Converts feet to meters (for display purposes)
  static double feetToMeters(double feet) {
    const metersPerFoot = 0.3048;
    return feet * metersPerFoot;
  }

  /// Format feet measurement for display
  static String formatFeet(double feet) {
    if (feet == feet.toInt()) {
      return '${feet.toInt()}ft';
    }
    return '${feet.toStringAsFixed(1)}ft';
  }

  /// Format meters measurement for display
  static String formatMeters(double meters) {
    if (meters == meters.toInt()) {
      return '${meters.toInt()}m';
    }
    return '${meters.toStringAsFixed(1)}m';
  }
}
