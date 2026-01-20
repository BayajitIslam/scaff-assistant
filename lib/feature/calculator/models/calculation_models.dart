/// Core data models for scaffold quantity calculations
/// Each model represents the output of a specific calculation card

/// Represents a component with size and quantity
class ComponentQuantity {
  final double size; // in feet
  final int quantity;

  ComponentQuantity({required this.size, required this.quantity});

  @override
  String toString() => '${size}ft × $quantity';
}

/// Height Calculation Result (per SET of standards)
class HeightCalculationResult {
  final double heightFt;
  final List<ComponentQuantity> primaryStandards;
  final List<ComponentQuantity> staggeredStandards;
  final int sleeves;
  final int soleBoards; // Always 2 per SET
  final int baseplates; // Always 2 per SET
  final bool isGolden;

  HeightCalculationResult({
    required this.heightFt,
    required this.primaryStandards,
    required this.staggeredStandards,
    required this.sleeves,
    this.soleBoards = 2,
    this.baseplates = 2,
    this.isGolden = false,
  });
}

/// Boarding option for length calculation
class BoardingOption {
  final String optionId;
  final List<ComponentQuantity> boards;
  final int transomCount;
  final int transomSingles;
  final int toeBoardSingles;
  final int insideBoardSingles;
  final bool isGolden;

  BoardingOption({
    required this.optionId,
    required this.boards,
    required this.transomCount,
    required this.transomSingles,
    required this.toeBoardSingles,
    this.insideBoardSingles = 0,
    this.isGolden = false,
  });
}

/// Length Calculation Result (per lift)
class LengthCalculationResult {
  final double lengthFt;
  final List<BoardingOption> boardingOptions;
  final String selectedBoardingOptionId;
  final List<ComponentQuantity> primaryLedgers;
  final List<ComponentQuantity> staggeredLedgers;
  final int ledgerSleeves;
  final List<ComponentQuantity> topHandrails;
  final List<ComponentQuantity> bottomHandrails;
  final int handrailSleeves;
  final List<double>
  shortBoardSizes; // Boards ≤ 6ft (flagged for clips/droppers)
  final bool isGolden;

  LengthCalculationResult({
    required this.lengthFt,
    required this.boardingOptions,
    required this.selectedBoardingOptionId,
    required this.primaryLedgers,
    required this.staggeredLedgers,
    required this.ledgerSleeves,
    required this.topHandrails,
    required this.bottomHandrails,
    required this.handrailSleeves,
    this.shortBoardSizes = const [],
    this.isGolden = false,
  });

  BoardingOption get selectedBoardingOption => boardingOptions.firstWhere(
    (opt) => opt.optionId == selectedBoardingOptionId,
  );
}

/// Bay Calculation Result
class BayCalculationResult {
  final double lengthFt;
  final int bayClass; // 1-4

  // One-time outputs (applied once, not per lift)
  final int setsOfLegs;
  final int numberOfBays;
  final List<double> bayDimensions;
  final String endBaySplitDescription;

  // Per-lift outputs
  final int ledgerDoubles;
  final int handrailDoubles; // Conditional - only if lift has handrails
  final int aberdeenDoubles;
  final int ledgerBraces;
  final int swayBraces;
  final int swivelsForLedgerBraces;
  final int swivelsForSwayBraces;

  final bool isGolden;

  BayCalculationResult({
    required this.lengthFt,
    required this.bayClass,
    required this.setsOfLegs,
    required this.numberOfBays,
    required this.bayDimensions,
    required this.endBaySplitDescription,
    required this.ledgerDoubles,
    required this.handrailDoubles,
    required this.aberdeenDoubles,
    required this.ledgerBraces,
    required this.swayBraces,
    required this.swivelsForLedgerBraces,
    required this.swivelsForSwayBraces,
    this.isGolden = false,
  });

  int get totalSwivels => swivelsForLedgerBraces + swivelsForSwayBraces;
}

/// Width Calculation Result
class WidthCalculationResult {
  final int mainDeckBoards; // 3, 4, or 5
  final int insideBoards; // 0-3

  // Boards per deck
  final int mainDeckBoardsPerDeck;
  final int insideBoardsPerDeck;
  final int toeBoardsPerDeck;
  final int totalBoardsPerDeck;

  // Stop-end handrails (conditional - only if lift has handrails)
  final int topStopEndHandrails;
  final int bottomStopEndHandrails;
  final int stopEndHandrailDoubles;

  // Stop-end toe boards (boarded lifts only)
  final int stopEndToeBoards;
  final int stopEndToeBoardSingles;
  final int stopEndToeBoardDroppers;
  final int stopEndToeBoardDropperDoubles;

  // Board clips & short deck droppers (triggered by short boards from length calc)
  final int boardClipsPerShortDeck;
  final int droppersPerShortDeck;
  final int dropperDoublesPerShortDeck;

