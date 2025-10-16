import 'package:flutter/services.dart';

/// نموذج لمسار حرف من SVG (مبسط)
class SimpleSvgLetterPath {
  final String letter;
  final String svgContent; // محتوى SVG الخام

  const SimpleSvgLetterPath({
    required this.letter,
    required this.svgContent,
  });
}

/// مدير مسارات الحروف من SVG (مبسط)
class SimpleSvgLetterPathManager {
  static final Map<String, SimpleSvgLetterPath> _cache = {};

  /// الحصول على مسار حرف (مع cache)
  static Future<SimpleSvgLetterPath?> getPath(String letter) async {
    // تحقق من الـ cache أولاً
    if (_cache.containsKey(letter)) {
      return _cache[letter];
    }

    try {
      // قراءة ملف SVG
      final svgString = await rootBundle.loadString('assets/svg/$letter.svg');
      
      final letterPath = SimpleSvgLetterPath(
        letter: letter,
        svgContent: svgString,
      );
      
      _cache[letter] = letterPath;
      return letterPath;
    } catch (e) {
      // ignore: avoid_print
      print('Could not load SVG for letter $letter: $e');
      return null;
    }
  }

  /// تحميل جميع الحروف مسبقاً
  static Future<void> preloadAllLetters() async {
    final letters = [
      'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ',
      'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص',
      'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق',
      'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي',
    ];

    for (final letter in letters) {
      try {
        await getPath(letter);
      } catch (e) {
        // ignore: avoid_print
        print('Failed to preload letter $letter: $e');
      }
    }
  }

  /// مسح الـ cache
  static void clearCache() {
    _cache.clear();
  }
}
