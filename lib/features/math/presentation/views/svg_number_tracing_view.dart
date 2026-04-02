import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/svg_number_paths.dart';
import 'package:arabic_learning_app/features/math/data/models/math_number_model.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/widgets/svg_letter_trace_painter.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

/// Arabic number names for TTS
const Map<int, String> _arabicNumberNames = {
  1: 'واحد',
  2: 'اثنان',
  3: 'ثلاثة',
  4: 'أربعة',
  5: 'خمسة',
  6: 'ستة',
  7: 'سبعة',
  8: 'ثمانية',
  9: 'تسعة',
  10: 'عشرة',
};

class SvgNumberTracingView extends StatefulWidget {
  final MathNumberModel numberModel;
  final MathLevelModel levelModel;

  const SvgNumberTracingView({
    super.key,
    required this.numberModel,
    required this.levelModel,
  });

  @override
  State<SvgNumberTracingView> createState() => _SvgNumberTracingViewState();
}

class _SvgNumberTracingViewState extends State<SvgNumberTracingView>
    with SingleTickerProviderStateMixin {
  // أبعاد منطقة الرسم
  static const double _canvasWidth = 350;
  static const double _canvasHeight = 450;

  // بيانات الرقم من SVG
  SvgNumberPath? numberPath;
  bool isLoading = true;

  // حالة التتبع
  List<Offset> userPath = [];
  int currentPathIndex = 0;
  bool isCompleted = false;
  Offset? currentFingerPosition;

  // Animation للنجاح
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  // Progress service
  MathProgressService? _progressService;

  // إعدادات الحساسية
  final double touchTolerance = 40.0;

  @override
  void initState() {
    super.initState();
    _loadNumberPath();
    _initProgress();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    // TTS intro
    _speakIntro();
  }

  Future<void> _speakIntro() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final name =
          _arabicNumberNames[widget.numberModel.number] ??
          widget.numberModel.label;
      await AppTtsService.instance.speak('تتبع الرقم $name بإصبعك');
    }
  }

  Future<void> _loadNumberPath() async {
    final path = await SvgNumberPathManager.getPath(
      widget.numberModel.number,
      canvasWidth: _canvasWidth,
      canvasHeight: _canvasHeight,
    );
    if (mounted) {
      setState(() {
        numberPath = path;
        isLoading = false;
      });
    }
  }

  Future<void> _initProgress() async {
    _progressService = await MathProgressService.getInstance();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
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
    if (isCompleted || numberPath == null) return;
    if (currentPathIndex >= numberPath!.paths.length) return;

    final currentPath = numberPath!.paths[currentPathIndex];
    final pathMetrics = currentPath.computeMetrics().first;
    final startPoint = pathMetrics.getTangentForOffset(0)?.position;

    if (startPoint != null) {
      final distance = (position - startPoint).distance;
      if (distance > touchTolerance) return;
    }

    setState(() {
      userPath.clear();
      userPath.add(position);
      currentFingerPosition = position;
    });
  }

  /// معالجة حركة اللمس
  void onPanUpdate(Offset position) {
    if (isCompleted || numberPath == null) return;
    if (currentPathIndex >= numberPath!.paths.length) return;

    setState(() {
      userPath.add(position);
      currentFingerPosition = position;
    });

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
    if (numberPath == null || userPath.isEmpty) return;
    if (currentPathIndex >= numberPath!.paths.length) return;

    final currentPath = numberPath!.paths[currentPathIndex];
    final pathMetrics = currentPath.computeMetrics().first;

    double totalCoverage = 0;
    int samplesCount = 0;

    for (double i = 0; i <= pathMetrics.length; i += 10) {
      final tangent = pathMetrics.getTangentForOffset(i);
      if (tangent == null) continue;

      final pathPoint = tangent.position;
      samplesCount++;

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

    final coverageRatio = samplesCount > 0 ? totalCoverage / samplesCount : 0.0;
    if (coverageRatio >= 0.9) {
      _completeCurrentPath();
    }
  }

  /// إكمال المسار الحالي
  void _completeCurrentPath() {
    setState(() {
      currentPathIndex++;
      userPath.clear();

      if (currentPathIndex >= numberPath!.paths.length) {
        isCompleted = true;
        _celebrationController.forward();
        _onTracingCompleted();
      }
    });
  }

  /// عند إكمال التتبع بنجاح
  Future<void> _onTracingCompleted() async {
    final name =
        _arabicNumberNames[widget.numberModel.number] ??
        widget.numberModel.label;
    await AppTtsService.instance.speak('أحسنت! لقد أتقنت كتابة رقم $name');

    if (_progressService != null) {
      // Mark all activities as completed for this number (tracing is the only one)
      for (int i = 0; i < 4; i++) {
        await _progressService!.completeActivity(
          widget.levelModel.level,
          widget.numberModel.number,
          i,
        );
      }

      // Unlock the next number or mark level complete
      await _unlockNextNumber();
    }

    if (mounted) {
      _showSuccessDialog();
    }
  }

  /// Unlock the next number in this level, or mark the level as complete
  Future<void> _unlockNextNumber() async {
    if (_progressService == null) return;

    final currentIdx = widget.levelModel.numbers.indexWhere(
      (n) => n.number == widget.numberModel.number,
    );

    if (currentIdx == -1) return;

    if (currentIdx + 1 < widget.levelModel.numbers.length) {
      // Unlock the next number
      final nextNumber = widget.levelModel.numbers[currentIdx + 1].number;
      await _progressService!.unlockNumber(
        widget.levelModel.level,
        nextNumber,
      );
    } else {
      // All numbers completed — mark level done
      if (widget.levelModel.level == 1) {
        await _progressService!.setLevel1Completed(true);
      } else if (widget.levelModel.level == 2) {
        await _progressService!.setLevel2Completed(true);
      } else if (widget.levelModel.level == 3) {
        await _progressService!.setLevel3Completed(true);
      }
    }
  }

  /// Get the next number model (if any)
  MathNumberModel? _getNextNumberModel() {
    final currentIdx = widget.levelModel.numbers.indexWhere(
      (n) => n.number == widget.numberModel.number,
    );
    if (currentIdx == -1 ||
        currentIdx + 1 >= widget.levelModel.numbers.length) {
      return null;
    }
    return widget.levelModel.numbers[currentIdx + 1];
  }

  /// إظهار dialog النجاح
  void _showSuccessDialog() {
    final nextNumber = _getNextNumberModel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('🌟 أحسنت! 🌟')],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'لقد أتقنت كتابة الرقم ${widget.numberModel.label}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              widget.numberModel.label,
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
              Navigator.pop(ctx); // close dialog
              resetDrawing();
            },
            child: const Text('حاول مرة أخرى', style: TextStyle(fontSize: 18)),
          ),
          if (nextNumber != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                Navigator.pushReplacement(
                  context,
                  AnimatedRoute.slideRight(
                    SvgNumberTracingView(
                      numberModel: nextNumber,
                      levelModel: widget.levelModel,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'التالي: ${nextNumber.label}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                Navigator.pop(context); // back to numbers
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'أحسنت! انتهيت من المستوى 🎉',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  List<Color> get _levelColors {
    if (widget.levelModel.level == 1) return AppColors.level1;
    if (widget.levelModel.level == 2) return AppColors.level2;
    return AppColors.primaryGradient;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('تتبع الرقم ${widget.numberModel.label}'),
          backgroundColor: _levelColors[0],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (numberPath == null || numberPath!.paths.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('تتبع الرقم ${widget.numberModel.label}'),
          backgroundColor: _levelColors[0],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('الرقم غير متوفر للتتبع', style: TextStyle(fontSize: 24)),
        ),
      );
    }

    final progress = currentPathIndex / numberPath!.paths.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('تتبع الرقم ${widget.numberModel.label}'),
        backgroundColor: _levelColors[0],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetDrawing,
            tooltip: 'إعادة',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_levelColors[0].withOpacity(0.15), Colors.white],
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
                    width: _canvasWidth,
                    height: _canvasHeight,
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
                          size: const Size(_canvasWidth, _canvasHeight),
                          painter: SvgLetterTracePainter(
                            guidePaths: numberPath!.paths,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _levelColors[0],
                ),
              ),
              Text(
                'المسار ${currentPathIndex + 1}/${numberPath!.paths.length}',
                style: TextStyle(color: _levelColors[1], fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: _levelColors[0].withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : _levelColors[0],
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
      instruction = 'ممتاز! لقد أتقنت الرقم! 🎉';
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
            : _levelColors[0].withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted ? Colors.green : _levelColors[0],
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30,
            color: isCompleted ? Colors.green : _levelColors[0],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.green.shade700 : _levelColors[0],
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('رجوع', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _levelColors[0],
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
