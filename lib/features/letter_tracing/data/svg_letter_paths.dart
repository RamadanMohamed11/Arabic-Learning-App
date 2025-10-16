import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:path_parsing/path_parsing.dart';

/// نموذج لمسار حرف من SVG
class SvgLetterPath {
  final String letter;
  final List<Path> paths; // المسارات من SVG

  const SvgLetterPath({
    required this.letter,
    required this.paths,
  });
}

/// محول SVG إلى Flutter Paths
class SvgPathConverter {
  /// تحويل SVG path string إلى Flutter Path
  static Path parseSvgPath(String pathData) {
    final path = Path();
    final pathProxy = _PathProxy(path);
    writeSvgPathDataToPath(pathData, pathProxy);
    return path;
  }

  /// قراءة ملف SVG وتحويله إلى paths
  static Future<SvgLetterPath> loadLetterFromSvg(String letter) async {
    try {
      // قراءة ملف SVG
      final svgString = await rootBundle.loadString('assets/svg/$letter.svg');
      
      // ignore: avoid_print
      print('Loaded SVG for letter $letter, length: ${svgString.length}');
      
      // تحليل XML
      final document = XmlDocument.parse(svgString);
      
      // استخراج جميع عناصر path
      final pathElements = document.findAllElements('path');
      
      // ignore: avoid_print
      print('Found ${pathElements.length} paths in SVG');
      
      // تحويل كل path إلى Flutter Path
      final paths = <Path>[];
      for (final pathElement in pathElements) {
        final pathData = pathElement.getAttribute('d');
        if (pathData != null && pathData.isNotEmpty) {
          try {
            final path = parseSvgPath(pathData);
            paths.add(path);
            // ignore: avoid_print
            print('Successfully parsed path ${paths.length}');
          } catch (e) {
            // ignore: avoid_print
            print('Error parsing path: $e');
          }
        }
      }
      
      // ignore: avoid_print
      print('Total paths created: ${paths.length}');
      
      return SvgLetterPath(
        letter: letter,
        paths: paths,
      );
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('Error loading SVG for letter $letter: $e');
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

/// Proxy لتحويل SVG path إلى Flutter Path
class _PathProxy implements PathProxy {
  final Path path;

  _PathProxy(this.path);

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }
}

/// مدير مسارات الحروف من SVG
class SvgLetterPathManager {
  static final Map<String, SvgLetterPath> _cache = {};

  /// الحصول على مسار حرف (مع cache)
  static Future<SvgLetterPath?> getPath(String letter) async {
    // تحقق من الـ cache أولاً
    if (_cache.containsKey(letter)) {
      return _cache[letter];
    }

    try {
      // حمل من SVG
      final letterPath = await SvgPathConverter.loadLetterFromSvg(letter);
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
