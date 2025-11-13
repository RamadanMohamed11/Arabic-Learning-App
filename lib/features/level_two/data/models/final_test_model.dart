class FinalWordQuestion {
  final String prompt; // e.g., emoji or short label of the image
  final List<String> options; // 3 options
  final int correctIndex; // index into options

  const FinalWordQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
}

class FinalReadQuestion {
  final String text; // sentence/word to read

  const FinalReadQuestion({
    required this.text,
  });
}

class FinalDictationQuestion {
  final String text; // sentence/word to dictate

  const FinalDictationQuestion({
    required this.text,
  });
}

// Section A: اختر الكلمة الصحيحة للصورة (5 أسئلة)
// Note: Adjusted prompts/emojis to match the intended correct answers logically.
const List<FinalWordQuestion> finalAQuestions = [
  FinalWordQuestion(
    prompt: '🍇',
    options: ['تفاحة', 'خيارة', 'عنب'],
    correctIndex: 2,
  ),
  FinalWordQuestion(
    prompt: '🐫',
    options: ['جمل', 'حصان', 'بطة'],
    correctIndex: 0,
  ),
  FinalWordQuestion(
    prompt: '🏠',
    options: ['بيت', 'شجرة', 'بحر'],
    correctIndex: 0,
  ),
  FinalWordQuestion(
    prompt: '🏞️',
    options: ['كتاب جديد', 'تفاحة حمراء', 'حديقة جميلة'],
    correctIndex: 2,
  ),
  FinalWordQuestion(
    prompt: '🌕',
    options: ['قمر', 'شمس', 'نجمة'],
    correctIndex: 0,
  ),
];

// Section B: اقرأ الجملة والكلمات (5 أسئلة)
const List<FinalReadQuestion> finalBQuestions = [
  FinalReadQuestion(text: 'شجرة'),
  FinalReadQuestion(text: 'شجرة عالية'),
  FinalReadQuestion(text: 'باب'),
  FinalReadQuestion(text: 'كتاب جديد'),
  FinalReadQuestion(text: 'نهر'),
];

// Section C: اسمع ثم اكتب (5 أسئلة)
const List<FinalDictationQuestion> finalCQuestions = [
  FinalDictationQuestion(text: 'قِطَّة'),
  FinalDictationQuestion(text: 'طِفْلٌ يَلْعَبُ'),
  FinalDictationQuestion(text: 'شَجَرَةٌ'),
  FinalDictationQuestion(text: 'سَمَكَةٌ'),
  FinalDictationQuestion(text: 'بَيْتٌ جَمِيلٌ'),
];
