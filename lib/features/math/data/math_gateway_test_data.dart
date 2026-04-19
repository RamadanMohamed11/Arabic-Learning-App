// ═══════════════════════════════════════════════════
// اختبار شامل بعد المستويات الأولى الثلاثة
// ═══════════════════════════════════════════════════

/// Question types for the gateway test
enum GatewayQuestionType {
  /// Count emojis and type the number
  countAndWrite,

  /// TTS speaks, user picks matching number
  audioChoice,

  /// Count multiple groups of emojis, type each count
  countGroups,

  /// Arrange numbers in ascending or descending order (drag)
  ordering,

  /// Standard multiple-choice
  multipleChoice,

  /// Fill in the missing number in a pattern/sequence
  numberPattern,
}

class GatewayQuestion {
  final String questionText;
  final GatewayQuestionType type;

  // ── countAndWrite ──
  /// The emoji string the user must count
  final String? emojiDisplay;
  /// The correct count
  final int? correctCount;

  // ── audioChoice ──
  /// The text to speak via TTS
  final String? audioText;
  /// The choices shown to the user
  final List<int>? audioChoices;
  /// The correct choice
  final int? audioCorrectAnswer;

  // ── countGroups ──
  /// List of emoji group strings, each a row
  final List<String>? emojiGroups;
  /// Correct count for each group
  final List<int>? groupCounts;

  // ── ordering ──
  /// The numbers to be ordered
  final List<int>? orderNumbers;
  /// The correct order
  final List<int>? correctOrder;
  /// Label: ascending or descending
  final String? orderLabel;

  // ── multipleChoice ──
  final List<String>? choices;
  final int? correctChoiceIndex; // 0-based

  // ── numberPattern ──
  /// Pattern display with __ for the blank (e.g. "١٠ ، ٢٠ ، ٣٠ ، __ ، ٥٠")
  final String? patternDisplay;
  /// Answer for the blank
  final int? patternAnswer;

  const GatewayQuestion({
    required this.questionText,
    required this.type,
    this.emojiDisplay,
    this.correctCount,
    this.audioText,
    this.audioChoices,
    this.audioCorrectAnswer,
    this.emojiGroups,
    this.groupCounts,
    this.orderNumbers,
    this.correctOrder,
    this.orderLabel,
    this.choices,
    this.correctChoiceIndex,
    this.patternDisplay,
    this.patternAnswer,
  });
}