  // Component sizes (reference values)
  final double transomLength;
  final double stopEndHandrailLength;
  final double aberdeenLength;
  final double stopEndToeBoardLength;
  final List<double> dropperLengths;

  final bool isGolden;

  WidthCalculationResult({
    required this.mainDeckBoards,
    required this.insideBoards,
    required this.mainDeckBoardsPerDeck,
    required this.insideBoardsPerDeck,
    required this.toeBoardsPerDeck,
    required this.totalBoardsPerDeck,
    required this.topStopEndHandrails,
    required this.bottomStopEndHandrails,
    required this.stopEndHandrailDoubles,
    required this.stopEndToeBoards,
    required this.stopEndToeBoardSingles,
    required this.stopEndToeBoardDroppers,
    required this.stopEndToeBoardDropperDoubles,
    required this.boardClipsPerShortDeck,
    required this.droppersPerShortDeck,
    required this.dropperDoublesPerShortDeck,
    required this.transomLength,
    required this.stopEndHandrailLength,
    required this.aberdeenLength,
    required this.stopEndToeBoardLength,
    required this.dropperLengths,
    this.isGolden = false,
  });
}

/// Brace sizing result
class BraceCalculationResult {
  final double ledgerBraceSize;
  final double swayBraceSize;

  BraceCalculationResult({
    required this.ledgerBraceSize,
    required this.swayBraceSize,
  });
}

/// Lift type enumeration
enum LiftType {
  base2mBoarded,
  from2mBoarded,
  from2mUnboardedToBoarded,
  remainder15mBoarded,
  remainder10mBoarded,
  remainder05mBoarded,
  baseWithBoardedAbove,
  intermediateUnboarded,
  unboardedWithRemainderAbove,
}

/// Component permissions for a lift type
class LiftComponentPermissions {
  final bool ledgers;
  final bool transoms;
  final bool ledgerBraces;
  final bool swayBraces;
  final bool aberdeens;
  final bool mainDeckBoards;
  final bool insideBoards;
  final bool toeBoards;
  final bool stopEndHandrails;
  final bool topHandrails;
  final bool bottomHandrails;
  final bool droppers;

  LiftComponentPermissions({
    required this.ledgers,
    required this.transoms,
    required this.ledgerBraces,
    required this.swayBraces,
    required this.aberdeens,
    required this.mainDeckBoards,
    required this.insideBoards,
    required this.toeBoards,
    required this.stopEndHandrails,
    required this.topHandrails,
    required this.bottomHandrails,
    required this.droppers,
  });

  bool get isBoarded => mainDeckBoards;
  bool get hasHandrails => topHandrails || bottomHandrails || stopEndHandrails;
}

/// Lift configuration
class LiftConfiguration {
  final int liftNumber; // 1-based index
  final LiftType liftType;
  final double heightM; // 2.0, 1.5, 1.0, or 0.5
  final LiftComponentPermissions permissions;

  LiftConfiguration({
    required this.liftNumber,
    required this.liftType,
    required this.heightM,
    required this.permissions,
  });

  bool get isBoarded => permissions.isBoarded;
  bool get hasHandrails => permissions.hasHandrails;
}

/// Final assembled quantities
class FinalQuantities {
  // Standards (vertical)
  final Map<double, int> standards; // size -> quantity

  // Ledgers (horizontal)
  final Map<double, int> ledgers;

  // Transoms
  final Map<double, int> transoms;

  // Boards
  final Map<double, int> boards;

  // Handrails
  final Map<double, int> handrails;

  // Bracing
  final Map<double, int> ledgerBraces;
  final Map<double, int> swayBraces;

  // Fittings
  final int doubles;
  final int swivels;
  final int sleeves;
  final int singles;
  final int boardClips;

  // Base support
  final int soleBoards;
  final int baseplates;

  // Droppers
  final Map<double, int> droppers;

  // Metadata
  final int totalLifts;
  final int boardedLifts;
  final double totalHeightM;
  final double totalLengthM;

  FinalQuantities({
    required this.standards,
    required this.ledgers,
    required this.transoms,
    required this.boards,
    required this.handrails,
    required this.ledgerBraces,
    required this.swayBraces,
    required this.doubles,
    required this.swivels,
    required this.sleeves,
    required this.singles,
    required this.boardClips,
    required this.soleBoards,
    required this.baseplates,
    required this.droppers,
    required this.totalLifts,
    required this.boardedLifts,
    required this.totalHeightM,
    required this.totalLengthM,
  });

  /// Format a component map as a string (e.g., "21ft × 24, 16ft × 8")
  String formatComponents(Map<double, int> components) {
    if (components.isEmpty) return '-';
    return components.entries.map((e) => '${e.key}ft × ${e.value}').join(', ');
  }
}
