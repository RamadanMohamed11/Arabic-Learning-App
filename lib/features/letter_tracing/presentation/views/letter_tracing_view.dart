import 'package:flutter/material.dart';
import 'package:arabic_learning_app/features/letter_tracing/data/letter_paths.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/widgets/letter_trace_painter.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';

class LetterTracingView extends StatefulWidget {
  final String letter;

  const LetterTracingView({super.key, required this.letter});

  @override
  State<LetterTracingView> createState() => _LetterTracingViewState();
}

class _LetterTracingViewState extends State<LetterTracingView>
    with SingleTickerProviderStateMixin {
  // بيانات الحرف
  late LetterPath? letterPath;

  // حالة التتبع
  List<Offset> userPath = [];
  int currentStrokeIndex = 0;
  int nextPointIndex = 0;
  bool isCompleted = false;
  Offset? currentFingerPosition;

  // Animation للنجاح
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  // إعدادات الحساسية
  final double touchTolerance = 35.0; // المسافة المسموحة للخطأ

  @override
  void initState() {
    super.initState();
    letterPath = ArabicLetterPaths.getPath(widget.letter);
    _playIntro();

    // تهيئة animation
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      "قُمْ بِتَتَبُّعِ الحَرْف",
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    _celebrationController.dispose();
    super.dispose();
  }

  /// إعادة تعيين الرسم
  void resetDrawing() {
    setState(() {
      userPath.clear();
      currentStrokeIndex = 0;
      nextPointIndex = 0;
      isCompleted = false;
      currentFingerPosition = null;
    });
    _celebrationController.reset();
  }

  /// معالجة بداية اللمس
  void onPanStart(Offset position) {
    if (isCompleted || letterPath == null) return;

    final currentStroke = letterPath!.strokes[currentStrokeIndex];
    if (currentStroke.isEmpty) return;

    // التحقق من أن المستخدم يبدأ من نقطة البداية
    final startPoint = currentStroke[nextPointIndex];
    final distance = (position - startPoint).distance;

    if (distance < touchTolerance) {
      setState(() {
        userPath.add(startPoint);
        nextPointIndex++;
        currentFingerPosition = position;
      });
    }
  }

  /// معالجة حركة الإصبع
  void onPanUpdate(Offset position) {
    if (isCompleted || letterPath == null) return;

    setState(() {
      currentFingerPosition = position;
    });

    final currentStroke = letterPath!.strokes[currentStrokeIndex];

    // إذا وصلنا لنهاية الـ stroke الحالي
    if (nextPointIndex >= currentStroke.length) {
      _completeCurrentStroke();
      return;
    }

    // النقطة المستهدفة
    final targetPoint = currentStroke[nextPointIndex];
    final distance = (position - targetPoint).distance;

    // إذا كان الإصبع قريب من النقطة المستهدفة
    if (distance < touchTolerance) {
      setState(() {
        userPath.add(targetPoint);
        nextPointIndex++;

        // إذا أكملنا الـ stroke الحالي
        if (nextPointIndex >= currentStroke.length) {
          _completeCurrentStroke();
        }
      });
    }
  }

  /// معالجة رفع الإصبع
  void onPanEnd() {
    setState(() {
      currentFingerPosition = null;
    });

    // إذا لم يكتمل الـ stroke، أعد المحاولة
    if (!isCompleted && letterPath != null) {
      final currentStroke = letterPath!.strokes[currentStrokeIndex];
      if (nextPointIndex < currentStroke.length) {
        // إعادة المحاولة للـ stroke الحالي
        setState(() {
          // احتفظ بالـ strokes المكتملة
          int completedPoints = 0;
          for (int i = 0; i < currentStrokeIndex; i++) {
            completedPoints += letterPath!.strokes[i].length;
          }

          if (userPath.length > completedPoints) {
            userPath.removeRange(completedPoints, userPath.length);
          }
          nextPointIndex = 0;
        });
      }
    }
  }

  /// إكمال الـ stroke الحالي
  void _completeCurrentStroke() {
    currentStrokeIndex++;
    nextPointIndex = 0;

    // إذا أكملنا جميع الـ strokes
    if (currentStrokeIndex >= letterPath!.strokes.length) {
      _completeDrawing();
    }
  }

  /// إكمال الرسم بنجاح
  void _completeDrawing() {
    setState(() {
      isCompleted = true;
      currentFingerPosition = null;
    });

    // تشغيل animation الاحتفال
    _celebrationController.forward();

    // إظهار dialog بعد ثانية
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _showSuccessDialog();
      }
    });
  }

  /// الحصول على الحرف التالي (دائماً يرجع حرف، حتى لو كان آخر حرف يرجع للأول)
  String _getNextLetter() {
    final currentIndex = arabicLetters.indexWhere(
      (l) => l.letter == widget.letter,
    );
    if (currentIndex == -1 || currentIndex >= arabicLetters.length - 1) {
      // إذا كان آخر حرف، ارجع للحرف الأول
      return arabicLetters[0].letter;
    }
    return arabicLetters[currentIndex + 1].letter;
  }

  /// الحصول على الحرف السابق
  String? _getPreviousLetter() {
    final currentIndex = arabicLetters.indexWhere(
      (l) => l.letter == widget.letter,
    );
    if (currentIndex <= 0) {
      return null; // أول حرف
    }
    return arabicLetters[currentIndex - 1].letter;
  }

  /// الانتقال للحرف التالي
  void _goToNextLetter() {
    final nextLetter = _getNextLetter();
    Navigator.pop(context); // أغلق الصفحة الحالية
    Navigator.push(
      context,
      AnimatedRoute.fadeScale(LetterTracingView(letter: nextLetter)),
    );
  }

  /// الانتقال للحرف السابق
  void _goToPreviousLetter() {
    final previousLetter = _getPreviousLetter();
    if (previousLetter != null) {
      Navigator.pop(context); // أغلق الصفحة الحالية
      Navigator.push(
        context,
        AnimatedRoute.fadeScale(LetterTracingView(letter: previousLetter)),
      );
    }
  }

  /// إظهار dialog النجاح
  void _showSuccessDialog() {
    final nextLetter = _getNextLetter();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.green.shade50,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 30),
            SizedBox(width: 8),
            Text(
              'أحسنت!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amber, size: 30),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'لقد أتقنت كتابة حرف "${widget.letter}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Text(
              widget.letter,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'الحرف التالي: $nextLetter',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetDrawing();
            },
            child: const Text('حاول مرة أخرى', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // أغلق الـ dialog
              _goToNextLetter(); // انتقل للحرف التالي
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'التالي',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (letterPath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تتبع الحرف'),
          backgroundColor: const Color(0xFF1A237E),
        ),
        body: const Center(
          child: Text('الحرف غير متوفر', style: TextStyle(fontSize: 24)),
        ),
      );
    }

    final previousLetter = _getPreviousLetter();
    final nextLetter = _getNextLetter();

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        title: Text(
          'تتبع حرف "${widget.letter}"',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          // زر الحرف السابق
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 24),
            onPressed: previousLetter != null ? _goToPreviousLetter : null,
            tooltip: previousLetter != null
                ? 'الحرف السابق: $previousLetter'
                : null,
          ),
          // زر إعادة
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: resetDrawing,
            tooltip: 'إعادة المحاولة',
          ),
          // زر الحرف التالي (دائماً متاح)
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 24),
            onPressed: _goToNextLetter,
            tooltip: 'الحرف التالي: $nextLetter',
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط التقدم
          _buildProgressBar(),

          const SizedBox(height: 20),

          // التعليمات
          _buildInstructions(),

          const Spacer(),

          // منطقة الرسم
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isCompleted ? _scaleAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 320,
                height: 360,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GestureDetector(
                    onPanStart: (details) => onPanStart(details.localPosition),
                    onPanUpdate: (details) =>
                        onPanUpdate(details.localPosition),
                    onPanEnd: (details) => onPanEnd(),
                    child: CustomPaint(
                      size: const Size(320, 360),
                      painter: LetterTracePainter(
                        guideStrokes: letterPath!.strokes,
                        guideDots: letterPath!.dots,
                        userPath: userPath,
                        isCompleted: isCompleted,
                        currentStrokeIndex: currentStrokeIndex,
                        currentFingerPosition: currentFingerPosition,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // أزرار التحكم
          _buildControlButtons(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// شريط التقدم
  Widget _buildProgressBar() {
    if (letterPath == null) return const SizedBox.shrink();

    int totalPoints = 0;
    for (var stroke in letterPath!.strokes) {
      totalPoints += stroke.length;
    }

    double progress = totalPoints > 0 ? userPath.length / totalPoints : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم: ${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Stroke ${currentStrokeIndex + 1}/${letterPath!.strokes.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// التعليمات
  Widget _buildInstructions() {
    String instruction = '';
    IconData icon = Icons.touch_app;

    if (isCompleted) {
      instruction = 'ممتاز! لقد أتقنت الحرف! 🎉';
      icon = Icons.check_circle;
    } else if (userPath.isEmpty) {
      instruction = 'ابدأ من الدائرة الخضراء 🟢\n(النقاط سترسم تلقائياً)';
      icon = Icons.touch_app;
    } else {
      instruction = 'استمر في التتبع... 👆\n(النقاط سترسم تلقائياً)';
      icon = Icons.trending_up;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.blue,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isCompleted ? Colors.green : Colors.blue, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                color: isCompleted ? Colors.green : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// أزرار التحكم
  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: resetDrawing,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _goToNextLetter,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('التالي', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
