class WordMatchItem {
  final String word;
  final String imagePath;

  const WordMatchItem({required this.word, required this.imagePath});
}

/// Items for Activity 2: وصل الكلمة
/// Uses assets from assets/images
const List<WordMatchItem> wordMatchItems = [
  WordMatchItem(word: 'ضفدع', imagePath: 'assets/images/ضفدع.jpg'),
  WordMatchItem(word: 'موز', imagePath: 'assets/images/موز.jpg'),
  WordMatchItem(word: 'قلعة', imagePath: 'assets/images/قلعة.jpg'),
  WordMatchItem(word: 'دراجة', imagePath: 'assets/images/دراجة.jpg'),
  WordMatchItem(word: 'أسد', imagePath: 'assets/images/أسد.jpg'),
  WordMatchItem(word: 'بيتزا', imagePath: 'assets/images/بيتزا.jpg'),
  WordMatchItem(word: 'زهرة', imagePath: 'assets/images/زهرة.jpg'),
  WordMatchItem(word: 'بطريق', imagePath: 'assets/images/بطريق.jpg'),
  WordMatchItem(word: 'قارب', imagePath: 'assets/images/قارب.jpg'),
  WordMatchItem(word: 'بالون', imagePath: 'assets/images/بالون.jpg'),
  WordMatchItem(word: 'مشى', imagePath: 'assets/images/مشى.jpg'),
  WordMatchItem(word: 'نام', imagePath: 'assets/images/نام.jpg'),
  WordMatchItem(word: 'أكل', imagePath: 'assets/images/أكل.jpg'),
];
