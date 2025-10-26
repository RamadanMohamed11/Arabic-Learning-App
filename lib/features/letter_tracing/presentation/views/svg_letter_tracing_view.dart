import 'package:flutter/material.dart';
import 'package:arabic_learning_app/features/letter_tracing/data/svg_letter_paths.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/widgets/svg_letter_trace_painter.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SvgLetterTracingView extends StatefulWidget {
  final String letter;

  const SvgLetterTracingView({super.key, required this.letter});

  @override
  State<SvgLetterTracingView> createState() => _SvgLetterTracingViewState();
}

class _SvgLetterTracingViewState extends State<SvgLetterTracingView>
    with SingleTickerProviderStateMixin {
  // بيانات الحرف من SVG
  SvgLetterPath? letterPath;
  bool isLoading = true;

  // حالة التتبع
  List<Offset> userPath = [];
  int currentPathIndex = 0; // أي path نرسم الآن
  bool isCompleted = false;
  Offset? currentFingerPosition;

  // Animation للنجاح
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  // TTS
  final FlutterTts _flutterTts = FlutterTts();

  // إعدادات الحساسية
  final double touchTolerance = 40.0; // المسافة المسموحة للخطأ

  @override
  void initState() {
    super.initState();
    _loadLetterPath();
    _initTts();

    // تهيئة animation
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _loadLetterPath() async {
    final path = await SvgLetterPathManager.getPath(widget.letter);
    setState(() {
      letterPath = path;
      isLoading = false;
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  /// إعادة تعيين الرسم
  void resetDrawing() {
    setState(() {
      userPath.clear();
      currentPathIndex = 0;
      isCompleted = false;
      currentFingerPosition = null;
    });
    _celebrationController.reset();
  }

  /// معالجة بداية اللمس
  void onPanStart(Offset position) {
    if (isCompleted || letterPath == null) return;
    if (currentPathIndex >= letterPath!.paths.length) return;

    final currentPath = letterPath!.paths[currentPathIndex];

    // تحقق من أن المستخدم بدأ بالقرب من بداية المسار
    final pathMetrics = currentPath.computeMetrics().first;
    final startPoint = pathMetrics.getTangentForOffset(0)?.position;

    if (startPoint != null) {
      final distance = (position - startPoint).distance;
      if (distance > touchTolerance) {
        // بعيد جداً عن نقطة البداية
        return;
      }
    }

    setState(() {
      userPath.clear();
      userPath.add(position);
      currentFingerPosition = position;
    });
  }

  /// معالجة حركة اللمس
  void onPanUpdate(Offset position) {
    if (isCompleted || letterPath == null) return;
    if (currentPathIndex >= letterPath!.paths.length) return;

    setState(() {
      userPath.add(position);
      currentFingerPosition = position;
    });

    // تحقق من التقدم
    _checkProgress();
  }

  /// معالجة نهاية اللمس
  void onPanEnd() {
    setState(() {
      currentFingerPosition = null;
    });
  }

  /// التحقق من التقدم
  void _checkProgress() {
    if (letterPath == null || userPath.isEmpty) return;
    if (currentPathIndex >= letterPath!.paths.length) return;

    final currentPath = letterPath!.paths[currentPathIndex];
    final pathMetrics = currentPath.computeMetrics().first;

    // حساب نسبة الإكمال
    double totalCoverage = 0;
    int samplesCount = 0;

    // عينات على طول المسار
    for (double i = 0; i <= pathMetrics.length; i += 10) {
      final tangent = pathMetrics.getTangentForOffset(i);
      if (tangent == null) continue;

      final pathPoint = tangent.position;
      samplesCount++;

      // تحقق من أن المستخدم مر بالقرب من هذه النقطة
      bool covered = false;
      for (final userPoint in userPath) {
        final distance = (userPoint - pathPoint).distance;
        if (distance < touchTolerance) {
          covered = true;
          break;
        }
      }

      if (covered) {
        totalCoverage++;
      }
    }

    // إذا غطى المستخدم 80% من المسار
    final coverageRatio = totalCoverage / samplesCount;
    if (coverageRatio >= 0.8) {
      _completeCurrentPath();
    }
  }

  /// إكمال المسار الحالي
  void _completeCurrentPath() {
    setState(() {
      currentPathIndex++;
      userPath.clear();

      // تحقق من إكمال جميع المسارات
      if (currentPathIndex >= letterPath!.paths.length) {
        isCompleted = true;
        _celebrationController.forward();
        _speak('أحسنت! لقد أتقنت كتابة حرف ${widget.letter}');
        _showSuccessDialog();
      }
    });
  }

  /// إظهار dialog النجاح
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('🌟 أحسنت! 🌟')],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'لقد أتقنت كتابة حرف "${widget.letter}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              widget.letter,
              style: const TextStyle(
                fontSize: 80,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              resetDrawing();
            },
            child: const Text('حاول مرة أخرى', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goToNextLetter();
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

  /// الحصول على الحرف التالي
  String _getNextLetter() {
    final currentIndex = arabicLetters.indexWhere(
      (l) => l.letter == widget.letter,
    );
    if (currentIndex >= arabicLetters.length - 1) {
      return arabicLetters.first.letter; // العودة للبداية
    }
    return arabicLetters[currentIndex + 1].letter;
  }

  /// الحصول على الحرف السابق
  String? _getPreviousLetter() {
    final currentIndex = arabicLetters.indexWhere(
      (l) => l.letter == widget.letter,
    );
    if (currentIndex <= 0) {
      return null;
    }
    return arabicLetters[currentIndex - 1].letter;
  }

  /// الانتقال للحرف التالي
  void _goToNextLetter() {
    final nextLetter = _getNextLetter();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SvgLetterTracingView(letter: nextLetter),
      ),
    );
  }

  /// الانتقال للحرف السابق
  void _goToPreviousLetter() {
    final previousLetter = _getPreviousLetter();
    if (previousLetter != null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SvgLetterTracingView(letter: previousLetter),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('تتبع حرف ${widget.letter}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (letterPath == null) {
      return Scaffold(
        appBar: AppBar(title: Text('تتبع حرف ${widget.letter}')),
        body: const Center(
          child: Text('الحرف غير متوفر', style: TextStyle(fontSize: 24)),
        ),
      );
    }

    final progress = currentPathIndex / letterPath!.paths.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('تتبع حرف ${widget.letter}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_getPreviousLetter() != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goToPreviousLetter,
              tooltip: 'الحرف السابق',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetDrawing,
            tooltip: 'إعادة',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goToNextLetter,
            tooltip: 'الحرف التالي',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // شريط التقدم
            _buildProgressBar(progress),
            const SizedBox(height: 10),

            // التعليمات
            _buildInstructions(),
            const SizedBox(height: 20),

            // منطقة الرسم
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: isCompleted
                      ? _scaleAnimation
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 350,
                    height: 450,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GestureDetector(
                        onPanStart: (details) =>
                            onPanStart(details.localPosition),
                        onPanUpdate: (details) =>
                            onPanUpdate(details.localPosition),
                        onPanEnd: (_) => onPanEnd(),
                        child: CustomPaint(
                          painter: SvgLetterTracePainter(
                            guidePaths: letterPath!.paths,
                            userPath: userPath,
                            isCompleted: isCompleted,
                            currentPathIndex: currentPathIndex,
                            currentFingerPosition: currentFingerPosition,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // أزرار التحكم
            _buildControlButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// شريط التقدم
  Widget _buildProgressBar(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم: ${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Text(
                'المسار ${currentPathIndex + 1}/${letterPath!.paths.length}',
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
      instruction = 'ابدأ من الدائرة الخضراء 🟢';
      icon = Icons.touch_app;
    } else {
      instruction = 'استمر في التتبع... 👆';
      icon = Icons.trending_up;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.blue,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: isCompleted ? Colors.green : Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCompleted
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
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
