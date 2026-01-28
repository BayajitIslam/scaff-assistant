/// =====================================================
/// CALCULATION SERVICE
/// Contains all card data tables and lookup functions
/// Based on Golden Reference 14 Documentation
/// =====================================================

import '../models/calculation_models.dart';

class CalculationService {
  // =====================================================
  // HEIGHT CARD DATA
  // Standards per SET at different heights
  // =====================================================

  static HeightResult? calculateHeight(int targetHeightFt) {
    // Height card data - key heights with their standard configurations
    // Each height defines primary and staggered builds for 1 SET of legs

    final heightData = _getHeightCardData();

    // Find the matching or next available height
    final sortedHeights = heightData.keys.toList()..sort();
    int? matchingHeight;

    for (final h in sortedHeights) {
      if (h >= targetHeightFt) {
        matchingHeight = h;
        break;
      }
    }

    matchingHeight ??= sortedHeights.last;

    return heightData[matchingHeight];
  }

  static Map<int, HeightResult> _getHeightCardData() {
    return {
      // 34ft height card
      34: HeightResult(
        heightFt: 34,
        primaryStandards: {'16ft': 2, '2ft': 1},
        staggeredStandards: {'21ft': 1, '7ft': 1, '6ft': 1},
        sleevesPerSet: 2,
        goldenLength: 37,
        isGolden: false,
      ),

      // 37ft height card (Golden)
      37: HeightResult(
        heightFt: 37,
        primaryStandards: {'16ft': 2, '5ft': 1},
        staggeredStandards: {'21ft': 1, '10ft': 1, '6ft': 1},
        sleevesPerSet: 2,
        goldenLength: 37,
        isGolden: true,
      ),

      // 40ft height card
      40: HeightResult(
        heightFt: 40,
        primaryStandards: {'16ft': 2, '8ft': 1},
        staggeredStandards: {'21ft': 1, '13ft': 1, '6ft': 1},
        sleevesPerSet: 2,
        isGolden: false,
      ),

      // 43ft height card
      43: HeightResult(
        heightFt: 43,
        primaryStandards: {'16ft': 2, '10ft': 1, '1ft': 1},
        staggeredStandards: {'21ft': 2, '1ft': 1},
        sleevesPerSet: 3,
        isGolden: false,
      ),

      // Add more height cards as needed...
      // 46ft, 49ft, 52ft, etc.
    };
  }

  // =====================================================
  // BAY CARD DATA
  // Geometry + per-lift components by length and class
  // =====================================================

  static BayResult? calculateBay(int lengthFt, int bayClass) {
    final bayData = _getBayCardData();

    // Find matching length or nearest
    final sortedLengths = bayData.keys.toList()..sort();
    int? matchingLength;

    for (final l in sortedLengths) {
      if (l >= lengthFt) {
        matchingLength = l;
        break;
      }
    }

    matchingLength ??= sortedLengths.last;

    final lengthData = bayData[matchingLength];
    if (lengthData == null) return null;

    return lengthData[bayClass];
  }

