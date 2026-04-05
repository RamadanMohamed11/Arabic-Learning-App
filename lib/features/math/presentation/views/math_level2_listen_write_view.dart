import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import 'package:arabic_learning_app/features/math/data/svg_number_paths.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/widgets/svg_letter_trace_painter.dart';

class _ListenWriteRound {
  final int number;
  final String arabicLabel;
  final String arabicName;

  const _ListenWriteRound({
    required this.number,
    required this.arabicLabel,
    required this.arabicName,
  });
}

class MathLevel2ListenWriteView extends StatefulWidget {
  const MathLevel2ListenWriteView({super.key});

  @override
  State<MathLevel2ListenWriteView> createState() =>
      _MathLevel2ListenWriteViewState();
}

class _MathLevel2ListenWriteViewState extends State<MathLevel2ListenWriteView>
    with SingleTickerProviderStateMixin {
  static const double _canvasWidth = 350;
  static const double _canvasHeight = 400;

  final List<_ListenWriteRound> _rounds = [
    _ListenWriteRound(
      number: 40,
      arabicLabel: 40.toArabicDigits(),
      arabicName: 'أربعون',
    ),
    _ListenWriteRound(
      number: 10,
      arabicLabel: 10.toArabicDigits(),
      arabicName: 'عشرة',
    ),
    _ListenWriteRound(
      number: 100,
      arabicLabel: 100.toArabicDigits(),
      arabicName: 'مائة',
    ),
    _ListenWriteRound(
      number: 60,
      arabicLabel: 60.toArabicDigits(),
      arabicName: 'ستون',
    ),
    _ListenWriteRound(
      number: 30,
      arabicLabel: 30.toArabicDigits(),
      arabicName: 'ثلاثون',
    ),
  ];

  int _currentRound = 0;
  int _score = 0;
  bool _isComplete = false;
  bool _hasListened = false;

  // Tracing state
  SvgNumberPath? _numberPath;
  bool _isLoadingPath = true;
  List<Offset> _userPath = [];
  int _currentPathIndex = 0;
  bool _isTracingComplete = false;
  Offset? _currentFingerPosition;
  final double _touchTolerance = 40.0;

  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );
    _initRound();
  }

  Future<void> _initRound() async {
    setState(() {
      _isLoadingPath = true;
      _isTracingComplete = false;
      _userPath = [];
      _currentPathIndex = 0;
      _currentFingerPosition = null;
      _hasListened = false;
    });
    _celebrationController.reset();

    // Load SVG path for current number
    final round = _rounds[_currentRound];
    final path = await SvgNumberPathManager.getPath(
      round.number,
      canvasWidth: _canvasWidth,
      canvasHeight: _canvasHeight,
    );

    if (mounted) {
      setState(() {
        _numberPath = path;
        _isLoadingPath = false;
      });
    }

    // Play instruction
    final instruction = _currentRound == 0
        ? 'اسمع الرقم ثم اكتبه، ${round.arabicName}'
        : round.arabicName;

    await AppTtsService.instance.speakScreenIntro(
      instruction,
      isMounted: () => mounted,
    );
    if (mounted) {
      setState(() {
        _hasListened = true;
      });
    }
  }

  Future<void> _playNumberSound() async {
    final round = _rounds[_currentRound];
    await AppTtsService.instance.speak(round.arabicName);
    setState(() {
      _hasListened = true;
    });
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    _celebrationController.dispose();
    super.dispose();
  }

  // --- Tracing logic ---
  void _onPanStart(Offset position) {
    if (_isTracingComplete || _numberPath == null) return;
    if (_currentPathIndex >= _numberPath!.paths.length) return;

    final currentPath = _numberPath!.paths[_currentPathIndex];
    final pathMetrics = currentPath.computeMetrics().first;
    final startPoint = pathMetrics.getTangentForOffset(0)?.position;

    if (startPoint != null) {
      final distance = (position - startPoint).distance;
      if (distance > _touchTolerance) return;
    }

    setState(() {
      _userPath.clear();
      _userPath.add(position);
      _currentFingerPosition = position;
    });
  }

  void _onPanUpdate(Offset position) {
    if (_isTracingComplete || _numberPath == null) return;
    if (_currentPathIndex >= _numberPath!.paths.length) return;

    setState(() {
      _userPath.add(position);
      _currentFingerPosition = position;
    });

    _checkProgress();
  }

  void _onPanEnd() {
    setState(() {
      _currentFingerPosition = null;
    });
  }

  void _checkProgress() {
    if (_numberPath == null || _userPath.isEmpty) return;
    if (_currentPathIndex >= _numberPath!.paths.length) return;

    final currentPath = _numberPath!.paths[_currentPathIndex];
    final pathMetrics = currentPath.computeMetrics().first;

    double totalCoverage = 0;
    int samplesCount = 0;

    for (double i = 0; i <= pathMetrics.length; i += 10) {
      final tangent = pathMetrics.getTangentForOffset(i);
      if (tangent == null) continue;

      final pathPoint = tangent.position;
      samplesCount++;

      bool covered = false;
      for (final userPoint in _userPath) {
        final distance = (userPoint - pathPoint).distance;
        if (distance < _touchTolerance) {
          covered = true;
          break;
        }
      }

      if (covered) {
        totalCoverage++;
      }
    }

    final coverageRatio =
        samplesCount > 0 ? totalCoverage / samplesCount : 0.0;
    if (coverageRatio >= 0.85) {
      _completeCurrentPath();
    }
  }

  void _completeCurrentPath() {
    setState(() {
      _currentPathIndex++;
      _userPath.clear();

      if (_currentPathIndex >= _numberPath!.paths.length) {
        _isTracingComplete = true;
        _celebrationController.forward();
        _onRoundCompleted();
      }
    });
  }

  Future<void> _onRoundCompleted() async {
    final round = _rounds[_currentRound];
    _score++;
    await AppTtsService.instance.speak(
      'أحسنت! لقد كتبت رقم ${round.arabicName} بشكل صحيح',
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (_currentRound < _rounds.length - 1) {
      setState(() {
        _currentRound++;
      });
      _initRound();
    } else {
      setState(() {
        _isComplete = true;
      });
      await AppTtsService.instance.speak(
        'ممتاز! لقد أكملت نشاط اسمع الرقم واكتبه بنجاح!',
      );
    }
  }

  void _resetTracing() {
    setState(() {
      _userPath.clear();
      _currentPathIndex = 0;
      _isTracingComplete = false;
      _currentFingerPosition = null;
    });
    _celebrationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return _buildResults();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اسمع واكتب (${(_currentRound + 1).toArabicDigits()}/${_rounds.length.toArabicDigits()})',
        ),
        backgroundColor: AppColors.level2[0],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTracing,
            tooltip: 'إعادة',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.level2[0].withValues(alpha: 0.15),
              Colors.white,
            ],
          ),
        ),
        child: _isLoadingPath
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 16),

                  // Listen button
                  _buildListenButton(),
                  const SizedBox(height: 12),

                  // Instructions
                  _buildInstructions(),
                  const SizedBox(height: 12),

                  // Progress: which path segment
                  if (_numberPath != null && _numberPath!.paths.length > 1)
                    _buildPathProgress(),

                  // Tracing canvas
                  Expanded(
                    child: Center(
                      child: ScaleTransition(
                        scale: _isTracingComplete
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
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: GestureDetector(
                              onPanStart: (details) =>
                                  _onPanStart(details.localPosition),
                              onPanUpdate: (details) =>
                                  _onPanUpdate(details.localPosition),
                              onPanEnd: (_) => _onPanEnd(),
                              child: _numberPath != null &&
                                      _numberPath!.paths.isNotEmpty
                                  ? CustomPaint(
                                      size: const Size(
                                        _canvasWidth,
                                        _canvasHeight,
                                      ),
                                      painter: SvgLetterTracePainter(
                                        guidePaths: _numberPath!.paths,
                                        userPath: _userPath,
                                        isCompleted: _isTracingComplete,
                                        currentPathIndex: _currentPathIndex,
                                        currentFingerPosition:
                                            _currentFingerPosition,
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        'الرقم غير متوفر للتتبع',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }

  Widget _buildListenButton() {
    return GestureDetector(
      onTap: _playNumberSound,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.level2[0], AppColors.level2[1]],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.level2[0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text(
              'اسمع الرقم 🔊',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    String instruction;
    IconData icon;

    if (_isTracingComplete) {
      instruction = 'ممتاز! لقد أتقنت الرقم! 🎉';
      icon = Icons.check_circle;
    } else if (!_hasListened) {
      instruction = 'اضغط على الزر لسماع الرقم أولاً 👆';
      icon = Icons.hearing;
    } else if (_userPath.isEmpty && _currentPathIndex == 0) {
      instruction = 'ابدأ من الدائرة الخضراء 🟢';
      icon = Icons.touch_app;
    } else {
      instruction = 'استمر في التتبع... 👆';
      icon = Icons.trending_up;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isTracingComplete
            ? Colors.green.withValues(alpha: 0.2)
            : AppColors.level2[0].withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isTracingComplete ? Colors.green : AppColors.level2[0],
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: _isTracingComplete ? Colors.green : AppColors.level2[0],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isTracingComplete
                    ? Colors.green.shade700
                    : AppColors.level2[0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathProgress() {
    final totalPaths = _numberPath!.paths.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'الجزء ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.level2[0],
              fontWeight: FontWeight.w600,
            ),
          ),
          ...List.generate(totalPaths, (index) {
            Color color;
            if (index < _currentPathIndex) {
              color = Colors.green;
            } else if (index == _currentPathIndex) {
              color = AppColors.level2[0];
            } else {
              color = Colors.grey.shade300;
            }
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: index == _currentPathIndex
                    ? Border.all(color: AppColors.level2[0], width: 2)
                    : null,
              ),
            );
          }),
          Text(
            ' (${(_currentPathIndex + 1).clamp(1, totalPaths).toArabicDigits()} / ${totalPaths.toArabicDigits()})',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.level2[0],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.level2[0], AppColors.level2[1]],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌟', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                const Text(
                  'أحسنت!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'لقد أكملت نشاط اسمع الرقم واكتبه',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_score.toArabicDigits()} / ${_rounds.length.toArabicDigits()}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.check),
                  label:
                      const Text('إنهاء', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.level2[0],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
