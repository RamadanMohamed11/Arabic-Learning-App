import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';

class MathLevel2CountByTenView extends StatefulWidget {
  const MathLevel2CountByTenView({super.key});

  @override
  State<MathLevel2CountByTenView> createState() =>
      _MathLevel2CountByTenViewState();
}

class _MathLevel2CountByTenViewState extends State<MathLevel2CountByTenView>
    with TickerProviderStateMixin {
  final List<int> _availableNumbers = [
    10,
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100
  ];
  int _currentStep = 0;
  bool _isComplete = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _celebrationController;

  static const double circleSize = 55.0;

  @override
  void initState() {
    super.initState();
    _availableNumbers.shuffle();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppTtsService.instance.speakScreenIntro(
        'رتب مضاعفات العشرة بشكل متسلسل من البداية',
        isMounted: () => mounted,
      );
    });
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Offset _getCircleOffset(int index, Size size) {
    // theta goes from pi downwards to 0
    double theta = math.pi - (index / 9.0) * math.pi;
    // x uses cos to spread out points at the bottom (around pi/2)
    double x = 0.5 + 0.45 * math.cos(theta); // x from 0.05 to 0.95
    // y uses sin for the U-shape arc
    double y = 0.15 + 0.7 * math.sin(theta); // y from 0.15 to 0.85
    return Offset(x * size.width, y * size.height);
  }

  void _handleCorrectPlacement(int targetNumber) async {
    setState(() {
      _availableNumbers.remove(targetNumber);
      _currentStep++;
    });

    final String arabicName = _getArabicName(targetNumber);
    await AppTtsService.instance.speak(arabicName);

    if (_currentStep == 10) {
      _celebrationController.forward();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _isComplete = true;
      });
      await AppTtsService.instance.speak("ممتاز! لقد رتبت الأرقام بنجاح");
    }
  }

  String _getArabicName(int numberValue) {
    switch (numberValue) {
      case 10:
        return 'عشرة';
      case 20:
        return 'عشرون';
      case 30:
        return 'ثلاثون';
      case 40:
        return 'أربعون';
      case 50:
        return 'خمسون';
      case 60:
        return 'ستون';
      case 70:
        return 'سبعون';
      case 80:
        return 'ثمانون';
      case 90:
        return 'تسعون';
      case 100:
        return 'مائة';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return _buildResults();

    return Scaffold(
      appBar: AppBar(
        title: const Text('العد بالعشرات'),
        backgroundColor: AppColors.level2[0],
        foregroundColor: Colors.white,
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.level2[0].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.level2[0], width: 2),
              ),
              child: Text(
                'اسحب الأرقام لتكمل السلسلة (${(_currentStep).toArabicDigits()}/١٠)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.level2[0],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 3,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final points = List.generate(
                    10,
                    (index) => _getCircleOffset(index, size),
                  );

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CaterpillarLinePainter(points: points),
                        ),
                      ),
                      ...List.generate(10, (index) {
                        return _buildCircle(index, size);
                      }),
                    ],
                  );
                },
              ),
            ),
            // Draggable Area
            Expanded(
              flex: 2,
              child: _buildDraggableItems(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(int index, Size size) {
    final offset = _getCircleOffset(index, size);
    final targetNumber = (index + 1) * 10;
    final isPlaced = _currentStep > index;
    final isCurrent = _currentStep == index;

    return Positioned(
      left: offset.dx - circleSize / 2,
      top: offset.dy - circleSize / 2,
      child: isPlaced
          ? _buildPlacedCircle(targetNumber)
          : isCurrent
              ? _buildCurrentTarget(targetNumber)
              : _buildLockedCircle(),
    );
  }

  Widget _buildCurrentTarget(int targetNumber) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        if (details.data == targetNumber) {
          _handleCorrectPlacement(targetNumber);
        } else {
          AppTtsService.instance.speak("حاول مرة أخرى");
        }
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovered = candidateData.isNotEmpty;
        return ScaleTransition(
          scale:
              isHovered ? const AlwaysStoppedAnimation(1.2) : _pulseAnimation,
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHovered
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.white,
              border: Border.all(
                color: isHovered ? Colors.green : AppColors.level2[0],
                width: 3,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                if (!isHovered)
                  BoxShadow(
                    color: AppColors.level2[0].withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
              ],
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: AppColors.level2[0].withValues(alpha: 0.5),
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlacedCircle(int number) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.level2[0],
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.level2[0].withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          number.toArabicDigits(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLockedCircle() {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.7),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline,
          color: Colors.grey.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDraggableItems() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _availableNumbers.map((numberValue) {
          return Draggable<int>(
            data: numberValue,
            feedback: _buildDraggableItem(numberValue, isDragging: true),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildDraggableItem(numberValue),
            ),
            child: _buildDraggableItem(numberValue),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDraggableItem(int numberValue, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isDragging ? AppColors.level2[1] : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.level2[0],
            width: 2,
          ),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: AppColors.level2[1].withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Center(
          child: Text(
            numberValue.toArabicDigits(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDragging ? Colors.white : AppColors.level2[0],
            ),
          ),
        ),
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
                  'لقد أكملت نشاط العد بالعشرات',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.check),
                  label: const Text('إنهاء', style: TextStyle(fontSize: 20)),
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

class _CaterpillarLinePainter extends CustomPainter {
  final List<Offset> points;

  _CaterpillarLinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.level2[0].withValues(alpha: 0.4)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    // Create a smooth curve between points using quadratic bezier
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

      if (i == 0) {
        path.lineTo(midPoint.dx, midPoint.dy);
      } else {
        path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
      }
    }
    // Connect to the last point
    path.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CaterpillarLinePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
