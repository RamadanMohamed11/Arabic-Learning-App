import 'dart:ui';
import 'dart:math' as math;
import 'dart:typed_data';
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

  /// تحويل عنصر `line` إلى Flutter Path
  static Path parseLineElement(XmlElement lineElement) {
    final x1 = double.tryParse(lineElement.getAttribute('x1') ?? '') ?? 0;
    final y1 = double.tryParse(lineElement.getAttribute('y1') ?? '') ?? 0;
    final x2 = double.tryParse(lineElement.getAttribute('x2') ?? '') ?? 0;
    final y2 = double.tryParse(lineElement.getAttribute('y2') ?? '') ?? 0;

    final path = Path();
    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
    return path;
  }

  /// تحويل عنصر `ellipse` إلى Flutter Path
  static Path parseEllipseElement(XmlElement ellipseElement) {
    final cx = double.tryParse(ellipseElement.getAttribute('cx') ?? '') ?? 0;
    final cy = double.tryParse(ellipseElement.getAttribute('cy') ?? '') ?? 0;
    final rx = double.tryParse(ellipseElement.getAttribute('rx') ?? '') ?? 0;
    final ry = double.tryParse(ellipseElement.getAttribute('ry') ?? '') ?? 0;

    final path = Path();
    path.addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));
    return path;
  }

  /// تحويل عنصر `circle` إلى Flutter Path
  static Path parseCircleElement(XmlElement circleElement) {
    final cx = double.tryParse(circleElement.getAttribute('cx') ?? '') ?? 0;
    final cy = double.tryParse(circleElement.getAttribute('cy') ?? '') ?? 0;
    final r = double.tryParse(circleElement.getAttribute('r') ?? '') ?? 0;

    final path = Path();
    path.addOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2));
    return path;
  }

  /// تحليل `transform` attribute وإرجاع مصفوفة التحويل
  /// يدعم: rotate(angle cx cy) و rotate(angle)
  static Float64List? parseTransformAttribute(String? transform) {
    if (transform == null || transform.isEmpty) return null;

    // Handle rotate(angle cx cy)
    final rotateCxCy = RegExp(
      r'rotate\(\s*([^\s,]+)[\s,]+([^\s,]+)[\s,]+([^\s,)]+)\s*\)',
    ).firstMatch(transform);
    if (rotateCxCy != null) {
      final angleDeg = double.tryParse(rotateCxCy.group(1)!) ?? 0;
      final cx = double.tryParse(rotateCxCy.group(2)!) ?? 0;
      final cy = double.tryParse(rotateCxCy.group(3)!) ?? 0;
      return _buildRotationMatrix(angleDeg, cx, cy);
    }

    // Handle rotate(angle) — rotation around origin
    final rotateSimple = RegExp(
      r'rotate\(\s*([^\s,)]+)\s*\)',
    ).firstMatch(transform);
    if (rotateSimple != null) {
      final angleDeg = double.tryParse(rotateSimple.group(1)!) ?? 0;
      return _buildRotationMatrix(angleDeg, 0, 0);
    }

    return null;
  }

  /// إنشاء مصفوفة دوران حول نقطة (cx, cy) بزاوية بالدرجات
  static Float64List _buildRotationMatrix(double angleDeg, double cx, double cy) {
    final angleRad = angleDeg * math.pi / 180.0;
    final cosA = math.cos(angleRad);
    final sinA = math.sin(angleRad);

    // T(cx,cy) * R(angle) * T(-cx,-cy)
    // Combined into a single affine matrix:
    // | cosA  -sinA  cx - cx*cosA + cy*sinA |
    // | sinA   cosA  cy - cx*sinA - cy*cosA |
    // |  0      0                 1         |
    final tx = cx - cx * cosA + cy * sinA;
    final ty = cy - cx * sinA - cy * cosA;

    // Flutter's Path.transform expects a 4x4 matrix in column-major order
    return Float64List.fromList([
      cosA, sinA, 0, 0,   // column 0
      -sinA, cosA, 0, 0,  // column 1
      0, 0, 1, 0,         // column 2
      tx, ty, 0, 1,       // column 3
    ]);
  }

  /// استخراج جميع المسارات من عنصر SVG (يدعم path و line والعناصر المتداخلة)
  static void _extractPaths(XmlElement element, List<Path> paths) {
    for (final child in element.children.whereType<XmlElement>()) {
      final tagName = child.name.local;

      if (tagName == 'g') {
        // مجموعة — ابحث بداخلها
        _extractPaths(child, paths);
      } else if (tagName == 'path') {
        final pathData = child.getAttribute('d');
        if (pathData == null || pathData.isEmpty) continue;

        try {
          var path = parseSvgPath(pathData);

          // تطبيق transform إن وُجد
          final transformStr = child.getAttribute('transform');
          final transformMatrix = parseTransformAttribute(transformStr);
          if (transformMatrix != null) {
            path = path.transform(transformMatrix);
          }

          // تصفية المسارات المنحلة (نقطة واحدة بدون رسم فعلي)
          final bounds = path.getBounds();
          if (bounds.width > 1 || bounds.height > 1) {
            paths.add(path);
          }
        } catch (_) {}
      } else if (tagName == 'line') {
        try {
          var path = parseLineElement(child);

          // تطبيق transform إن وُجد
          final transformStr = child.getAttribute('transform');
          final transformMatrix = parseTransformAttribute(transformStr);
          if (transformMatrix != null) {
            path = path.transform(transformMatrix);
          }

          // تصفية المسارات المنحلة
          final bounds = path.getBounds();
          if (bounds.width > 1 || bounds.height > 1) {
            paths.add(path);
          }
        } catch (_) {}
      } else if (tagName == 'ellipse') {
        try {
          var path = parseEllipseElement(child);

          // تطبيق transform إن وُجد
          final transformStr = child.getAttribute('transform');
          final transformMatrix = parseTransformAttribute(transformStr);
          if (transformMatrix != null) {
            path = path.transform(transformMatrix);
          }

          final bounds = path.getBounds();
          if (bounds.width > 1 || bounds.height > 1) {
            paths.add(path);
          }
        } catch (_) {}
      } else if (tagName == 'circle') {
        try {
          var path = parseCircleElement(child);

          // تطبيق transform إن وُجد
          final transformStr = child.getAttribute('transform');
          final transformMatrix = parseTransformAttribute(transformStr);
          if (transformMatrix != null) {
            path = path.transform(transformMatrix);
          }

          final bounds = path.getBounds();
          if (bounds.width > 1 || bounds.height > 1) {
            paths.add(path);
          }
        } catch (_) {}
      }
    }
  }

  /// قراءة ملف SVG وتحويله إلى paths مع تحويل الإحداثيات لتناسب الـ canvas
  static Future<SvgNumberPath> loadNumberFromSvg(
    int number, {
    required double canvasWidth,
    required double canvasHeight,
    double padding = 40.0,
    String svgBasePath = 'assets/svg/numbers',
  }) async {
    final svgString = await rootBundle.loadString(
      '$svgBasePath/$number.svg',
    );

    final document = XmlDocument.parse(svgString);

    // استخراج جميع المسارات (path + line مع دعم transform)
    final rawPaths = <Path>[];
    _extractPaths(document.rootElement, rawPaths);

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

    // إنشاء مصفوفة التحويل للـ canvas
    final matrix = Float64List.fromList([
      scale, 0, 0, 0,       // column 0
      0, scale, 0, 0,       // column 1
      0, 0, 1, 0,           // column 2
      offsetX, offsetY, 0, 1, // column 3
    ]);

    // تحويل جميع المسارات
    final transformedPaths = <Path>[];
    for (final path in rawPaths) {
      transformedPaths.add(path.transform(matrix));
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
    String svgBasePath = 'assets/svg/numbers',
  }) async {
    final key = '${svgBasePath}_${number}_${canvasWidth.toInt()}x${canvasHeight.toInt()}';
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final numberPath = await SvgNumberPathConverter.loadNumberFromSvg(
        number,
        canvasWidth: canvasWidth,
        canvasHeight: canvasHeight,
        svgBasePath: svgBasePath,
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
