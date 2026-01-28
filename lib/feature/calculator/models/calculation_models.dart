/// =====================================================
/// SCAFFOLD CALCULATOR - DATA MODELS
/// Based on Golden Reference 14 Documentation
/// =====================================================

/// Component with size and quantity
class SizedComponent {
  final String size;
  final int quantity;

  SizedComponent({required this.size, required this.quantity});

  @override
  String toString() => '$quantity x $size';
}

/// Lift types enum
enum LiftType {
  base2m('2M BASE LIFT'),
  fromBoarded2m('2M FROM BOARDED'),
  fromUnboarded2m('2M FROM UNBOARDED'),
  remainder1_5m('1.5M REMAINDER LIFT'),
  remainder1m('1M REMAINDER LIFT'),
  remainder0_5m('0.5M REMAINDER LIFT');

  final String displayName;
  const LiftType(this.displayName);
}

/// Single lift in the stack
class Lift {
  final int number;
  final double startHeight; // in meters
  final double endHeight; // in meters
  final LiftType type;
  final bool isBoarded;

  Lift({
    required this.number,
    required this.startHeight,
    required this.endHeight,
    required this.type,
    required this.isBoarded,
  });

  double get height => endHeight - startHeight;

  String get rangeDisplay => '${startHeight.toStringAsFixed(1)} - ${endHeight.toStringAsFixed(1)}m';

  @override
  String toString() => 'Lift $number: $rangeDisplay ($type, boarded: $isBoarded)';
}

/// Complete lift stack
class LiftStack {
  final List<Lift> lifts;

  LiftStack(this.lifts);

  int get totalLifts => lifts.length;
  int get boardedLifts => lifts.where((l) => l.isBoarded).length;
  int get unboardedLifts => totalLifts - boardedLifts;

