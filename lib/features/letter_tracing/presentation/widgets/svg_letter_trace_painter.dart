import 'dart:ui';
import 'dart:math' as dart_math;
import 'package:flutter/material.dart';

/// Painter مخصص لرسم مسار الحرف من SVG وتتبع تقدم المستخدم
class SvgLetterTracePainter extends CustomPainter {
  final List<Path> guidePaths; // المسارات من SVG
  final List<Offset> userPath; // مسار المستخدم
  final bool isCompleted; // هل اكتمل الرسم؟
  final int currentPathIndex; // رقم الـ path الحالي
  final Offset? currentFingerPosition; // موقع الإصبع الحالي

  SvgLetterTracePainter({
    required this.guidePaths,
    required this.userPath,
    required this.isCompleted,
    required this.currentPathIndex,
    this.currentFingerPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // إعدادات الفرشاة الأساسية
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // 1. رسم المسارات الإرشادية (رمادي باهت)
    _drawGuidePaths(canvas, paint);

    // 2. رسم نقطة البداية (دائرة خضراء)
    if (!isCompleted && currentPathIndex < guidePaths.length) {
      _drawStartPoint(canvas, paint);
    }

    // 3. رسم المسارات المكتملة (أخضر)
    _drawCompletedPaths(canvas, paint);

    // 4. رسم تقدم المستخدم على المسار الحالي
    if (userPath.isNotEmpty && !isCompleted) {
      _drawUserProgress(canvas, paint);
    }

    // 5. رسم موقع الإصبع الحالي
    if (currentFingerPosition != null && !isCompleted) {
      _drawFingerIndicator(canvas, paint);
    }

    // 6. عند الانتهاء، ارسم جميع المسارات بالأخضر
    if (isCompleted) {
      _drawAllCompletedPaths(canvas, paint);
    }
  }

  /// رسم المسارات الإرشادية الرمادية
  void _drawGuidePaths(Canvas canvas, Paint paint) {
    paint.color = Colors.grey.withOpacity(0.3);
    paint.strokeWidth = 25.0;

    for (final path in guidePaths) {
      canvas.drawPath(path, paint);
    }
  }

  /// رسم نقطة البداية
  void _drawStartPoint(Canvas canvas, Paint paint) {
    if (currentPathIndex >= guidePaths.length) return;

    final currentPath = guidePaths[currentPathIndex];
    final pathMetrics = currentPath.computeMetrics().first;
    final startTangent = pathMetrics.getTangentForOffset(0);
    
    if (startTangent == null) return;
    final startPoint = startTangent.position;

    // دائرة خارجية خضراء متحركة
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    paint.color = Colors.green.withOpacity(0.6);
    canvas.drawCircle(startPoint, 25, paint);

    // دائرة داخلية خضراء
    paint.style = PaintingStyle.fill;
    paint.color = Colors.green.withOpacity(0.8);
    canvas.drawCircle(startPoint, 15, paint);

    paint.style = PaintingStyle.stroke;
  }

  /// رسم المسارات المكتملة (أخضر)
  void _drawCompletedPaths(Canvas canvas, Paint paint) {
    paint.color = Colors.green;
    paint.strokeWidth = 28.0;

    for (int i = 0; i < currentPathIndex && i < guidePaths.length; i++) {
      final path = guidePaths[i];
      
      // إضافة ظل
      canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, false);
      canvas.drawPath(path, paint);
    }
  }

  /// رسم تقدم المستخدم (أبيض)
  void _drawUserProgress(Canvas canvas, Paint paint) {
    if (userPath.length < 2) return;

    paint.color = Colors.white;
    paint.strokeWidth = 26.0;

    final path = Path();
    path.moveTo(userPath.first.dx, userPath.first.dy);
    for (var i = 1; i < userPath.length; i++) {
      path.lineTo(userPath[i].dx, userPath[i].dy);
    }

    // إضافة ظل للمسار
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, false);
    canvas.drawPath(path, paint);
  }

  /// رسم مؤشر الإصبع الحالي
  void _drawFingerIndicator(Canvas canvas, Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = Colors.blue.withOpacity(0.3);
    canvas.drawCircle(currentFingerPosition!, 20, paint);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    paint.color = Colors.blue;
    canvas.drawCircle(currentFingerPosition!, 20, paint);
  }

  /// رسم جميع المسارات عند النجاح (أخضر)
  void _drawAllCompletedPaths(Canvas canvas, Paint paint) {
    paint.color = Colors.green;
    paint.strokeWidth = 30.0;

    for (final path in guidePaths) {
      // إضافة ظل
      canvas.drawShadow(path, Colors.black.withOpacity(0.3), 6.0, false);
      canvas.drawPath(path, paint);
    }

    // رسم نجوم حول الحرف للاحتفال
    _drawCelebrationStars(canvas);
  }

  /// رسم نجوم احتفالية
  void _drawCelebrationStars(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    // نجوم في الزوايا
    final starPositions = [
      const Offset(50, 50),
      const Offset(300, 50),
      const Offset(50, 400),
      const Offset(300, 400),
      const Offset(175, 30),
      const Offset(175, 420),
    ];

    for (final pos in starPositions) {
      _drawStar(canvas, paint, pos, 15);
    }
  }

  /// رسم نجمة
  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final double angle = 3.14159 / 5;

    for (int i = 0; i < 10; i++) {
      final double radius = i.isEven ? size : size / 2;
      final double x = center.dx + radius * cos(i * angle - 3.14159 / 2);
      final double y = center.dy + radius * sin(i * angle - 3.14159 / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  double cos(double angle) => angle.cos();
  double sin(double angle) => angle.sin();

  @override
  bool shouldRepaint(SvgLetterTracePainter oldDelegate) {
    return oldDelegate.userPath != userPath ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.currentPathIndex != currentPathIndex ||
        oldDelegate.currentFingerPosition != currentFingerPosition;
  }
}

extension on double {
  double cos() => dart_math.cos(this);
  double sin() => dart_math.sin(this);
}
