class WordModel {
  final String word;
  final String meaning;
  final String emoji;
  final String audioText; // Text for TTS

  const WordModel({
    required this.word,
    required this.meaning,
    required this.emoji,
    required this.audioText,
  });
}

// List of training words
const List<WordModel> trainingWords = [
  WordModel(
    word: 'بيت',
    meaning: 'House',
    emoji: '🏠',
    audioText: 'بيت',
  ),
  WordModel(
    word: 'قطة',
    meaning: 'Cat',
    emoji: '🐱',
    audioText: 'قطة',
  ),
  WordModel(
    word: 'كلب',
    meaning: 'Dog',
    emoji: '🐕',
    audioText: 'كلب',
  ),
  WordModel(
    word: 'شمس',
    meaning: 'Sun',
    emoji: '☀️',
    audioText: 'شمس',
  ),
  WordModel(
    word: 'قمر',
    meaning: 'Moon',
    emoji: '🌙',
    audioText: 'قمر',
  ),
  WordModel(
    word: 'ماء',
    meaning: 'Water',
    emoji: '💧',
    audioText: 'ماء',
  ),
  WordModel(
    word: 'نار',
    meaning: 'Fire',
    emoji: '🔥',
    audioText: 'نار',
  ),
  WordModel(
    word: 'شجرة',
    meaning: 'Tree',
    emoji: '🌳',
    audioText: 'شجرة',
  ),
  WordModel(
    word: 'وردة',
    meaning: 'Flower',
    emoji: '🌹',
    audioText: 'وردة',
  ),
  WordModel(
    word: 'كتاب',
    meaning: 'Book',
    emoji: '�책',
    audioText: 'كتاب',
  ),
  WordModel(
    word: 'قلم',
    meaning: 'Pen',
    emoji: '🖊️',
    audioText: 'قلم',
  ),
  WordModel(
    word: 'باب',
    meaning: 'Door',
    emoji: '🚪',
    audioText: 'باب',
  ),
  WordModel(
    word: 'سيارة',
    meaning: 'Car',
    emoji: '🚗',
    audioText: 'سيارة',
  ),
  WordModel(
    word: 'طائرة',
    meaning: 'Airplane',
    emoji: '✈️',
    audioText: 'طائرة',
  ),
  WordModel(
    word: 'سمكة',
    meaning: 'Fish',
    emoji: '🐟',
    audioText: 'سمكة',
  ),
  WordModel(
    word: 'تفاحة',
    meaning: 'Apple',
    emoji: '🍎',
    audioText: 'تفاحة',
  ),
  WordModel(
    word: 'موز',
    meaning: 'Banana',
    emoji: '🍌',
    audioText: 'موز',
  ),
  WordModel(
    word: 'حليب',
    meaning: 'Milk',
    emoji: '🥛',
    audioText: 'حليب',
  ),
  WordModel(
    word: 'خبز',
    meaning: 'Bread',
    emoji: '🍞',
    audioText: 'خبز',
  ),
  WordModel(
    word: 'عصير',
    meaning: 'Juice',
    emoji: '🧃',
    audioText: 'عصير',
  ),
];
