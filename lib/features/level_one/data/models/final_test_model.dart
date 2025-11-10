enum QuestionType { imageToCharacter, pronunciation, listenAndWrite }

class FinalTestQuestion {
  final QuestionType type;
  final String? emoji;
  final String correctAnswer;
  final List<String> options;

  FinalTestQuestion({
    required this.type,
    this.emoji,
    required this.correctAnswer,
    required this.options,
  });
}

/// All questions for the final level one test
final List<FinalTestQuestion> finalLevelOneQuestions = [
  // Part 1: Image to Character Recognition (5 questions)
  FinalTestQuestion(
    type: QuestionType.imageToCharacter,
    emoji: '🐱',
    correctAnswer: 'ق',
    options: ['ب', 'ق', 'ن', 'م'],
  ),
  FinalTestQuestion(
    type: QuestionType.imageToCharacter,
    emoji: '🍞',
    correctAnswer: 'خ',
    options: ['خ', 'ب', 'د', 'ح'],
  ),
  FinalTestQuestion(
    type: QuestionType.imageToCharacter,
    emoji: '🐟',
    correctAnswer: 'س',
    options: ['س', 'ف', 'م', 'ش'],
  ),
  FinalTestQuestion(
    type: QuestionType.imageToCharacter,
    emoji: '☀',
    correctAnswer: 'ش',
    options: ['ش', 'ض', 'ط', 'س'],
  ),
  FinalTestQuestion(
    type: QuestionType.imageToCharacter,
    emoji: '🍌',
    correctAnswer: 'م',
    options: ['ك', 'ل', 'م', 'ن'],
  ),

  // Part 2: Character Pronunciation (5 questions)
  FinalTestQuestion(
    type: QuestionType.pronunciation,
    correctAnswer: 'ب',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.pronunciation,
    correctAnswer: 'ت',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.pronunciation,
    correctAnswer: 'ر',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.pronunciation,
    correctAnswer: 'س',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.pronunciation,
    correctAnswer: 'ل',
    options: [],
  ),

  // Part 3: Listen and Write (5 questions)
  FinalTestQuestion(
    type: QuestionType.listenAndWrite,
    correctAnswer: 'ص',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.listenAndWrite,
    correctAnswer: 'ف',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.listenAndWrite,
    correctAnswer: 'ك',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.listenAndWrite,
    correctAnswer: 'ن',
    options: [],
  ),
  FinalTestQuestion(
    type: QuestionType.listenAndWrite,
    correctAnswer: 'ع',
    options: [],
  ),
];