  /// Count lifts by type
  Map<LiftType, int> get liftTypeCounts {
    final counts = <LiftType, int>{};
    for (final lift in lifts) {
      counts[lift.type] = (counts[lift.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Get base type for brace calculations
  String getLiftBaseType(LiftType type) {
    switch (type) {
      case LiftType.base2m:
        return '2m Base';
      case LiftType.fromBoarded2m:
      case LiftType.fromUnboarded2m:
        return '2m From Boarded';
      case LiftType.remainder1_5m:
        return '1.5m Remainder';
      case LiftType.remainder1m:
        return '1m Remainder';
      case LiftType.remainder0_5m:
        return '0.5m Remainder';
    }
  }
}

/// Height card result (per SET of standards)
class HeightResult {
  final int heightFt;
  final Map<String, int> primaryStandards; // size -> qty per set
  final Map<String, int> staggeredStandards; // size -> qty per set
  final int sleevesPerSet;
  final int soleBoardsPerLeg;
  final int baseplatesPerLeg;
  final int? goldenLength;
  final bool isGolden;

  HeightResult({
    required this.heightFt,
    required this.primaryStandards,
    required this.staggeredStandards,
    required this.sleevesPerSet,
    this.soleBoardsPerLeg = 1,
    this.baseplatesPerLeg = 1,
    this.goldenLength,
    this.isGolden = false,
  });

  /// Combined standards per SET (primary + staggered)
  Map<String, int> get combinedStandardsPerSet {
    final combined = <String, int>{};
    primaryStandards.forEach((size, qty) {
      combined[size] = (combined[size] ?? 0) + qty;
    });
    staggeredStandards.forEach((size, qty) {
      combined[size] = (combined[size] ?? 0) + qty;
    });
    return combined;
  }

  /// Total sleeves per SET (primary + staggered)
  int get totalSleevesPerSet => sleevesPerSet * 2;
}

/// Length card result (per lift)
class LengthResult {
  final int lengthFt;

  // Board options
  final BoardOption boardOption1;
  final BoardOption boardOption2;

  // Ledgers per lift (primary + staggered combined)
  final Map<String, int> ledgersPerLift;
  final int ledgerSleevesPerLift; // per run line, so x2 for primary+staggered

  // Handrails per lift (top + bottom combined)
  final Map<String, int> handrailsPerLift;
  final int handrailSleevesPerLift; // per run line, so x2 for top+bottom

  // Boards per boarded lift
  final Map<String, int> mainDeckBoardsPerLift;
  final Map<String, int> insideBoardsPerLift;
  final Map<String, int> toeBoardsPerLift;

  final int? goldenLength;
  final bool isGolden;

  LengthResult({
    required this.lengthFt,
    required this.boardOption1,
    required this.boardOption2,
    required this.ledgersPerLift,
    required this.ledgerSleevesPerLift,
    required this.handrailsPerLift,
    required this.handrailSleevesPerLift,
    required this.mainDeckBoardsPerLift,
    required this.insideBoardsPerLift,
    required this.toeBoardsPerLift,
    this.goldenLength,
    this.isGolden = false,
  });
}

/// Board option data
class BoardOption {
  final int optionNumber;
  final int transomCount;
  final int transomSingles;
  final int toeBoardSingles;
  final int insideBoardSingles;

  BoardOption({
    required this.optionNumber,
    required this.transomCount,
    required this.transomSingles,
    required this.toeBoardSingles,
    required this.insideBoardSingles,
  });
}

/// Bay card result
class BayResult {
  final int lengthFt;
  final int bayClass;

  // ONE-TIME outputs (not multiplied by lifts)
  final int setsOfLegs;
  final int numberOfBays;

  // PER-LIFT outputs
  final int ledgerDoublesPerLift;
  final int topHandrailDoublesPerLift;
  final int bottomHandrailDoublesPerLift;
  final int aberdeenDoublesPerLift;
  final int ledgerBracesPerLift;
  final int swayBracesPerLift;
  final int ledgerBraceSwivelsPerLift;
  final int swayBraceSwivelsPerLift;

  final bool isGolden;

  BayResult({
    required this.lengthFt,
    required this.bayClass,
    required this.setsOfLegs,
    required this.numberOfBays,
    required this.ledgerDoublesPerLift,
    required this.topHandrailDoublesPerLift,
    required this.bottomHandrailDoublesPerLift,
    required this.aberdeenDoublesPerLift,
    required this.ledgerBracesPerLift,
    required this.swayBracesPerLift,
    required this.ledgerBraceSwivelsPerLift,
    required this.swayBraceSwivelsPerLift,
    this.isGolden = false,
  });

  int get handrailDoublesPerLift =>
      topHandrailDoublesPerLift + bottomHandrailDoublesPerLift;

  int get swivelsPerLift =>
      ledgerBraceSwivelsPerLift + swayBraceSwivelsPerLift;
}

/// Width card result (per boarded lift)
class WidthResult {
  final int mainDeckBoards;
  final int insideBoards;

  // Component sizes
  final String transomLength;
  final String aberdeenLength;
  final String stopEndHandrailLength;
  final String stopEndToeBoardLength;
  final String stopEndDropperLength;
  final String shortDeckDropperLength;

  // Stop end handrails (per boarded lift)
  final int topStopEndHandrails;
  final int bottomStopEndHandrails;
  final int topStopEndHandrailDoubles;
  final int bottomStopEndHandrailDoubles;

  // Stop end toe boards (per boarded lift)
  final int stopEndToeBoards;
  final int droppersForStopEndToeBoards;
  final int doublesForStopEndToeBoards;
  final int singlesForStopEndToeBoards;

  // Short board handling
  final int boardClipsPerShortDeck;
  final int dropperPerShortDeck;
  final int doublesPerShortDeckDropper;

  final bool isGolden;

  WidthResult({
    required this.mainDeckBoards,
    required this.insideBoards,
    required this.transomLength,
    required this.aberdeenLength,
    required this.stopEndHandrailLength,
    required this.stopEndToeBoardLength,
    required this.stopEndDropperLength,
    required this.shortDeckDropperLength,
    required this.topStopEndHandrails,
    required this.bottomStopEndHandrails,
    required this.topStopEndHandrailDoubles,
    required this.bottomStopEndHandrailDoubles,
    required this.stopEndToeBoards,
    required this.droppersForStopEndToeBoards,
    required this.doublesForStopEndToeBoards,
    required this.singlesForStopEndToeBoards,
    required this.boardClipsPerShortDeck,
    required this.dropperPerShortDeck,
    required this.doublesPerShortDeckDropper,
    this.isGolden = false,
  });

  int get totalStopEndHandrails => topStopEndHandrails + bottomStopEndHandrails;
  int get totalStopEndHandrailDoubles =>
      topStopEndHandrailDoubles + bottomStopEndHandrailDoubles;
}

/// Final assembled quantities
class FinalQuantities {
  // Vertical components
  final Map<String, int> standards;
  final int sleeves;
  final int soleBoards;
  final int baseplates;

  // Horizontal components
  final Map<String, int> ledgers;
  final int ledgerSleeves;
  final Map<String, int> handrails;
  final int handrailSleeves;
  final Map<String, int> transoms;
  final Map<String, int> aberdeens;

  // Boards
  final Map<String, int> boards; // Combined main deck + inside + toe

  // Bracing
  final Map<String, int> ledgerBraces;
  final Map<String, int> swayBraces;
  final int swivels;

  // Fittings
  final int doubles;
  final int singles;
  final int boardClips;

  // Droppers
  final Map<String, int> droppers;

  // Validation
  final bool isGoldenHeight;
  final bool isGoldenLength;
  final bool isGoldenWidth;
  final bool liftLogicValid;

  FinalQuantities({
    required this.standards,
    required this.sleeves,
    required this.soleBoards,
    required this.baseplates,
    required this.ledgers,
    required this.ledgerSleeves,
    required this.handrails,
    required this.handrailSleeves,
    required this.transoms,
    required this.aberdeens,
    required this.boards,
    required this.ledgerBraces,
    required this.swayBraces,
    required this.swivels,
    required this.doubles,
    required this.singles,
    required this.boardClips,
    required this.droppers,
    this.isGoldenHeight = false,
    this.isGoldenLength = false,
    this.isGoldenWidth = false,
    this.liftLogicValid = true,
  });

  /// Format components map to display string
  String formatComponents(Map<String, int> components) {
    if (components.isEmpty) return '-';

    final sorted = components.entries.toList()
      ..sort((a, b) {
        // Sort by size (extract number from string like "21ft")
        final aNum = int.tryParse(a.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return bNum.compareTo(aNum); // Descending order
      });

    return sorted.map((e) => '${e.value} x ${e.key}').join(', ');
  }
}