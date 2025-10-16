import 'package:flutter/material.dart';

/// Painter مخصص لرسم مسار الحرف وتتبع تقدم المستخدم
class LetterTracePainter extends CustomPainter {
  final List<List<Offset>> guideStrokes; // المسارات الإرشادية
  final List<Offset>? guideDots; // النقاط الإرشادية
  final List<Offset> userPath; // مسار المستخدم
  final bool isCompleted; // هل اكتمل الرسم؟
  final int currentStrokeIndex; // رقم الـ stroke الحالي
  final Offset? currentFingerPosition; // موقع الإصبع الحالي

  LetterTracePainter({
    required this.guideStrokes,
    this.guideDots,
    required this.userPath,
    required this.isCompleted,
    required this.currentStrokeIndex,
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
    if (!isCompleted && currentStrokeIndex < guideStrokes.length) {
      _drawStartPoint(canvas, paint);
    }

    // 3. رسم تقدم المستخدم
    if (userPath.isNotEmpty && !isCompleted) {
      _drawUserProgress(canvas, paint);
    }

    // 4. رسم موقع الإصبع الحالي
    if (currentFingerPosition != null && !isCompleted) {
      _drawFingerIndicator(canvas, paint);
    }

    // 5. عند الانتهاء، ارسم المسار الكامل بالأخضر
    if (isCompleted) {
      _drawCompletedPath(canvas, paint);
    }
  }

  /// رسم المسارات الإرشادية الرمادية
  void _drawGuidePaths(Canvas canvas, Paint paint) {
    paint.color = Colors.grey.withOpacity(0.4);

    for (var stroke in guideStrokes) {
      if (stroke.isEmpty) continue;

      // إذا كان stroke يحتوي على نقطة واحدة فقط (نقطة)
      if (stroke.length == 1) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(stroke.first, 12, paint);
        paint.style = PaintingStyle.stroke;
      } else {
        // خط عادي
        paint.strokeWidth = 30.0;
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (var i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  /// رسم نقطة البداية
  void _drawStartPoint(Canvas canvas, Paint paint) {
    final currentStroke = guideStrokes[currentStrokeIndex];
    if (currentStroke.isEmpty) return;

    final startPoint = currentStroke.first;

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

  /// رسم تقدم المستخدم (أبيض)
  void _drawUserProgress(Canvas canvas, Paint paint) {
    if (userPath.isEmpty) return;

    paint.color = Colors.white;

    // رسم جميع الـ strokes المكتملة
    int pointIndex = 0;
    for (int i = 0; i < currentStrokeIndex && i < guideStrokes.length; i++) {
      final stroke = guideStrokes[i];
      if (stroke.isEmpty) continue;

      // إذا كان stroke نقطة واحدة
      if (stroke.length == 1) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(stroke.first, 12, paint);
        
        // إضافة ظل للنقطة
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(stroke.first, 12, shadowPaint);
        canvas.drawCircle(stroke.first, 12, paint);
        
        paint.style = PaintingStyle.stroke;
        pointIndex++;
      } else {
        // خط عادي
        paint.strokeWidth = 28.0;
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (var j = 1; j < stroke.length; j++) {
          path.lineTo(stroke[j].dx, stroke[j].dy);
        }
        canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, false);
        canvas.drawPath(path, paint);
        pointIndex += stroke.length;
      }
    }

    // رسم الـ stroke الحالي (قيد التقدم)
    if (currentStrokeIndex < guideStrokes.length) {
      final currentStroke = guideStrokes[currentStrokeIndex];
      
      if (currentStroke.length == 1) {
        // نقطة - انتظر حتى يلمس المستخدم
        // سيتم رسمها عند الإكمال
      } else if (userPath.length > pointIndex) {
        // خط - ارسم التقدم
        paint.strokeWidth = 28.0;
        final path = Path();
        path.moveTo(userPath[pointIndex].dx, userPath[pointIndex].dy);
        for (var i = pointIndex + 1; i < userPath.length; i++) {
          path.lineTo(userPath[i].dx, userPath[i].dy);
        }
        canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4.0, false);
        canvas.drawPath(path, paint);
      }
    }
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

  /// رسم المسار الكامل عند النجاح (أخضر)
  void _drawCompletedPath(Canvas canvas, Paint paint) {
    paint.color = Colors.green;

    // رسم جميع الـ strokes
    for (var stroke in guideStrokes) {
      if (stroke.isEmpty) continue;

      // إذا كان stroke نقطة واحدة
      if (stroke.length == 1) {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(stroke.first, 12, paint);
        paint.style = PaintingStyle.stroke;
      } else {
        // خط عادي
        paint.strokeWidth = 30.0;
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (var i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        // إضافة ظل
        canvas.drawShadow(path, Colors.black.withOpacity(0.3), 6.0, false);
        canvas.drawPath(path, paint);
      }
    }

    // رسم نجوم حول الحرف للاحتفال
    _drawCelebrationStars(canvas);
  }

  /// رسم نجوم احتفالية
  void _drawCelebrationStars(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final starPositions = [
      const Offset(50, 50),
      const Offset(270, 50),
      const Offset(50, 320),
      const Offset(270, 320),
    ];

    for (var pos in starPositions) {
      _drawStar(canvas, paint, pos, 15);
    }
  }

  /// رسم نجمة
  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final double x = center.dx + size * (i % 2 == 0 ? 1 : 0.5) * 
          (i == 0 ? 0 : (i == 1 ? 0.951 : (i == 2 ? 0.588 : (i == 3 ? -0.588 : -0.951))));
      final double y = center.dy + size * (i % 2 == 0 ? 1 : 0.5) * 
          (i == 0 ? -1 : (i == 1 ? -0.309 : (i == 2 ? 0.809 : (i == 3 ? 0.809 : -0.309))));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LetterTracePainter oldDelegate) {
    return userPath != oldDelegate.userPath ||
        isCompleted != oldDelegate.isCompleted ||
        currentStrokeIndex != oldDelegate.currentStrokeIndex ||
        currentFingerPosition != oldDelegate.currentFingerPosition;
  }
}
