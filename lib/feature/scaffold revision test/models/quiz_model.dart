enum QuizDifficulty {
  part1('Part 1'),
  part2('Part 2'),
  advanced('Advanced');

  final String displayName;

  const QuizDifficulty(this.displayName);
}

class QuizModel {
  int id;
  String question;
  QuizDifficulty difficulty;
  List<String> options;
  int correctIndex;
  int? selectedIndex;
  QuizModel({
    required this.id,
    required this.question,
    required this.difficulty,
    required this.options,
    required this.correctIndex,
    this.selectedIndex,
  });
}
