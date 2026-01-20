import '../models/calculation_models.dart';

/// Lift validation data
/// Defines valid lift types and component permissions
class LiftCalculationData {
  /// Component permissions for each lift type
  static final Map<LiftType, LiftComponentPermissions> _liftPermissions = {
    // Boarded lift types
    LiftType.base2mBoarded: LiftComponentPermissions(
      ledgers: true,
      transoms: true,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: true,
      mainDeckBoards: true,
      insideBoards: true,
      toeBoards: true,
      stopEndHandrails: true,
      topHandrails: false, // Base doesn't have top handrail
      bottomHandrails: true,
      droppers: true,
    ),

    LiftType.from2mBoarded: LiftComponentPermissions(
      ledgers: true,
      transoms: true,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: true,
      mainDeckBoards: true,
      insideBoards: true,
      toeBoards: true,
      stopEndHandrails: true,
      topHandrails: true,
      bottomHandrails: true,
      droppers: true,
    ),

    LiftType.from2mUnboardedToBoarded: LiftComponentPermissions(
      ledgers: true,
      transoms: true,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: true,
      mainDeckBoards: true,
      insideBoards: true,
      toeBoards: true,
      stopEndHandrails: true,
      topHandrails: true,
      bottomHandrails: true,
      droppers: true,
    ),

    LiftType.remainder15mBoarded: LiftComponentPermissions(
      ledgers: true,
      transoms: true,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: true,
      mainDeckBoards: true,
      insideBoards: true,
      toeBoards: true,
      stopEndHandrails: true,
      topHandrails: true,
      bottomHandrails: false, // Top lift doesn't have bottom handrail
      droppers: true,
    ),

    LiftType.remainder10mBoarded: LiftComponentPermissions(
      ledgers: true,
      transoms: true,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: true,
      mainDeckBoards: true,
      insideBoards: true,
      toeBoards: true,
      stopEndHandrails: true,
      topHandrails: true,
      bottomHandrails: false,
      droppers: true,
    ),

    LiftType.remainder05mBoarded: LiftComponentPermissions(
      ledgers: true,
      transoms: true,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: true,
      mainDeckBoards: true,
      insideBoards: true,
      toeBoards: true,
      stopEndHandrails: true,
      topHandrails: true,
      bottomHandrails: false,
      droppers: true,
    ),

    // Unboarded lift types
    LiftType.baseWithBoardedAbove: LiftComponentPermissions(
      ledgers: true,
      transoms: false,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: false,
      mainDeckBoards: false,
      insideBoards: false,
      toeBoards: false,
      stopEndHandrails: false,
      topHandrails: false,
      bottomHandrails: false,
      droppers: false,
    ),

    LiftType.intermediateUnboarded: LiftComponentPermissions(
      ledgers: true,
      transoms: false,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: false,
      mainDeckBoards: false,
      insideBoards: false,
      toeBoards: false,
      stopEndHandrails: false,
      topHandrails: false,
      bottomHandrails: false,
      droppers: false,
    ),

    LiftType.unboardedWithRemainderAbove: LiftComponentPermissions(
      ledgers: true,
      transoms: false,
      ledgerBraces: true,
      swayBraces: true,
      aberdeens: false,
      mainDeckBoards: false,
      insideBoards: false,
      toeBoards: false,
      stopEndHandrails: false,
      topHandrails: false,
      bottomHandrails: false,
      droppers: false,
    ),
  };

  /// Get component permissions for a lift type
  static LiftComponentPermissions getPermissions(LiftType liftType) {
    return _liftPermissions[liftType] ?? _getDefaultPermissions();
  }

  /// Check if a component is allowed for a lift type
  static bool isComponentAllowed(LiftType liftType, String componentName) {
    final permissions = getPermissions(liftType);

    switch (componentName.toLowerCase()) {
      case 'ledgers':
        return permissions.ledgers;
      case 'transoms':
        return permissions.transoms;
      case 'ledgerbraces':
        return permissions.ledgerBraces;
      case 'swaybraces':
        return permissions.swayBraces;
      case 'aberdeens':
        return permissions.aberdeens;
      case 'maindeckboards':
        return permissions.mainDeckBoards;
      case 'insideboards':
        return permissions.insideBoards;
      case 'toeboards':
        return permissions.toeBoards;
      case 'stopendhandrails':
        return permissions.stopEndHandrails;
      case 'tophandrails':
        return permissions.topHandrails;
      case 'bottomhandrails':
        return permissions.bottomHandrails;
      case 'droppers':
        return permissions.droppers;
      default:
        return false;
    }
  }

  /// Get default permissions (all false for safety)
  static LiftComponentPermissions _getDefaultPermissions() {
    return LiftComponentPermissions(
      ledgers: false,
      transoms: false,
      ledgerBraces: false,
      swayBraces: false,
      aberdeens: false,
      mainDeckBoards: false,
      insideBoards: false,
      toeBoards: false,
      stopEndHandrails: false,
      topHandrails: false,
      bottomHandrails: false,
      droppers: false,
    );
  }

  /// Validate a lift configuration
  static bool isValidLiftConfiguration(List<LiftConfiguration> lifts) {
    if (lifts.isEmpty) return false;

    // First lift should be a base lift
    final firstLift = lifts.first;
    if (firstLift.liftType != LiftType.base2mBoarded &&
        firstLift.liftType != LiftType.baseWithBoardedAbove) {
      return false;
    }

    // All lifts should have valid permissions
    for (final lift in lifts) {
      if (!_liftPermissions.containsKey(lift.liftType)) {
        return false;
      }
    }

    return true;
  }
}
