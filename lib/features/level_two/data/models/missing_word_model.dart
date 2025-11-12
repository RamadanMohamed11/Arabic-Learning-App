class MissingWordQuestion {
  final String puzzle; // e.g. كـ_ب
  final String answer; // e.g. كتب
  final String imagePath; // assets/images/...jpg
  final String missingLetter; // e.g. ت
  final List<String> options; // letter choices containing the correct one

  const MissingWordQuestion({
    required this.puzzle,
    required this.answer,
    required this.imagePath,
    required this.missingLetter,
    required this.options,
  });
}

// Activity 3 questions (using available assets)
const List<MissingWordQuestion> missingWordQuestions = [
  MissingWordQuestion(
    puzzle: 'كـ_ب',
    answer: 'كتب',
    imagePath: 'assets/images/كتب.jpg',
    missingLetter: 'ت',
    options: ['ت', 'ث', 'ط', 'د'],
  ),
  MissingWordQuestion(
    puzzle: 'خـ_ز',
    answer: 'خبز',
    imagePath: 'assets/images/خبز.jpg',
    missingLetter: 'ب',
    options: ['ب', 'م', 'ن', 'ف'],
  ),
  MissingWordQuestion(
    puzzle: 'قـ_م',
    answer: 'قلم',
    imagePath: 'assets/images/قلم.jpg',
    missingLetter: 'ل',
    options: ['ل', 'ر', 'ن', 'م'],
  ),
  MissingWordQuestion(
    puzzle: 'و_د',
    answer: 'ورد',
    imagePath: 'assets/images/ورد.jpg',
    missingLetter: 'ر',
    options: ['ر', 'ز', 'ذ', 'د'],
  ),
  MissingWordQuestion(
    puzzle: 'طـ_ر',
    answer: 'طير',
    imagePath: 'assets/images/طير.jpg',
    missingLetter: 'ي',
    options: ['ي', 'و', 'ا', 'ن'],
  ),
  MissingWordQuestion(
    puzzle: 'مـدر_ة',
    answer: 'مدرسة',
    imagePath: 'assets/images/مدرسة.jpg',
    missingLetter: 'س',
    options: ['س', 'ش', 'ص', 'ز'],
  ),
  MissingWordQuestion(
    puzzle: 'كـر_ي',
    answer: 'كرسي',
    imagePath: 'assets/images/كرسي.jpg',
    missingLetter: 'س',
    options: ['س', 'ش', 'ص', 'ز'],
  ),
  MissingWordQuestion(
    puzzle: 'جـ_ل',
    answer: 'جبل',
    imagePath: 'assets/images/جبل.jpg',
    missingLetter: 'ب',
    options: ['ب', 'م', 'ن', 'ف'],
  ),
  MissingWordQuestion(
    puzzle: 'فـ_ل',
    answer: 'فيل',
    imagePath: 'assets/images/فيل.jpg',
    missingLetter: 'ي',
    options: ['ي', 'و', 'ا', 'ن'],
  ),
  MissingWordQuestion(
    puzzle: 'درا_ة',
    answer: 'دراجة',
    imagePath: 'assets/images/دراجة.jpg',
    missingLetter: 'ج',
    options: ['ج', 'ح', 'خ', 'غ'],
  ),
  MissingWordQuestion(
    puzzle: 'يـج_س',
    answer: 'يجلس',
    imagePath: 'assets/images/يجلس.jpg',
    missingLetter: 'ل',
    options: ['ل', 'ر', 'ن', 'م'],
  ),
  MissingWordQuestion(
    puzzle: 'يـر_م',
    answer: 'يَرْسُمُ',
    imagePath: 'assets/images/يرسم.jpg',
    missingLetter: 'س',
    options: ['س', 'ش', 'ص', 'ز'],
  ),
  MissingWordQuestion(
    puzzle: 'يـف_ح',
    answer: 'يَفْتَحُ',
    imagePath: 'assets/images/يفتح.jpg',
    missingLetter: 'ت',
    options: ['ت', 'ث', 'ط', 'د'],
  ),
];
