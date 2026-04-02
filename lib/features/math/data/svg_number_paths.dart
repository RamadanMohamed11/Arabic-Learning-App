import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:path_parsing/path_parsing.dart';

/// نموذج لمسار رقم من SVG
class SvgNumberPath {
  final int number;
  final List<Path> paths;

  const SvgNumberPath({required this.number, required this.paths});
}

/// محول SVG إلى Flutter Paths للأرقام
class SvgNumberPathConverter {
  /// تحويل SVG path string إلى Flutter Path
  static Path parseSvgPath(String pathData) {
    final path = Path();
    final pathProxy = _PathProxy(path);
    writeSvgPathDataToPath(pathData, pathProxy);
    return path;
  }

  /// قراءة ملف SVG وتحويله إلى paths مع تحويل الإحداثيات لتناسب الـ canvas
  static Future<SvgNumberPath> loadNumberFromSvg(
    int number, {
    required double canvasWidth,
    required double canvasHeight,
    double padding = 40.0,
  }) async {
    final svgString = await rootBundle.loadString(
      'assets/svg/numbers/$number.svg',
    );

    final document = XmlDocument.parse(svgString);
    final pathElements = document.findAllElements('path');
    final rawPaths = <Path>[];
    for (final pathElement in pathElements) {
      final pathData = pathElement.getAttribute('d');
      if (pathData != null && pathData.isNotEmpty) {
        try {
          rawPaths.add(parseSvgPath(pathData));
        } catch (_) {}
      }
    }

    if (rawPaths.isEmpty) {
      return SvgNumberPath(number: number, paths: []);
    }

    // حساب bounding box لجميع المسارات
    Rect totalBounds = rawPaths.first.getBounds();
    for (int i = 1; i < rawPaths.length; i++) {
      totalBounds = totalBounds.expandToInclude(rawPaths[i].getBounds());
    }

    // حساب scale و offset لتوسيط المسارات في الـ canvas مع padding
    final availableWidth = canvasWidth - (padding * 2);
    final availableHeight = canvasHeight - (padding * 2);

    final scaleX = availableWidth / totalBounds.width;
    final scaleY = availableHeight / totalBounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY; // الأصغر للحفاظ على النسبة

    final scaledWidth = totalBounds.width * scale;
    final scaledHeight = totalBounds.height * scale;

    final offsetX =
        padding + (availableWidth - scaledWidth) / 2 - totalBounds.left * scale;
    final offsetY =
        padding +
        (availableHeight - scaledHeight) / 2 -
        totalBounds.top * scale;

    // إنشاء مصفوفة التحويل
    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale, scale);

    // تحويل جميع المسارات
    final transformedPaths = <Path>[];
    for (final path in rawPaths) {
      transformedPaths.add(path.transform(matrix.storage));
    }

    return SvgNumberPath(number: number, paths: transformedPaths);
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
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
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

/// مدير مسارات الأرقام من SVG مع cache
class SvgNumberPathManager {
  static final Map<String, SvgNumberPath> _cache = {};

  /// الحصول على مسار رقم (مع cache) — يجب تمرير أبعاد الـ canvas
  static Future<SvgNumberPath?> getPath(
    int number, {
    required double canvasWidth,
    required double canvasHeight,
  }) async {
    final key = '${number}_${canvasWidth.toInt()}x${canvasHeight.toInt()}';
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final numberPath = await SvgNumberPathConverter.loadNumberFromSvg(
        number,
        canvasWidth: canvasWidth,
        canvasHeight: canvasHeight,
      );
      _cache[key] = numberPath;
      return numberPath;
    } catch (_) {
      return null;
    }
  }

  /// مسح الـ cache
  static void clearCache() {
    _cache.clear();
  }
}
