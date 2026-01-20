import '../models/calculation_models.dart';

/// Assembles final quantities from all calculation results
/// Applies multiplication rules and lift validation
class QuantityAssembler {
  /// Assemble final quantities from all calculation results
  static FinalQuantities assembleFinalQuantities({
    required HeightCalculationResult heightResult,
    required LengthCalculationResult lengthResult,
    required BayCalculationResult bayResult,
    required WidthCalculationResult widthResult,
    required List<LiftConfiguration> liftStack,
    required int bayClass,
    required int mainDeckBoards,
  }) {
    // Initialize component maps
    final standards = <double, int>{};
    final ledgers = <double, int>{};
    final transoms = <double, int>{};
    final boards = <double, int>{};
    final handrails = <double, int>{};
    final ledgerBraces = <double, int>{};
    final swayBraces = <double, int>{};
    final droppers = <double, int>{};

    int totalDoubles = 0;
    int totalSwivels = 0;
    int totalSleeves = 0;
    int totalSingles = 0;
    int totalBoardClips = 0;

    // Count lift types
    final totalLifts = liftStack.length;
    final boardedLifts = liftStack.where((l) => l.isBoarded).toList();
    final handrailLifts = liftStack.where((l) => l.hasHandrails).toList();

    // ===== STANDARDS (Height × Sets of Legs) =====
    // Applied ONCE (not per lift)
    final setsOfLegs = bayResult.setsOfLegs;

    for (final component in heightResult.primaryStandards) {
      _addComponent(standards, component.size, component.quantity * setsOfLegs);
    }
    for (final component in heightResult.staggeredStandards) {
      _addComponent(standards, component.size, component.quantity * setsOfLegs);
    }

    // Height sleeves × sets of legs (one-time)
    totalSleeves += heightResult.sleeves * setsOfLegs;

    // ===== LEDGERS (Length × Lifts) =====
    // Applied per lift
    for (final lift in liftStack) {
      if (!lift.permissions.ledgers) continue;

      for (final component in lengthResult.primaryLedgers) {
        _addComponent(ledgers, component.size, component.quantity);
      }
      for (final component in lengthResult.staggeredLedgers) {
        _addComponent(ledgers, component.size, component.quantity);
      }

      totalSleeves += lengthResult.ledgerSleeves;
    }

    // Bay ledger doubles (per lift)
    totalDoubles += bayResult.ledgerDoubles * totalLifts;

    // ===== TRANSOMS & BOARDS (Length × Width × Boarded Lifts) =====
    for (final lift in boardedLifts) {
      if (!lift.permissions.transoms) continue;

      // Transoms from length calculation
      final selectedBoarding = lengthResult.selectedBoardingOption;
      totalSingles += selectedBoarding.transomSingles;
      totalSingles += selectedBoarding.toeBoardSingles;
      totalSingles += selectedBoarding.insideBoardSingles;

      // Boards from length × width
      for (final boardComponent in selectedBoarding.boards) {
        final totalBoardsThisSize =
            boardComponent.quantity * widthResult.totalBoardsPerDeck;
        _addComponent(boards, boardComponent.size, totalBoardsThisSize);
      }

      // Stop-end toe boards (width calculation, boarded lifts only)
      totalSingles += widthResult.stopEndToeBoardSingles;
      totalDoubles += widthResult.stopEndToeBoardDropperDoubles;

      // Add stop-end toe board droppers
      _addComponent(
        droppers,
        widthResult.stopEndToeBoardLength,
        widthResult.stopEndToeBoardDroppers,
      );
    }

    // ===== HANDRAILS (Conditional on Handrail Lifts) =====
    for (final lift in handrailLifts) {
      // Top handrails
      if (lift.permissions.topHandrails) {
        for (final component in lengthResult.topHandrails) {
          _addComponent(handrails, component.size, component.quantity);
        }

        // Stop-end top handrails from width
        _addComponent(
          handrails,
          widthResult.stopEndHandrailLength,
          widthResult.topStopEndHandrails,
        );
      }

      // Bottom handrails
      if (lift.permissions.bottomHandrails) {
        for (final component in lengthResult.bottomHandrails) {
          _addComponent(handrails, component.size, component.quantity);
        }

        // Stop-end bottom handrails from width
        _addComponent(
          handrails,
          widthResult.stopEndHandrailLength,
          widthResult.bottomStopEndHandrails,
        );
      }

      totalSleeves += lengthResult.handrailSleeves;
      totalDoubles += widthResult.stopEndHandrailDoubles;
    }

    // Bay handrail doubles (only for handrail lifts)
    totalDoubles += bayResult.handrailDoubles * handrailLifts.length;

    // ===== BRACING (Bay × Lifts with Brace Sizing) =====
    for (final lift in liftStack) {
      if (lift.permissions.ledgerBraces) {
        // Get brace size for this lift type
        final braceSize = _getLedgerBraceSize(mainDeckBoards, lift.liftType);
        _addComponent(ledgerBraces, braceSize, bayResult.ledgerBraces);
      }

      if (lift.permissions.swayBraces) {
        final braceSize = _getSwayBraceSize(bayClass, lift.liftType);
        _addComponent(swayBraces, braceSize, bayResult.swayBraces);
      }

      // Swivels for bracing (per lift)
      totalSwivels += bayResult.swivelsForLedgerBraces;
      totalSwivels += bayResult.swivelsForSwayBraces;
    }

    // ===== ABERDEENS (Bay × Boarded Lifts) =====
    totalDoubles += bayResult.aberdeenDoubles * boardedLifts.length;

    // ===== SHORT BOARD CLIPS & DROPPERS =====
    // Triggered by short boards from length calculation
    if (lengthResult.shortBoardSizes.isNotEmpty) {
      final shortDeckCount = boardedLifts.length;
      totalBoardClips += widthResult.boardClipsPerShortDeck * shortDeckCount;
      totalDoubles += widthResult.dropperDoublesPerShortDeck * shortDeckCount;

      // Add short deck droppers
      for (final dropperLength in widthResult.dropperLengths) {
        _addComponent(
          droppers,
          dropperLength,
          widthResult.droppersPerShortDeck * shortDeckCount,
        );
      }
    }

    // ===== BASE SUPPORT (Height × Sets of Legs, One-Time) =====
    final soleBoards = heightResult.soleBoards * setsOfLegs;
    final baseplates = heightResult.baseplates * setsOfLegs;

    return FinalQuantities(
      standards: standards,
      ledgers: ledgers,
      transoms: transoms,
      boards: boards,
      handrails: handrails,
      ledgerBraces: ledgerBraces,
      swayBraces: swayBraces,
      doubles: totalDoubles,
      swivels: totalSwivels,
      sleeves: totalSleeves,
      singles: totalSingles,
      boardClips: totalBoardClips,
      soleBoards: soleBoards,
      baseplates: baseplates,
      droppers: droppers,
      totalLifts: totalLifts,
      boardedLifts: boardedLifts.length,
      totalHeightM: liftStack.fold(0.0, (sum, lift) => sum + lift.heightM),
      totalLengthM: 0.0, // Set by caller
    );
  }

  /// Helper to add component to map
  static void _addComponent(Map<double, int> map, double size, int quantity) {
    map[size] = (map[size] ?? 0) + quantity;
  }

  /// Get ledger brace size for lift type (simplified - should use BraceCalculationData)
  static double _getLedgerBraceSize(int mainDeckBoards, LiftType liftType) {
    // Simplified logic - in real implementation, use BraceCalculationData
    if (mainDeckBoards == 3) return 8.0;
    if (mainDeckBoards == 4) return 10.0;
    return 10.0;
  }

  /// Get sway brace size for lift type (simplified - should use BraceCalculationData)
  static double _getSwayBraceSize(int bayClass, LiftType liftType) {
    // Simplified logic - in real implementation, use BraceCalculationData
    if (bayClass == 1) return 10.0;
    if (bayClass == 2 || bayClass == 3) return 13.0;
    return 16.0;
  }
}
