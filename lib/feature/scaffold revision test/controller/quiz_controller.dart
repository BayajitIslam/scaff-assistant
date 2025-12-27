import 'package:get/get.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/feature/scaffold%20revision%20test/models/quiz_model.dart';
import 'package:scaffassistant/routing/route_name.dart';

class QuizController extends GetxController {
  //<=========================== VARIABLES ===========================>

  // All Questions
  RxList<QuizModel> allQuestions = <QuizModel>[].obs;
  // Current Questions
  RxList<QuizModel> currentQuestions = <QuizModel>[].obs;

  // Selected Difficulty
  Rx<QuizDifficulty> selectedDifficulty = QuizDifficulty.part1.obs;
  // Selected Question Count
  RxList questionsCountOptions = [10, 25, 50].obs;
  //  Selected Question Count
  RxInt selectedQuestionCount = 10.obs;
  // Current Question
  RxInt currentQuestionIndex = 0.obs;
  // Is Answered
  RxBool isAnswered = false.obs;
  // Correct Count
  RxInt correctCount = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadQuestions();
  }

  void loadQuestions() {
    allQuestions.value = dummyQuiz;
  }

  //<============================ Start Quiz ============================>
  void startQuiz(QuizDifficulty difficulty, int count) {
    selectedDifficulty.value = difficulty;
    currentQuestionIndex.value = 0;
    var filtered = allQuestions
        .where((element) => element.difficulty == difficulty)
        .toList();
    filtered.shuffle();
    isAnswered.value = false;
    correctCount.value = 0;
    if (count > 0) {
      currentQuestions.value = filtered.take(count).toList();
    }
    update();
    Get.toNamed(
      RouteNames.quizScreen,
      arguments: selectedDifficulty.value.displayName,
    );
    Console.info('===== QUIZ STARTED =====');
  }

  //<============================ Is isAnswered ============================>

  void selectAnswer(index) {
    Console.info('===== USER GAVE ANSWER =====');
    currentQuestions[currentQuestionIndex.value].selectedIndex = index;
    currentQuestions.refresh();
    Console.info(
      "Answer: ${currentQuestions[currentQuestionIndex.value].options[index]}",
    );
    isAnswered.value = true;
  }

  //<=========================== DUMMY DATA ===========================>
  List<QuizModel> dummyQuiz = [
    QuizModel(
      id: 1,
      question: 'What is the primary purpose of scaffolding?',
      difficulty: QuizDifficulty.part1,
      options: [
        'To provide safe access and working platforms',
        'To replace ladders completely',
        'To support permanent structures',
        'To decorate a building',
      ],
      correctIndex: 0,
    ),
    QuizModel(
      id: 2,
      question:
          'Which component is used to support the vertical load of a scaffold?',
      difficulty: QuizDifficulty.part2,
      options: [
        'To support permanent structures',
        'Ledger',
        'Standard',
        'Toe board',
      ],
      correctIndex: 2,
    ),
    QuizModel(
      id: 3,
      question: 'What is the load capacity of a heavy-duty scaffold?',
      difficulty: QuizDifficulty.part1,
      options: ['300kg', '600kg', '500kg', '400kg'],
      correctIndex: 1,
    ),
    QuizModel(
      id: 4,
      question: 'What is the maximum height for a mobile scaffold?',
      difficulty: QuizDifficulty.part2,
      options: ['10m', '12m', '14m', '8m'],
      correctIndex: 1,
    ),
    QuizModel(
      id: 5,
      question: 'What is the load capacity of a heavy-duty scaffold?',
      difficulty: QuizDifficulty.advanced,
      options: ['300kg', '600kg', '500kg', '400kg'],
      correctIndex: 1,
    ),
  ];
}