  static Map<int, Map<int, BayResult>> _getBayCardData() {
    return {
      // 137ft bay card
      137: {
        1: BayResult(
          lengthFt: 137,
          bayClass: 1,
          setsOfLegs: 17,
          numberOfBays: 16,
          ledgerDoublesPerLift: 34,
          topHandrailDoublesPerLift: 17,
          bottomHandrailDoublesPerLift: 17,
          aberdeenDoublesPerLift: 34,
          ledgerBracesPerLift: 9,
          swayBracesPerLift: 3,
          ledgerBraceSwivelsPerLift: 18,
          swayBraceSwivelsPerLift: 6,
          isGolden: false,
        ),
        2: BayResult(
          lengthFt: 137,
          bayClass: 2,
          setsOfLegs: 19,
          numberOfBays: 18,
          ledgerDoublesPerLift: 38,
          topHandrailDoublesPerLift: 19,
          bottomHandrailDoublesPerLift: 19,
          aberdeenDoublesPerLift: 38,
          ledgerBracesPerLift: 10,
          swayBracesPerLift: 3,
          ledgerBraceSwivelsPerLift: 20,
          swayBraceSwivelsPerLift: 6,
          isGolden: false,
        ),
        3: BayResult(
          lengthFt: 137,
          bayClass: 3,
          setsOfLegs: 22,
          numberOfBays: 21,
          ledgerDoublesPerLift: 44,
          topHandrailDoublesPerLift: 22,
          bottomHandrailDoublesPerLift: 22,
          aberdeenDoublesPerLift: 44,
          ledgerBracesPerLift: 12,
          swayBracesPerLift: 4,
          ledgerBraceSwivelsPerLift: 24,
          swayBraceSwivelsPerLift: 8,
          isGolden: false,
        ),
        4: BayResult(
          lengthFt: 137,
          bayClass: 4,
          setsOfLegs: 25,
          numberOfBays: 24,
          ledgerDoublesPerLift: 50,
          topHandrailDoublesPerLift: 25,
          bottomHandrailDoublesPerLift: 25,
          aberdeenDoublesPerLift: 50,
          ledgerBracesPerLift: 13,
          swayBracesPerLift: 4,
          ledgerBraceSwivelsPerLift: 26,
          swayBraceSwivelsPerLift: 8,
          isGolden: false,
        ),
      },

      // 138ft bay card (Golden length)
      138: {
        1: BayResult(
          lengthFt: 138,
          bayClass: 1,
          setsOfLegs: 17,
          numberOfBays: 16,
          ledgerDoublesPerLift: 34,
          topHandrailDoublesPerLift: 17,
          bottomHandrailDoublesPerLift: 17,
          aberdeenDoublesPerLift: 34,
          ledgerBracesPerLift: 9,
          swayBracesPerLift: 3,
          ledgerBraceSwivelsPerLift: 18,
          swayBraceSwivelsPerLift: 6,
          isGolden: true,
        ),
        2: BayResult(
          lengthFt: 138,
          bayClass: 2,
          setsOfLegs: 19,
          numberOfBays: 18,
          ledgerDoublesPerLift: 38,
          topHandrailDoublesPerLift: 19,
          bottomHandrailDoublesPerLift: 19,
          aberdeenDoublesPerLift: 38,
          ledgerBracesPerLift: 10,
          swayBracesPerLift: 3,
          ledgerBraceSwivelsPerLift: 20,
          swayBraceSwivelsPerLift: 6,
          isGolden: true,
        ),
        3: BayResult(
          lengthFt: 138,
          bayClass: 3,
          setsOfLegs: 22,
          numberOfBays: 21,
          ledgerDoublesPerLift: 44,
          topHandrailDoublesPerLift: 22,
          bottomHandrailDoublesPerLift: 22,
          aberdeenDoublesPerLift: 44,
          ledgerBracesPerLift: 12,
          swayBracesPerLift: 4,
          ledgerBraceSwivelsPerLift: 24,
          swayBraceSwivelsPerLift: 8,
          isGolden: true,
        ),
        4: BayResult(
          lengthFt: 138,
          bayClass: 4,
          setsOfLegs: 25,
          numberOfBays: 24,
          ledgerDoublesPerLift: 50,
          topHandrailDoublesPerLift: 25,
          bottomHandrailDoublesPerLift: 25,
          aberdeenDoublesPerLift: 50,
          ledgerBracesPerLift: 13,
          swayBracesPerLift: 4,
          ledgerBraceSwivelsPerLift: 26,
          swayBraceSwivelsPerLift: 8,
          isGolden: true,
        ),
      },

      // Add more length entries as needed...
    };
  }

  // =====================================================
  // LENGTH CARD DATA
  // Per-lift horizontal components
  // =====================================================

  static LengthResult? calculateLength(int lengthFt) {
    final lengthData = _getLengthCardData();

    // Find matching length or nearest
    final sortedLengths = lengthData.keys.toList()..sort();
    int? matchingLength;

    for (final l in sortedLengths) {
      if (l >= lengthFt) {
        matchingLength = l;
        break;
      }
    }

    matchingLength ??= sortedLengths.last;

    return lengthData[matchingLength];
  }

