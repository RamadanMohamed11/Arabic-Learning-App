/// ═══════════════════════════════════════════════════
/// HALF 1: أساسيات الجمع (Single-digit Addition)
/// ═══════════════════════════════════════════════════

/// Introduction text (displayed before activities)
const String kAdditionIntroText = '''
الجمع هو عملية رياضية نستخدمها لإيجاد مجموع عددين أو أكثر.
على سبيل المثال، إذا كان لديك ٢ تفاحة ومعهم ٣ تفاحات إضافية، فإن المجموع يكون ٥.
مثال آخر، إذا كنت تمتلك ١٠ جنيه ومعهم ٢٠ جنيه إضافيين، يصبح المجموع ٣٠.
في الحياة اليومية، نستخدم الجمع في أشياء مثل حساب النقود، جمع عدد الفواكه، أو حتى في الحسابات اليومية.
''';

const String kAdditionVideoUrl = 'kAZkdG08EPU'; // Just the video ID for youtube_player_flutter

/// Activity 1 — عد الفواكه (Fruit Counting)
class FruitAdditionRound {
  final String emoji;
  final int leftCount;
  final int rightCount;
  final int answer; 

  const FruitAdditionRound({
    required this.emoji,
    required this.leftCount,
    required this.rightCount,
    required this.answer,
  });
}

const List<FruitAdditionRound> kFruitAdditionRounds = [
  FruitAdditionRound(emoji: '🍊', leftCount: 3, rightCount: 1, answer: 4),
  FruitAdditionRound(emoji: '🍇', leftCount: 1, rightCount: 1, answer: 2),
  FruitAdditionRound(emoji: '🥭', leftCount: 2, rightCount: 3, answer: 5),
  FruitAdditionRound(emoji: '🍋', leftCount: 6, rightCount: 4, answer: 10),
  FruitAdditionRound(emoji: '🌶️', leftCount: 4, rightCount: 4, answer: 8),
  FruitAdditionRound(emoji: '🍍', leftCount: 5, rightCount: 1, answer: 6),
];

/// Activity 2 — جمع مباشر (Direct Addition, single-digit)
const List<Map<String, int>> kDirectAdditionH1 = [
  {'a': 1, 'b': 2, 'answer': 3},
  {'a': 2, 'b': 3, 'answer': 5},
  {'a': 3, 'b': 1, 'answer': 4},
  {'a': 6, 'b': 3, 'answer': 9},
  {'a': 4, 'b': 3, 'answer': 7},
  {'a': 6, 'b': 4, 'answer': 10},
  {'a': 5, 'b': 5, 'answer': 10},
  {'a': 1, 'b': 0, 'answer': 1},
  {'a': 2, 'b': 5, 'answer': 7},
];

/// Activity 3 — خط الأعداد (Number Line)
class NumberLineRound {
  final int start;
  final int move;
  final int answer; 

  const NumberLineRound({
    required this.start,
    required this.move,
    required this.answer,
  });
}

const List<NumberLineRound> kNumberLineRounds = [
  NumberLineRound(start: 1, move: 1, answer: 2),
  NumberLineRound(start: 5, move: 2, answer: 7),
  NumberLineRound(start: 2, move: 2, answer: 4),
  NumberLineRound(start: 0, move: 3, answer: 3),
  NumberLineRound(start: 3, move: 5, answer: 8),
  NumberLineRound(start: 2, move: 3, answer: 5),
  NumberLineRound(start: 4, move: 2, answer: 6),
  NumberLineRound(start: 0, move: 1, answer: 1),
  NumberLineRound(start: 5, move: 4, answer: 9),
  NumberLineRound(start: 4, move: 6, answer: 10),
];

/// ═══════════════════════════════════════════════════
/// HALF 2: جمع الأعداد الكبيرة (Multi-digit Addition)
/// ═══════════════════════════════════════════════════

const String kPlaceValueScriptText = '''
بعد أن تعلمت الجمع على خط الأعداد، يمكنك الآن تطبيقه على الأعداد الأكبر التي تتكوّن من آحاد وعشرات ومئات.
أي رقم مكوّن من رقمين أو ثلاثة يمكن تقسيمه إلى:
مئات
عشرات
آحاد

عند جمع عددين أو أكثر، نبدأ أولًا بجمع الآحاد، ثم نجمع العشرات، ثم المئات، ثم نضيف النواتج معًا للحصول على الإجابة النهائية.

مثال: ١٢ + ٥
ننظر إلى العدد ١٢: فيه عشرة واحدة و ٢ آحاد.
نبدأ بجمع الآحاد: ٢ + ٥ = ٧
ثم نضيف العشرة: ١٠ + ٧ = ١٧
إذن الناتج هو ١٧.

مثال آخر: ٢٣ + ١٤٠
نبدأ بالآحاد: ٣ + ٠ = ٣
ثم العشرات: ٢٠ + ٤٠ = ٦٠
ثم المئات: ٠ + ١٠٠ = ١٠٠
ثم نجمع النواتج: ٣ + ٦٠ + ١٠٠ = ١٦٣
إذن الناتج هو ١٦٣.

تذكّر دائمًا أن فهم قيمة كل رقم (آحاد وعشرات ومئات) يساعدك على حل مسائل الجمع بسهولة ودقة.
''';

