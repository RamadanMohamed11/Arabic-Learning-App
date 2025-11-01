/// Arabic letter names with proper diacritics for pronunciation
class LetterName {
  final String letter;
  final String name;
  final String nameWithDiacritics;

  const LetterName({
    required this.letter,
    required this.name,
    required this.nameWithDiacritics,
  });
}

/// Full list of Arabic letter names with diacritics
const List<LetterName> letterNames = [
  LetterName(letter: 'ا', name: 'ألف', nameWithDiacritics: 'أَلِف'),
  LetterName(letter: 'ب', name: 'باء', nameWithDiacritics: 'بَاء'),
  LetterName(letter: 'ت', name: 'تاء', nameWithDiacritics: 'تَاء'),
  LetterName(letter: 'ث', name: 'ثاء', nameWithDiacritics: 'ثَاء'),
  LetterName(letter: 'ج', name: 'جيم', nameWithDiacritics: 'جِيم'),
  LetterName(letter: 'ح', name: 'حاء', nameWithDiacritics: 'حَاء'),
  LetterName(letter: 'خ', name: 'خاء', nameWithDiacritics: 'خَاء'),
  LetterName(letter: 'د', name: 'دال', nameWithDiacritics: 'دَال'),
  LetterName(letter: 'ذ', name: 'ذال', nameWithDiacritics: 'ذَال'),
  LetterName(letter: 'ر', name: 'راء', nameWithDiacritics: 'رَاء'),
  LetterName(letter: 'ز', name: 'زاي', nameWithDiacritics: 'زَاي'),
  LetterName(letter: 'س', name: 'سين', nameWithDiacritics: 'سِين'),
  LetterName(letter: 'ش', name: 'شين', nameWithDiacritics: 'شِين'),
  LetterName(letter: 'ص', name: 'صاد', nameWithDiacritics: 'صَاد'),
  LetterName(letter: 'ض', name: 'ضاد', nameWithDiacritics: 'ضَاد'),
  LetterName(letter: 'ط', name: 'طاء', nameWithDiacritics: 'طَاء'),
  LetterName(letter: 'ظ', name: 'ظاء', nameWithDiacritics: 'ظَاء'),
  LetterName(letter: 'ع', name: 'عين', nameWithDiacritics: 'عَيْن'),
  LetterName(letter: 'غ', name: 'غين', nameWithDiacritics: 'غَيْن'),
  LetterName(letter: 'ف', name: 'فاء', nameWithDiacritics: 'فَاء'),
  LetterName(letter: 'ق', name: 'قاف', nameWithDiacritics: 'قَاف'),
  LetterName(letter: 'ك', name: 'كاف', nameWithDiacritics: 'كَاف'),
  LetterName(letter: 'ل', name: 'لام', nameWithDiacritics: 'لَام'),
  LetterName(letter: 'م', name: 'ميم', nameWithDiacritics: 'مِيم'),
  LetterName(letter: 'ن', name: 'نون', nameWithDiacritics: 'نُون'),
  LetterName(letter: 'ه', name: 'هاء', nameWithDiacritics: 'هَاء'),
  LetterName(letter: 'و', name: 'واو', nameWithDiacritics: 'وَاو'),
  LetterName(letter: 'ي', name: 'ياء', nameWithDiacritics: 'يَاء'),
];

/// Get letter name by letter
LetterName? getLetterName(String letter) {
  try {
    return letterNames.firstWhere((ln) => ln.letter == letter);
  } catch (e) {
    return null;
  }
}