  static Map<int, LengthResult> _getLengthCardData() {
    return {
      // 137ft length card
      137: LengthResult(
        lengthFt: 137,
        boardOption1: BoardOption(
          optionNumber: 1,
          transomCount: 53,
          transomSingles: 106,
          toeBoardSingles: 22,
          insideBoardSingles: 22,
        ),
        boardOption2: BoardOption(
          optionNumber: 2,
          transomCount: 54,
          transomSingles: 108,
          toeBoardSingles: 24,
          insideBoardSingles: 24,
        ),
        ledgersPerLift: {'21ft': 10, '16ft': 4}, // Primary + Staggered combined
        ledgerSleevesPerLift: 6, // per run line
        handrailsPerLift: {'21ft': 10, '16ft': 4}, // Top + Bottom combined
        handrailSleevesPerLift: 6, // per run line
        mainDeckBoardsPerLift: {'13ft': 45, '8ft': 5, '6ft': 10},
        insideBoardsPerLift: {'13ft': 9, '8ft': 1, '6ft': 2},
        toeBoardsPerLift: {'13ft': 9, '8ft': 1, '6ft': 2},
        goldenLength: 138,
        isGolden: false,
      ),

      // 138ft length card (Golden)
      138: LengthResult(
        lengthFt: 138,
        boardOption1: BoardOption(
          optionNumber: 1,
          transomCount: 54,
          transomSingles: 108,
          toeBoardSingles: 23,
          insideBoardSingles: 23,
        ),
        boardOption2: BoardOption(
          optionNumber: 2,
          transomCount: 55,
          transomSingles: 110,
          toeBoardSingles: 24,
          insideBoardSingles: 24,
        ),
        ledgersPerLift: {'21ft': 10, '16ft': 4},
        ledgerSleevesPerLift: 6,
        handrailsPerLift: {'21ft': 10, '16ft': 4},
        handrailSleevesPerLift: 6,
        mainDeckBoardsPerLift: {'13ft': 45, '8ft': 5, '6ft': 10},
        insideBoardsPerLift: {'13ft': 9, '8ft': 1, '6ft': 2},
        toeBoardsPerLift: {'13ft': 9, '8ft': 1, '6ft': 2},
        goldenLength: 138,
        isGolden: true,
      ),

      // Add more length entries as needed...
    };
  }

  // =====================================================
  // WIDTH CARD DATA
  // 12 fixed cards based on main deck (3,4,5) x inside boards (0,1,2,3)
  // =====================================================

  static WidthResult? calculateWidth(int mainDeckBoards, int insideBoards) {
    final widthData = _getWidthCardData();
    final key = '${mainDeckBoards}-$insideBoards';
    return widthData[key];
  }

