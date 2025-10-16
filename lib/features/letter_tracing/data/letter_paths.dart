import 'package:flutter/material.dart';

/// بيانات مسارات الحروف العربية للتتبع
class LetterPath {
  final String letter;
  final List<List<Offset>> strokes; // كل حرف قد يحتوي على أكثر من stroke
  final List<Offset>? dots; // النقاط (للحروف مثل ب، ت، ث)

  const LetterPath({
    required this.letter,
    required this.strokes,
    this.dots,
  });
}

/// مسارات جميع الحروف العربية
class ArabicLetterPaths {
  static final Map<String, LetterPath> paths = {
    // ا - ألف
    'ا': LetterPath(
      letter: 'ا',
      strokes: [
        [
          const Offset(160, 80),
          const Offset(160, 250),
        ],
      ],
    ),

    // ب - باء
    'ب': LetterPath(
      letter: 'ب',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(250, 100),
          const Offset(240, 150),
          const Offset(220, 180),
          const Offset(180, 200),
          const Offset(140, 200),
          const Offset(100, 190),
          const Offset(80, 160),
          const Offset(70, 120),
          const Offset(70, 100),
        ],
        // النقطة (كـ stroke منفصل)
        [
          const Offset(160, 230),
        ],
      ],
    ),

    // ت - تاء
    'ت': LetterPath(
      letter: 'ت',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(250, 100),
          const Offset(240, 150),
          const Offset(220, 180),
          const Offset(180, 200),
          const Offset(140, 200),
          const Offset(100, 190),
          const Offset(80, 160),
          const Offset(70, 120),
          const Offset(70, 100),
        ],
        // النقطة الأولى
        [
          const Offset(140, 70),
        ],
        // النقطة الثانية
        [
          const Offset(180, 70),
        ],
      ],
    ),

    // ث - ثاء
    'ث': LetterPath(
      letter: 'ث',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(250, 100),
          const Offset(240, 150),
          const Offset(220, 180),
          const Offset(180, 200),
          const Offset(140, 200),
          const Offset(100, 190),
          const Offset(80, 160),
          const Offset(70, 120),
          const Offset(70, 100),
        ],
        // النقطة الأولى
        [
          const Offset(120, 70),
        ],
        // النقطة الثانية
        [
          const Offset(160, 70),
        ],
        // النقطة الثالثة
        [
          const Offset(200, 70),
        ],
      ],
    ),

    // ج - جيم
    'ج': LetterPath(
      letter: 'ج',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(80, 100),
          const Offset(120, 90),
          const Offset(180, 90),
          const Offset(220, 100),
          const Offset(240, 130),
          const Offset(240, 170),
          const Offset(220, 200),
          const Offset(180, 210),
          const Offset(140, 210),
          const Offset(100, 200),
        ],
        // النقطة
        [
          const Offset(160, 230),
        ],
      ],
    ),

    // ح - حاء
    'ح': LetterPath(
      letter: 'ح',
      strokes: [
        [
          const Offset(80, 100),
          const Offset(120, 90),
          const Offset(180, 90),
          const Offset(220, 100),
          const Offset(240, 130),
          const Offset(240, 170),
          const Offset(220, 200),
          const Offset(180, 210),
          const Offset(140, 210),
          const Offset(100, 200),
        ],
      ],
    ),

    // خ - خاء
    'خ': LetterPath(
      letter: 'خ',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(80, 100),
          const Offset(120, 90),
          const Offset(180, 90),
          const Offset(220, 100),
          const Offset(240, 130),
          const Offset(240, 170),
          const Offset(220, 200),
          const Offset(180, 210),
          const Offset(140, 210),
          const Offset(100, 200),
        ],
        // النقطة
        [
          const Offset(160, 70),
        ],
      ],
    ),

    // د - دال
    'د': LetterPath(
      letter: 'د',
      strokes: [
        [
          const Offset(100, 150),
          const Offset(140, 140),
          const Offset(180, 140),
          const Offset(220, 150),
          const Offset(240, 180),
          const Offset(230, 210),
          const Offset(200, 230),
          const Offset(160, 240),
          const Offset(120, 230),
          const Offset(90, 210),
        ],
      ],
    ),

    // ذ - ذال
    'ذ': LetterPath(
      letter: 'ذ',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(100, 150),
          const Offset(140, 140),
          const Offset(180, 140),
          const Offset(220, 150),
          const Offset(240, 180),
          const Offset(230, 210),
          const Offset(200, 230),
          const Offset(160, 240),
          const Offset(120, 230),
          const Offset(90, 210),
        ],
        // النقطة
        [
          const Offset(180, 110),
        ],
      ],
    ),

    // ر - راء
    'ر': LetterPath(
      letter: 'ر',
      strokes: [
        [
          const Offset(140, 120),
          const Offset(160, 140),
          const Offset(180, 160),
          const Offset(200, 190),
          const Offset(210, 220),
          const Offset(210, 250),
        ],
      ],
    ),

    // ز - زاي
    'ز': LetterPath(
      letter: 'ز',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(140, 120),
          const Offset(160, 140),
          const Offset(180, 160),
          const Offset(200, 190),
          const Offset(210, 220),
          const Offset(210, 250),
        ],
        // النقطة
        [
          const Offset(160, 100),
        ],
      ],
    ),

    // س - سين
    'س': LetterPath(
      letter: 'س',
      strokes: [
        [
          const Offset(70, 150),
          const Offset(90, 140),
          const Offset(110, 145),
          const Offset(130, 160),
          const Offset(140, 180),
          const Offset(150, 160),
          const Offset(170, 145),
          const Offset(190, 140),
          const Offset(210, 145),
          const Offset(230, 160),
          const Offset(240, 180),
          const Offset(250, 200),
        ],
      ],
    ),

    // ش - شين
    'ش': LetterPath(
      letter: 'ش',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(70, 150),
          const Offset(90, 140),
          const Offset(110, 145),
          const Offset(130, 160),
          const Offset(140, 180),
          const Offset(150, 160),
          const Offset(170, 145),
          const Offset(190, 140),
          const Offset(210, 145),
          const Offset(230, 160),
          const Offset(240, 180),
          const Offset(250, 200),
        ],
        // النقطة الأولى
        [
          const Offset(120, 110),
        ],
        // النقطة الثانية
        [
          const Offset(160, 110),
        ],
        // النقطة الثالثة
        [
          const Offset(200, 110),
        ],
      ],
    ),

    // ص - صاد
    'ص': LetterPath(
      letter: 'ص',
      strokes: [
        [
          const Offset(80, 120),
          const Offset(120, 110),
          const Offset(160, 110),
          const Offset(200, 120),
          const Offset(220, 140),
          const Offset(230, 170),
          const Offset(230, 200),
          const Offset(220, 230),
          const Offset(190, 250),
          const Offset(150, 260),
          const Offset(110, 250),
        ],
      ],
    ),

    // ض - ضاد
    'ض': LetterPath(
      letter: 'ض',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(80, 120),
          const Offset(120, 110),
          const Offset(160, 110),
          const Offset(200, 120),
          const Offset(220, 140),
          const Offset(230, 170),
          const Offset(230, 200),
          const Offset(220, 230),
          const Offset(190, 250),
          const Offset(150, 260),
          const Offset(110, 250),
        ],
        // النقطة
        [
          const Offset(180, 90),
        ],
      ],
    ),

    // ط - طاء
    'ط': LetterPath(
      letter: 'ط',
      strokes: [
        [
          const Offset(100, 140),
          const Offset(140, 130),
          const Offset(180, 130),
          const Offset(220, 140),
          const Offset(240, 170),
          const Offset(240, 200),
          const Offset(220, 230),
          const Offset(180, 240),
          const Offset(140, 240),
          const Offset(100, 230),
          const Offset(80, 200),
        ],
      ],
    ),

    // ظ - ظاء
    'ظ': LetterPath(
      letter: 'ظ',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(100, 140),
          const Offset(140, 130),
          const Offset(180, 130),
          const Offset(220, 140),
          const Offset(240, 170),
          const Offset(240, 200),
          const Offset(220, 230),
          const Offset(180, 240),
          const Offset(140, 240),
          const Offset(100, 230),
          const Offset(80, 200),
        ],
        // النقطة
        [
          const Offset(180, 110),
        ],
      ],
    ),

    // ع - عين
    'ع': LetterPath(
      letter: 'ع',
      strokes: [
        [
          const Offset(180, 120),
          const Offset(200, 140),
          const Offset(210, 170),
          const Offset(210, 200),
          const Offset(190, 230),
          const Offset(160, 240),
          const Offset(130, 230),
          const Offset(110, 200),
          const Offset(110, 170),
          const Offset(120, 140),
        ],
      ],
    ),

    // غ - غين
    'غ': LetterPath(
      letter: 'غ',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(180, 120),
          const Offset(200, 140),
          const Offset(210, 170),
          const Offset(210, 200),
          const Offset(190, 230),
          const Offset(160, 240),
          const Offset(130, 230),
          const Offset(110, 200),
          const Offset(110, 170),
          const Offset(120, 140),
        ],
        // النقطة
        [
          const Offset(160, 100),
        ],
      ],
    ),

    // ف - فاء
    'ف': LetterPath(
      letter: 'ف',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(160, 80),
          const Offset(180, 100),
          const Offset(200, 130),
          const Offset(210, 170),
          const Offset(210, 210),
          const Offset(190, 240),
          const Offset(160, 250),
          const Offset(130, 240),
          const Offset(110, 210),
          const Offset(110, 180),
        ],
        // النقطة
        [
          const Offset(160, 60),
        ],
      ],
    ),

    // ق - قاف
    'ق': LetterPath(
      letter: 'ق',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(160, 80),
          const Offset(180, 100),
          const Offset(200, 130),
          const Offset(210, 170),
          const Offset(210, 210),
          const Offset(190, 240),
          const Offset(160, 250),
          const Offset(130, 240),
          const Offset(110, 210),
          const Offset(110, 180),
        ],
        // النقطة الأولى
        [
          const Offset(140, 60),
        ],
        // النقطة الثانية
        [
          const Offset(180, 60),
        ],
      ],
    ),

    // ك - كاف
    'ك': LetterPath(
      letter: 'ك',
      strokes: [
        [
          const Offset(100, 100),
          const Offset(100, 200),
        ],
        [
          const Offset(100, 150),
          const Offset(140, 120),
          const Offset(180, 110),
          const Offset(220, 120),
        ],
        [
          const Offset(180, 140),
          const Offset(200, 170),
          const Offset(210, 200),
        ],
      ],
    ),

    // ل - لام
    'ل': LetterPath(
      letter: 'ل',
      strokes: [
        [
          const Offset(140, 80),
          const Offset(150, 100),
          const Offset(160, 130),
          const Offset(165, 160),
          const Offset(165, 190),
          const Offset(165, 220),
          const Offset(165, 250),
        ],
      ],
    ),

    // م - ميم
    'م': LetterPath(
      letter: 'م',
      strokes: [
        [
          const Offset(80, 150),
          const Offset(100, 140),
          const Offset(130, 135),
          const Offset(160, 135),
          const Offset(190, 140),
          const Offset(220, 150),
          const Offset(240, 180),
          const Offset(240, 210),
          const Offset(220, 240),
          const Offset(180, 250),
          const Offset(140, 240),
          const Offset(110, 220),
        ],
      ],
    ),

    // ن - نون
    'ن': LetterPath(
      letter: 'ن',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(80, 160),
          const Offset(120, 150),
          const Offset(160, 150),
          const Offset(200, 160),
          const Offset(220, 180),
          const Offset(230, 210),
          const Offset(220, 240),
          const Offset(190, 260),
          const Offset(150, 270),
          const Offset(110, 260),
        ],
        // النقطة
        [
          const Offset(160, 130),
        ],
      ],
    ),

    // ه - هاء
    'ه': LetterPath(
      letter: 'ه',
      strokes: [
        [
          const Offset(160, 100),
          const Offset(200, 120),
          const Offset(220, 150),
          const Offset(230, 190),
          const Offset(220, 230),
          const Offset(190, 260),
          const Offset(150, 270),
          const Offset(110, 260),
          const Offset(80, 230),
          const Offset(70, 190),
          const Offset(80, 150),
          const Offset(110, 120),
          const Offset(150, 110),
        ],
      ],
    ),

    // و - واو
    'و': LetterPath(
      letter: 'و',
      strokes: [
        [
          const Offset(160, 130),
          const Offset(190, 150),
          const Offset(210, 180),
          const Offset(220, 220),
          const Offset(210, 260),
          const Offset(180, 290),
          const Offset(140, 300),
          const Offset(100, 290),
          const Offset(80, 260),
          const Offset(70, 220),
          const Offset(80, 180),
          const Offset(110, 150),
          const Offset(140, 140),
        ],
      ],
    ),

    // ي - ياء
    'ي': LetterPath(
      letter: 'ي',
      strokes: [
        // الشكل الأساسي
        [
          const Offset(80, 150),
          const Offset(120, 140),
          const Offset(160, 140),
          const Offset(200, 150),
          const Offset(220, 170),
          const Offset(230, 200),
          const Offset(230, 230),
          const Offset(220, 260),
          const Offset(200, 280),
        ],
        // النقطة الأولى
        [
          const Offset(210, 300),
        ],
        // النقطة الثانية
        [
          const Offset(240, 300),
        ],
      ],
    ),
  };

  /// الحصول على مسار حرف معين
  static LetterPath? getPath(String letter) {
    return paths[letter];
  }
}
