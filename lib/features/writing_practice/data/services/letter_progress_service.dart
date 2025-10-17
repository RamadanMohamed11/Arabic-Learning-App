import 'package:shared_preferences/shared_preferences.dart';

class LetterProgressService {
  static const String _keyPrefix = 'letter_completed_';
  static const String _keyUnlockedLetters = 'unlocked_letters_count';

  // Save that a letter has been completed
  Future<void> markLetterCompleted(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$letter', true);
    
    // Update unlocked letters count
    final currentUnlocked = await getUnlockedLettersCount();
    final letterIndex = _getLetterIndex(letter);
    if (letterIndex >= currentUnlocked) {
      await prefs.setInt(_keyUnlockedLetters, letterIndex + 1);
    }
  }

  // Check if a letter has been completed
  Future<bool> isLetterCompleted(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$letter') ?? false;
  }

  // Get the count of unlocked letters (letters that can be practiced)
  Future<int> getUnlockedLettersCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUnlockedLetters) ?? 1; // At least the first letter is unlocked
  }

  // Check if a letter is unlocked (can be practiced)
  Future<bool> isLetterUnlocked(String letter) async {
    final unlockedCount = await getUnlockedLettersCount();
    final letterIndex = _getLetterIndex(letter);
    return letterIndex < unlockedCount;
  }

  // Get letter index from the Arabic alphabet
  int _getLetterIndex(String letter) {
    const arabicLetters = [
      'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
      'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
      'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي'
    ];
    return arabicLetters.indexOf(letter);
  }

  // Reset all progress (for testing or reset functionality)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix) || key == _keyUnlockedLetters) {
        await prefs.remove(key);
      }
    }
  }

  // Get completion percentage
  Future<double> getCompletionPercentage() async {
    const totalLetters = 28;
    int completedCount = 0;
    
    const arabicLetters = [
      'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
      'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
      'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي'
    ];
    
    for (final letter in arabicLetters) {
      if (await isLetterCompleted(letter)) {
        completedCount++;
      }
    }
    
    return (completedCount / totalLetters) * 100;
  }
}