  static Map<String, WidthResult> _getWidthCardData() {
    return {
      // Main deck 5, Inside 1 (Golden combination)
      '5-1': WidthResult(
        mainDeckBoards: 5,
        insideBoards: 1,
        transomLength: '5ft',
        aberdeenLength: '6ft',
        stopEndHandrailLength: '6ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '5ft',
        shortDeckDropperLength: '5ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: true,
      ),

      // Main deck 5, Inside 0
      '5-0': WidthResult(
        mainDeckBoards: 5,
        insideBoards: 0,
        transomLength: '5ft',
        aberdeenLength: '6ft',
        stopEndHandrailLength: '6ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '5ft',
        shortDeckDropperLength: '5ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      // Main deck 4, Inside 1
      '4-1': WidthResult(
        mainDeckBoards: 4,
        insideBoards: 1,
        transomLength: '4ft',
        aberdeenLength: '5ft',
        stopEndHandrailLength: '5ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '4ft',
        shortDeckDropperLength: '4ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      // Main deck 4, Inside 0
      '4-0': WidthResult(
        mainDeckBoards: 4,
        insideBoards: 0,
        transomLength: '4ft',
        aberdeenLength: '5ft',
        stopEndHandrailLength: '5ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '4ft',
        shortDeckDropperLength: '4ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      // Main deck 3, Inside 1
      '3-1': WidthResult(
        mainDeckBoards: 3,
        insideBoards: 1,
        transomLength: '3ft',
        aberdeenLength: '4ft',
        stopEndHandrailLength: '4ft',
        stopEndToeBoardLength: '3ft',
        stopEndDropperLength: '3ft',
        shortDeckDropperLength: '3ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 6,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      // Main deck 3, Inside 0
      '3-0': WidthResult(
        mainDeckBoards: 3,
        insideBoards: 0,
        transomLength: '3ft',
        aberdeenLength: '4ft',
        stopEndHandrailLength: '4ft',
        stopEndToeBoardLength: '3ft',
        stopEndDropperLength: '3ft',
        shortDeckDropperLength: '3ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 6,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      // Add remaining combinations: 5-2, 5-3, 4-2, 4-3, 3-2, 3-3
      '5-2': WidthResult(
        mainDeckBoards: 5,
        insideBoards: 2,
        transomLength: '5ft',
        aberdeenLength: '6ft',
        stopEndHandrailLength: '6ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '5ft',
        shortDeckDropperLength: '5ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      '5-3': WidthResult(
        mainDeckBoards: 5,
        insideBoards: 3,
        transomLength: '5ft',
        aberdeenLength: '6ft',
        stopEndHandrailLength: '6ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '5ft',
        shortDeckDropperLength: '5ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      '4-2': WidthResult(
        mainDeckBoards: 4,
        insideBoards: 2,
        transomLength: '4ft',
        aberdeenLength: '5ft',
        stopEndHandrailLength: '5ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '4ft',
        shortDeckDropperLength: '4ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      '4-3': WidthResult(
        mainDeckBoards: 4,
        insideBoards: 3,
        transomLength: '4ft',
        aberdeenLength: '5ft',
        stopEndHandrailLength: '5ft',
        stopEndToeBoardLength: '4ft',
        stopEndDropperLength: '4ft',
        shortDeckDropperLength: '4ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 8,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      '3-2': WidthResult(
        mainDeckBoards: 3,
        insideBoards: 2,
        transomLength: '3ft',
        aberdeenLength: '4ft',
        stopEndHandrailLength: '4ft',
        stopEndToeBoardLength: '3ft',
        stopEndDropperLength: '3ft',
        shortDeckDropperLength: '3ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 6,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),

      '3-3': WidthResult(
        mainDeckBoards: 3,
        insideBoards: 3,
        transomLength: '3ft',
        aberdeenLength: '4ft',
        stopEndHandrailLength: '4ft',
        stopEndToeBoardLength: '3ft',
        stopEndDropperLength: '3ft',
        shortDeckDropperLength: '3ft',
        topStopEndHandrails: 2,
        bottomStopEndHandrails: 2,
        topStopEndHandrailDoubles: 4,
        bottomStopEndHandrailDoubles: 4,
        stopEndToeBoards: 2,
        droppersForStopEndToeBoards: 2,
        doublesForStopEndToeBoards: 4,
        singlesForStopEndToeBoards: 4,
        boardClipsPerShortDeck: 6,
        dropperPerShortDeck: 1,
        doublesPerShortDeckDropper: 2,
        isGolden: false,
      ),
    };
  }

  // =====================================================
  // BRACE SIZE TABLES
  // =====================================================

  /// Get ledger brace size based on main deck boards and lift type
  static String getLedgerBraceSize(int mainDeckBoards, String liftType) {
    final table = _getLedgerBraceSizeTable();
    return table[mainDeckBoards]?[liftType] ?? '7ft';
  }

  static Map<int, Map<String, String>> _getLedgerBraceSizeTable() {
    return {
      // Main deck 5 boards
      5: {
        '2m Base': '8ft',
        '2m From Boarded': '7ft',
        '2m From Unboarded': '7ft',
        '1.5m Remainder': '6ft',
        '1m Remainder': '5ft',
        '0.5m Remainder': '4ft',
      },
      // Main deck 4 boards
      4: {
        '2m Base': '7ft',
        '2m From Boarded': '6ft',
        '2m From Unboarded': '6ft',
        '1.5m Remainder': '5ft',
        '1m Remainder': '4ft',
        '0.5m Remainder': '4ft',
      },
      // Main deck 3 boards
      3: {
        '2m Base': '6ft',
        '2m From Boarded': '5ft',
        '2m From Unboarded': '5ft',
        '1.5m Remainder': '4ft',
        '1m Remainder': '4ft',
        '0.5m Remainder': '3ft',
      },
    };
  }

  /// Get sway brace size based on bay class and lift type
  static String getSwayBraceSize(int bayClass, String liftType) {
    final table = _getSwayBraceSizeTable();
    return table[bayClass]?[liftType] ?? '10ft';
  }

  static Map<int, Map<String, String>> _getSwayBraceSizeTable() {
    return {
      // Class 1 (2.7m bays)
      1: {
        '2m Base': '12ft',
        '2m From Boarded': '11ft',
        '2m From Unboarded': '11ft',
        '1.5m Remainder': '11ft',
        '1m Remainder': '10ft',
        '0.5m Remainder': '10ft',
      },
      // Class 2 (2.4m bays)
      2: {
        '2m Base': '11ft',
        '2m From Boarded': '10ft',
        '2m From Unboarded': '10ft',
        '1.5m Remainder': '10ft',
        '1m Remainder': '9ft',
        '0.5m Remainder': '9ft',
      },
      // Class 3 (2.0m bays)
      3: {
        '2m Base': '10ft',
        '2m From Boarded': '9ft',
        '2m From Unboarded': '9ft',
        '1.5m Remainder': '9ft',
        '1m Remainder': '8ft',
        '0.5m Remainder': '8ft',
      },
      // Class 4 (1.8m bays)
      4: {
        '2m Base': '9ft',
        '2m From Boarded': '8ft',
        '2m From Unboarded': '8ft',
        '1.5m Remainder': '8ft',
        '1m Remainder': '7ft',
        '0.5m Remainder': '7ft',
      },
    };
  }
}