import '../models/calculation_models.dart';

/// Width calculation data (12 fixed cards)
/// Selected based on: Main Deck Boards (3/4/5) × Inside Boards (0-3)
class WidthCalculationData {
  // Key format: "mainDeck_insideBoards" (e.g., "3_0", "4_2", "5_3")
  static final Map<String, WidthCalculationResult> _widthData = {
    // Main Deck: 3, Inside Boards: 0
    '3_0': WidthCalculationResult(
      mainDeckBoards: 3,
      insideBoards: 0,
      mainDeckBoardsPerDeck: 3,
      insideBoardsPerDeck: 0,
      toeBoardsPerDeck: 2,
      totalBoardsPerDeck: 5,
      topStopEndHandrails: 2,
      bottomStopEndHandrails: 2,
      stopEndHandrailDoubles: 4,
      stopEndToeBoards: 2,
      stopEndToeBoardSingles: 8,
      stopEndToeBoardDroppers: 4,
      stopEndToeBoardDropperDoubles: 8,
      boardClipsPerShortDeck: 6,
      droppersPerShortDeck: 3,
      dropperDoublesPerShortDeck: 6,
      transomLength: 4.0,
      stopEndHandrailLength: 4.0,
      aberdeenLength: 4.0,
      stopEndToeBoardLength: 4.0,
      dropperLengths: [3.0, 3.5, 4.0],
      isGolden: true,
    ),

    // Main Deck: 3, Inside Boards: 1
    '3_1': WidthCalculationResult(
      mainDeckBoards: 3,
      insideBoards: 1,
      mainDeckBoardsPerDeck: 3,
      insideBoardsPerDeck: 1,
      toeBoardsPerDeck: 2,
      totalBoardsPerDeck: 6,
      topStopEndHandrails: 2,
      bottomStopEndHandrails: 2,
      stopEndHandrailDoubles: 4,
      stopEndToeBoards: 2,
      stopEndToeBoardSingles: 10,
      stopEndToeBoardDroppers: 5,
      stopEndToeBoardDropperDoubles: 10,
      boardClipsPerShortDeck: 8,
      droppersPerShortDeck: 4,
      dropperDoublesPerShortDeck: 8,
      transomLength: 5.0,
      stopEndHandrailLength: 5.0,
      aberdeenLength: 5.0,
      stopEndToeBoardLength: 5.0,
      dropperLengths: [3.5, 4.0, 4.5],
      isGolden: false,
    ),

    // Main Deck: 4, Inside Boards: 0
    '4_0': WidthCalculationResult(
      mainDeckBoards: 4,
      insideBoards: 0,
      mainDeckBoardsPerDeck: 4,
      insideBoardsPerDeck: 0,
      toeBoardsPerDeck: 2,
      totalBoardsPerDeck: 6,
      topStopEndHandrails: 2,
      bottomStopEndHandrails: 2,
      stopEndHandrailDoubles: 4,
      stopEndToeBoards: 2,
      stopEndToeBoardSingles: 10,
      stopEndToeBoardDroppers: 5,
      stopEndToeBoardDropperDoubles: 10,
      boardClipsPerShortDeck: 8,
      droppersPerShortDeck: 4,
      dropperDoublesPerShortDeck: 8,
      transomLength: 5.0,
      stopEndHandrailLength: 5.0,
      aberdeenLength: 5.0,
      stopEndToeBoardLength: 5.0,
      dropperLengths: [4.0, 4.5, 5.0],
      isGolden: true,
    ),

    // Main Deck: 4, Inside Boards: 2
    '4_2': WidthCalculationResult(
      mainDeckBoards: 4,
      insideBoards: 2,
      mainDeckBoardsPerDeck: 4,
      insideBoardsPerDeck: 2,
      toeBoardsPerDeck: 2,
      totalBoardsPerDeck: 8,
      topStopEndHandrails: 2,
      bottomStopEndHandrails: 2,
      stopEndHandrailDoubles: 4,
      stopEndToeBoards: 2,
      stopEndToeBoardSingles: 12,
      stopEndToeBoardDroppers: 6,
      stopEndToeBoardDropperDoubles: 12,
      boardClipsPerShortDeck: 12,
      droppersPerShortDeck: 6,
      dropperDoublesPerShortDeck: 12,
      transomLength: 6.0,
      stopEndHandrailLength: 6.0,
      aberdeenLength: 6.0,
      stopEndToeBoardLength: 6.0,
      dropperLengths: [4.5, 5.0, 5.5],
      isGolden: false,
    ),

    // Main Deck: 5, Inside Boards: 0
    '5_0': WidthCalculationResult(
      mainDeckBoards: 5,
      insideBoards: 0,
      mainDeckBoardsPerDeck: 5,
      insideBoardsPerDeck: 0,
      toeBoardsPerDeck: 2,
      totalBoardsPerDeck: 7,
      topStopEndHandrails: 2,
      bottomStopEndHandrails: 2,
      stopEndHandrailDoubles: 4,
      stopEndToeBoards: 2,
      stopEndToeBoardSingles: 12,
      stopEndToeBoardDroppers: 6,
      stopEndToeBoardDropperDoubles: 12,
      boardClipsPerShortDeck: 10,
      droppersPerShortDeck: 5,
      dropperDoublesPerShortDeck: 10,
      transomLength: 6.0,
      stopEndHandrailLength: 6.0,
      aberdeenLength: 6.0,
      stopEndToeBoardLength: 6.0,
      dropperLengths: [5.0, 5.5, 6.0],
      isGolden: true,
    ),

    // Main Deck: 5, Inside Boards: 3
    '5_3': WidthCalculationResult(
      mainDeckBoards: 5,
      insideBoards: 3,
      mainDeckBoardsPerDeck: 5,
      insideBoardsPerDeck: 3,
      toeBoardsPerDeck: 2,
      totalBoardsPerDeck: 10,
      topStopEndHandrails: 2,
      bottomStopEndHandrails: 2,
      stopEndHandrailDoubles: 4,
      stopEndToeBoards: 2,
      stopEndToeBoardSingles: 16,
      stopEndToeBoardDroppers: 8,
      stopEndToeBoardDropperDoubles: 16,
      boardClipsPerShortDeck: 16,
      droppersPerShortDeck: 8,
      dropperDoublesPerShortDeck: 16,
      transomLength: 7.0,
      stopEndHandrailLength: 7.0,
      aberdeenLength: 7.0,
      stopEndToeBoardLength: 7.0,
      dropperLengths: [5.5, 6.0, 6.5],
      isGolden: false,
    ),

    // TODO: Add remaining 6 combinations to complete the 12 cards
    // Combinations needed: 3_2, 3_3, 4_1, 4_3, 5_1, 5_2
  };

  /// Get width calculation based on main deck boards and inside boards
  static WidthCalculationResult? getWidthCalculation(
    int mainDeckBoards,
    int insideBoards,
  ) {
    // Validate inputs
    if (mainDeckBoards < 3 || mainDeckBoards > 5) return null;
    if (insideBoards < 0 || insideBoards > 3) return null;

    final key = '${mainDeckBoards}_$insideBoards';
    return _widthData[key];
  }

  /// Get all golden width combinations
  static List<WidthCalculationResult> getGoldenCombinations() {
    return _widthData.values.where((result) => result.isGolden).toList();
  }

  /// Check if a width configuration is golden
  static bool isGoldenWidth(int mainDeckBoards, int insideBoards) {
    final result = getWidthCalculation(mainDeckBoards, insideBoards);
    return result?.isGolden ?? false;
  }

  /// Get all valid main deck board options
  static List<int> getValidMainDeckOptions() => [3, 4, 5];

  /// Get all valid inside board options
  static List<int> getValidInsideBoardOptions() => [0, 1, 2, 3];
}
