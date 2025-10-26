class RevisionQuestion {
  final String correctAnswer;
  final List<String> options;

  RevisionQuestion({
    required this.correctAnswer,
    required this.options,
  });
}

class RevisionTestGroup {
  final int groupNumber;
  final String title;
  final String emoji;
  final List<String> letters;
  final List<RevisionQuestion> questions;

  RevisionTestGroup({
    required this.groupNumber,
    required this.title,
    required this.emoji,
    required this.letters,
    required this.questions,
  });
}

// بيانات اختبارات المراجعة لكل مجموعة (كل 4 حروف)
final List<RevisionTestGroup> revisionTestGroups = [
  // 🟩 المجموعة 1 (أ، ب، ت، ث)
  RevisionTestGroup(
    groupNumber: 1,
    title: 'المجموعة 1',
    emoji: '🟩',
    letters: ['أ', 'ب', 'ت', 'ث'],
    questions: [
      RevisionQuestion(
        correctAnswer: 'أ',
        options: ['ب', 'ث', 'أ', 'ت'],
      ),
      RevisionQuestion(
        correctAnswer: 'ب',
        options: ['ت', 'أ', 'ب', 'ث'],
      ),
      RevisionQuestion(
        correctAnswer: 'ت',
        options: ['ث', 'ب', 'أ', 'ت'],
      ),
      RevisionQuestion(
        correctAnswer: 'ث',
        options: ['ت', 'أ', 'ث', 'ب'],
      ),
    ],
  ),

  // 🟦 المجموعة 2 (ج، ح، خ، د)
  RevisionTestGroup(
    groupNumber: 2,
    title: 'المجموعة 2',
    emoji: '🟦',
    letters: ['ج', 'ح', 'خ', 'د'],
    questions: [
      RevisionQuestion(
        correctAnswer: 'ج',
        options: ['ج', 'ب', 'خ', 'أ'],
      ),
      RevisionQuestion(
        correctAnswer: 'ح',
        options: ['ح', 'ت', 'د', 'ث'],
      ),
      RevisionQuestion(
        correctAnswer: 'خ',
        options: ['ب', 'خ', 'ج', 'ت'],
      ),
      RevisionQuestion(
        correctAnswer: 'د',
        options: ['د', 'أ', 'ب', 'ج'],
      ),
    ],
  ),

  // 🟨 المجموعة 3 (ذ، ر، ز، س)
  RevisionTestGroup(
    groupNumber: 3,
    title: 'المجموعة 3',
    emoji: '🟨',
    letters: ['ذ', 'ر', 'ز', 'س'],
    questions: [
      RevisionQuestion(
        correctAnswer: 'ذ',
        options: ['ذ', 'د', 'ب', 'ت'],
      ),
      RevisionQuestion(
        correctAnswer: 'ر',
        options: ['ر', 'ب', 'أ', 'ذ'],
      ),
      RevisionQuestion(
        correctAnswer: 'ز',
        options: ['ث', 'ر', 'ز', 'أ'],
      ),
      RevisionQuestion(
        correctAnswer: 'س',
        options: ['س', 'خ', 'ر', 'ب'],
      ),
    ],
  ),

  // 🟧 المجموعة 4 (ش، ص، ض، ط)
  RevisionTestGroup(
    groupNumber: 4,
    title: 'المجموعة 4',
    emoji: '🟧',
    letters: ['ش', 'ص', 'ض', 'ط'],
    questions: [
      RevisionQuestion(
        correctAnswer: 'ش',
        options: ['ش', 'ص', 'ب', 'س'],
      ),
      RevisionQuestion(
        correctAnswer: 'ص',
        options: ['ص', 'ط', 'أ', 'ذ'],
      ),
      RevisionQuestion(
        correctAnswer: 'ض',
        options: ['ض', 'ر', 'ط', 'خ'],
      ),
      RevisionQuestion(
        correctAnswer: 'ط',
        options: ['ط', 'ث', 'ض', 'ش'],
      ),
    ],
  ),

  // 🟪 المجموعة 5 (ظ، ع، غ، ف)
  RevisionTestGroup(
    groupNumber: 5,
    title: 'المجموعة 5',
    emoji: '🟪',
    letters: ['ظ', 'ع', 'غ', 'ف'],
    questions: [
      RevisionQuestion(
        correctAnswer: 'ظ',
        options: ['ظ', 'ط', 'غ', 'ب'],
      ),
      RevisionQuestion(
        correctAnswer: 'ع',
        options: ['ع', 'ص', 'غ', 'د'],
      ),
      RevisionQuestion(
        correctAnswer: 'غ',
        options: ['غ', 'ع', 'ت', 'ز'],
      ),
      RevisionQuestion(
        correctAnswer: 'ف',
        options: ['ف', 'خ', 'ع', 'ش'],
      ),
    ],
  ),

  // 🟥 المجموعة 6 (ق، ك، ل، م)
  RevisionTestGroup(
    groupNumber: 6,
    title: 'المجموعة 6',
    emoji: '🟥',
    letters: ['ق', 'ك', 'ل', 'م'],
    questions: [
      RevisionQuestion(
        correctAnswer: 'ق',
        options: ['ق', 'ف', 'ك', 'ب'],
      ),
      RevisionQuestion(
        correctAnswer: 'ك',
        options: ['ك', 'ل', 'أ', 'ط'],
      ),
      RevisionQuestion(
        correctAnswer: 'ل',
        options: ['ل', 'ق', 'م', 'ص'],
      ),
      RevisionQuestion(
        correctAnswer: 'م',
        options: ['م', 'ك', 'ر', 'خ'],
      ),
    ],
  ),

  // 🟫 المجموعة 7 (ن، هـ، و، ي)
  RevisionTestGroup(
    groupNumber: 7,
    title: 'المجموعة 7',
    emoji: '🟫',
    letters: ['ن', 'هـ', 'و', 'ي'],
    questions: [
      RevisionQuestion(
        correctAnswer: 'ن',
        options: ['ن', 'م', 'هـ', 'ب'],
      ),
      RevisionQuestion(
        correctAnswer: 'هـ',
        options: ['هـ', 'ن', 'و', 'ك'],
      ),
      RevisionQuestion(
        correctAnswer: 'و',
        options: ['و', 'ي', 'ك', 'ف'],
      ),
      RevisionQuestion(
        correctAnswer: 'ي',
        options: ['ي', 'هـ', 'م', 'ز'],
      ),
    ],
  ),
];