/// Activity 1 — Direct multi-digit addition
const List<Map<String, int>> kDirectAdditionH2 = [
  {'a': 12, 'b': 15, 'answer': 27},
  {'a': 23, 'b': 14, 'answer': 37},
  {'a': 35, 'b': 22, 'answer': 57},
  {'a': 41, 'b': 19, 'answer': 60},
  {'a': 56, 'b': 13, 'answer': 69},
  {'a': 67, 'b': 21, 'answer': 88},
  {'a': 78, 'b': 11, 'answer': 89},
  {'a': 89, 'b': 10, 'answer': 99},
  {'a': 90, 'b': 5, 'answer': 95},
  {'a': 20, 'b': 34, 'answer': 54},
  {'a': 30, 'b': 25, 'answer': 55},
  {'a': 40, 'b': 36, 'answer': 76},
  {'a': 50, 'b': 42, 'answer': 92},
  {'a': 60, 'b': 18, 'answer': 78},
  {'a': 70, 'b': 29, 'answer': 99},
  {'a': 80, 'b': 14, 'answer': 94},
  {'a': 90, 'b': 23, 'answer': 113},
];

/// Activity 2 — Match operation to answer (وصّل)
class MatchingPair {
  final int a;
  final int b;
  final int answer;
  const MatchingPair(this.a, this.b, this.answer);
}

const List<MatchingPair> kMatchingPairs = [
  MatchingPair(12, 8, 20),
  MatchingPair(23, 15, 38),
  MatchingPair(34, 26, 60),
  MatchingPair(25, 18, 43),
  MatchingPair(30, 12, 42),
  MatchingPair(31, 14, 45),
  MatchingPair(32, 16, 48),
  MatchingPair(45, 15, 60),
  MatchingPair(50, 25, 75),
  MatchingPair(120, 30, 150),
  MatchingPair(130, 40, 170),
  MatchingPair(140, 50, 190),
  MatchingPair(150, 60, 210),
  MatchingPair(160, 70, 230),
  MatchingPair(14, 5, 19),
  MatchingPair(15, 2, 17),
  MatchingPair(16, 3, 19),
  MatchingPair(17, 1, 18),
  MatchingPair(170, 80, 250),
  MatchingPair(180, 90, 270),
];

/// Activity 3 — Word problems (مسائل حياتية)
class WordProblem {
  final String text;
  final int answer;
  final String icon;

  const WordProblem({
    required this.text,
    required this.answer,
    required this.icon,
  });
}

const List<WordProblem> kWordProblems = [
  WordProblem(text: 'معك ٢٥ جنيه وأخذت ٣٥ جنيه → كم معك؟', answer: 60, icon: '💰'),
  WordProblem(text: 'لديك ٤٠ كتاب وأضيف ٣٢ → كم أصبحوا؟', answer: 72, icon: '📚'),
  WordProblem(text: 'في الصندوق ٦٠ كرة وأضفنا ٢٥ → كم الآن؟', answer: 85, icon: '⚽'),
  WordProblem(text: 'معك ٧٥ قلم وأعطاك أحد ١٤ → كم لديك؟', answer: 89, icon: '✏️'),
  WordProblem(text: 'في الفصل ٨٠ طالب ودخل ١٩ → كم الآن؟', answer: 99, icon: '🎓'),
  WordProblem(text: 'معك ٣٠ جنيه وأضفت ٤٥ جنيه → كم المجموع؟', answer: 75, icon: '💰'),
];

/// Activity 4 — Speed Challenge (تحدي السرعة)
const List<Map<String, int>> kSpeedChallengeQuestions = [
  {'a': 12, 'b': 3, 'answer': 15},
  {'a': 25, 'b': 14, 'answer': 39},
  {'a': 34, 'b': 5, 'answer': 39},
  {'a': 40, 'b': 23, 'answer': 63},
  {'a': 17, 'b': 2, 'answer': 19},
  {'a': 56, 'b': 34, 'answer': 90},
  {'a': 63, 'b': 18, 'answer': 81},
  {'a': 70, 'b': 25, 'answer': 95},
  {'a': 89, 'b': 11, 'answer': 100},
  {'a': 32, 'b': 48, 'answer': 80},
  {'a': 15, 'b': 27, 'answer': 42},
  {'a': 60, 'b': 19, 'answer': 79},
  {'a': 44, 'b': 36, 'answer': 80},
  {'a': 23, 'b': 57, 'answer': 80},
  {'a': 18, 'b': 42, 'answer': 60},
];

const int kSpeedChallengeDurationSeconds = 300; // 5 minutes
const double kSpeedChallengePassThreshold = 0.80; // 80%
