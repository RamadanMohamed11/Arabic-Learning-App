/// Model for word spelling activity
/// Student arranges scattered letters to form the correct word
class WordSpellingQuestion {
  final String word;
  final String emoji;
  final String meaning;
  final List<String> letters;

  WordSpellingQuestion({
    required this.word,
    required this.emoji,
    required this.meaning,
    required this.letters,
  });
}

/// All word spelling questions for Level 2
final List<WordSpellingQuestion> wordSpellingQuestions = [
  // 2-letter words
  WordSpellingQuestion(
    word: 'أب',
    emoji: '👨',
    meaning: 'Father',
    letters: ['أ', 'ب'],
  ),
  WordSpellingQuestion(
    word: 'أم',
    emoji: '👩',
    meaning: 'Mother',
    letters: ['أ', 'م'],
  ),
  WordSpellingQuestion(
    word: 'أخ',
    emoji: '👦',
    meaning: 'Brother',
    letters: ['أ', 'خ'],
  ),

  // 3-letter words
  WordSpellingQuestion(
    word: 'أخت',
    emoji: '👧',
    meaning: 'Sister',
    letters: ['أ', 'خ', 'ت'],
  ),
  WordSpellingQuestion(
    word: 'بيت',
    emoji: '🏠',
    meaning: 'House',
    letters: ['ب', 'ي', 'ت'],
  ),
  WordSpellingQuestion(
    word: 'شمس',
    emoji: '☀️',
    meaning: 'Sun',
    letters: ['ش', 'م', 'س'],
  ),
  WordSpellingQuestion(
    word: 'قلم',
    emoji: '🖊️',
    meaning: 'Pen',
    letters: ['ق', 'ل', 'م'],
  ),
  WordSpellingQuestion(
    word: 'كتب',
    emoji: '📚',
    meaning: 'Books',
    letters: ['ك', 'ت', 'ب'],
  ),
  WordSpellingQuestion(
    word: 'قرأ',
    emoji: '📖',
    meaning: 'Read',
    letters: ['ق', 'ر', 'أ'],
  ),
  WordSpellingQuestion(
    word: 'لعب',
    emoji: '⚽',
    meaning: 'Play',
    letters: ['ل', 'ع', 'ب'],
  ),

  // 4-letter words
  WordSpellingQuestion(
    word: 'قطة',
    emoji: '🐱',
    meaning: 'Cat',
    letters: ['ق', 'ط', 'ة'],
  ),

  // 5-letter words
  WordSpellingQuestion(
    word: 'تفاحة',
    emoji: '🍎',
    meaning: 'Apple',
    letters: ['ت', 'ف', 'ا', 'ح', 'ة'],
  ),
  WordSpellingQuestion(
    word: 'سيارة',
    emoji: '🚗',
    meaning: 'Car',
    letters: ['س', 'ي', 'ا', 'ر', 'ة'],
  ),
];