const List<GatewayQuestion> kGatewayTestQuestions = [
  // ───────────── ١. عد + كتابة ─────────────
  GatewayQuestion(
    questionText: 'عُد واكتب الرقم',
    type: GatewayQuestionType.countAndWrite,
    emojiDisplay: '🍎🍎🍎🍎🍎',
    correctCount: 5,
  ),

  // ───────────── ٢. اختيار صوتي ─────────────
  GatewayQuestion(
    questionText: 'استمع واختر الرقم الصحيح',
    type: GatewayQuestionType.audioChoice,
    emojiDisplay: '⚽⚽⚽⚽⚽⚽⚽⚽',
    audioText: 'ثمانية',
    audioChoices: [7, 8, 9],
    audioCorrectAnswer: 8,
  ),

  // ───────────── ٣. عد مجموعات ─────────────
  GatewayQuestion(
    questionText: 'عُد كل مجموعة واكتب الرقم',
    type: GatewayQuestionType.countGroups,
    emojiGroups: [
      '🍎🍎🍎🍎',
      '🍎🍎🍎',
      '🍎🍎🍎🍎🍎🍎🍎',
    ],
    groupCounts: [4, 3, 7],
  ),

  // ───────────── ٤. ترتيب تصاعدي ─────────────
  GatewayQuestion(
    questionText: 'رتب الأرقام من الأصغر إلى الأكبر',
    type: GatewayQuestionType.ordering,
    orderNumbers: [8, 2, 5, 1],
    correctOrder: [1, 2, 5, 8],
    orderLabel: 'من الأصغر إلى الأكبر',
  ),

  // ───────────── ٥. اختيار منطقي صوتي ─────────────
  GatewayQuestion(
    questionText: 'أي رقم بين ٣ و ٥؟',
    type: GatewayQuestionType.audioChoice,
    audioText: 'أي رقم بين ثلاثة و خمسة',
    audioChoices: [2, 4, 6],
    audioCorrectAnswer: 4,
  ),

  // ───────────── ٦. اختيار صوتي ─────────────
  GatewayQuestion(
    questionText: 'استمع واختر الرقم الصحيح',
    type: GatewayQuestionType.audioChoice,
    audioText: 'ستون',
    audioChoices: [6, 60, 16],
    audioCorrectAnswer: 60,
  ),

  // ───────────── ٧. مقارنة ─────────────
  GatewayQuestion(
    questionText: 'أيهم أكبر؟',
    type: GatewayQuestionType.multipleChoice,
    choices: ['٢٠', '٨٠', '٤٠'],
    correctChoiceIndex: 1, // ٨٠
  ),

  // ───────────── ٨. نمط أعداد ─────────────
  GatewayQuestion(
    questionText: 'أكمل النمط',
    type: GatewayQuestionType.numberPattern,
    patternDisplay: '١٠  ،  ٢٠  ،  ٣٠  ،  __  ،  ٥٠',
    patternAnswer: 40,
  ),

  // ───────────── ٩. ترتيب تنازلي ─────────────
  GatewayQuestion(
    questionText: 'رتب الأرقام من الأكبر إلى الأصغر',
    type: GatewayQuestionType.ordering,
    orderNumbers: [70, 10, 50, 20],
    correctOrder: [70, 50, 20, 10],
    orderLabel: 'من الأكبر إلى الأصغر',
  ),

  // ───────────── ١٠. اختيار منطقي ─────────────
  GatewayQuestion(
    questionText: 'عدد أكبر من ٣٠ وأصغر من ٥٠',
    type: GatewayQuestionType.multipleChoice,
    choices: ['٢٠', '٤٠', '٦٠'],
    correctChoiceIndex: 1, // ٤٠
  ),

  // ───────────── ١١. تحليل العدد ─────────────
  GatewayQuestion(
    questionText: '٦٣ = ؟',
    type: GatewayQuestionType.multipleChoice,
    choices: ['٦٠ + ٣', '٥٠ + ١٣', '٣٠ + ٣٣'],
    correctChoiceIndex: 0,
  ),

  // ───────────── ١٢. عشرات + آحاد ─────────────
  GatewayQuestion(
    questionText: '٤ عشرات + ٥ آحاد = ؟',
    type: GatewayQuestionType.multipleChoice,
    choices: ['٤٥', '٥٣', '٣٣'],
    correctChoiceIndex: 0,
  ),

  // ───────────── ١٣. مقارنة ─────────────
  GatewayQuestion(
    questionText: 'أيهم أكبر؟',
    type: GatewayQuestionType.multipleChoice,
    choices: ['٢٧', '٧٢', '٤٥'],
    correctChoiceIndex: 1,
  ),

  // ───────────── ١٤. ترتيب تصاعدي ─────────────
  GatewayQuestion(
    questionText: 'رتب الأرقام من الأصغر إلى الأكبر',
    type: GatewayQuestionType.ordering,
    orderNumbers: [31, 14, 22, 40],
    correctOrder: [14, 22, 31, 40],
    orderLabel: 'من الأصغر إلى الأكبر',
  ),

  // ───────────── ١٥. عشرات + آحاد ─────────────
  GatewayQuestion(
    questionText: '٣ عشرات + ٥ آحاد = ؟',
    type: GatewayQuestionType.multipleChoice,
    choices: ['٥٣', '٣٥', '٣٣'],
    correctChoiceIndex: 1,
  ),
];

const double kGatewayTestPassThreshold = 0.60; // 60% to pass
