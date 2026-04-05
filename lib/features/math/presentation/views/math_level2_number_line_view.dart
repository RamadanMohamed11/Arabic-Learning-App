import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';

class _OrderRound {
  final List<int> scrambled;
  final List<int> correct;

  const _OrderRound({required this.scrambled, required this.correct});
}

class MathLevel2NumberLineView extends StatefulWidget {
  const MathLevel2NumberLineView({super.key});

  @override
  State<MathLevel2NumberLineView> createState() =>
      _MathLevel2NumberLineViewState();
}

class _MathLevel2NumberLineViewState extends State<MathLevel2NumberLineView>
    with TickerProviderStateMixin {
  final List<_OrderRound> _rounds = [
    _OrderRound(
      scrambled: [20, 10, 50, 30, 40],
      correct: [10, 20, 30, 40, 50],
    ),
    _OrderRound(
      scrambled: [60, 90, 70, 50, 100, 80],
      correct: [50, 60, 70, 80, 90, 100],
    ),
  ];

  int _currentRound = 0;
  int _score = 0;
  bool _isComplete = false;
  bool _roundCorrect = false;

  late List<int> _currentOrder;
  late List<int?> _answerSlots;
  late Set<int> _usedIndices;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initRound();
    _playIntro();
  }

  Future<void> _playIntro() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'رتب مضاعفات العشرة على خط الأعداد. اضغط على الأرقام بالترتيب الصحيح من الأصغر إلى الأكبر!',
      isMounted: () => mounted,
    );
  }

  void _initRound() {
    final round = _rounds[_currentRound];
    _currentOrder = List.from(round.scrambled);
    _answerSlots = List.filled(round.correct.length, null);
    _usedIndices = {};
    _roundCorrect = false;
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onNumberTapped(int index) {
    if (_roundCorrect || _usedIndices.contains(index)) return;

    final number = _currentOrder[index];
    final nextSlotIndex = _answerSlots.indexOf(null);
    if (nextSlotIndex == -1) return;

    final expectedNumber = _rounds[_currentRound].correct[nextSlotIndex];

    if (number == expectedNumber) {
      setState(() {
        _answerSlots[nextSlotIndex] = number;
        _usedIndices.add(index);
      });

      final name = _arabicTensNames[number] ?? number.toArabicDigits();
      AppTtsService.instance.speak(name);

      if (!_answerSlots.contains(null)) {
        _onRoundComplete();
      }
    } else {
      _shakeController.forward().then((_) => _shakeController.reset());
      AppTtsService.instance.speak('حاول مرة أخرى');
    }
  }

  Future<void> _onRoundComplete() async {
    _score++;
    setState(() {
      _roundCorrect = true;
    });

    await AppTtsService.instance.speak('أحسنت! ترتيب صحيح');
    if (!mounted) return;

    if (_currentRound < _rounds.length - 1) {
      setState(() {
        _currentRound++;
        _initRound();
      });

      if (mounted) {
        await AppTtsService.instance.speak('رتب المضاعفات التالية على خط الأعداد');
      }
    } else {
      setState(() {
        _isComplete = true;
      });
      await AppTtsService.instance.speak(
        'ممتاز! لقد أكملت نشاط ترتيب المضاعفات بنجاح!',
      );
    }
  }

  void _resetRound() {
    setState(() {
      _initRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return _buildResults();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خط الأعداد (${(_currentRound + 1).toArabicDigits()}/${_rounds.length.toArabicDigits()})',
        ),
        backgroundColor: AppColors.level2[0],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetRound,
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
              AppColors.level2[0].withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Instruction
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.level2[0].withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.level2[0], width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      _roundCorrect ? Icons.check_circle : Icons.timeline,
                      color: _roundCorrect
                          ? Colors.green
                          : AppColors.level2[0],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _roundCorrect
                            ? 'أحسنت! الترتيب صحيح 🎉'
                            : 'رتب المضاعفات على خط الأعداد ⬆️',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _roundCorrect
                              ? Colors.green.shade700
                              : AppColors.level2[0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Number line slots
              _buildNumberLine(),

              const SizedBox(height: 30),

              // Arrow
              Icon(
                Icons.arrow_upward,
                size: 36,
                color: AppColors.level2[0].withValues(alpha: 0.5),
              ),
              Text(
                'اختر بالترتيب من الأصغر',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.level2[0].withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // Number buttons
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value *
                          ((_shakeController.status == AnimationStatus.forward)
                              ? 1
                              : -1),
                      0,
                    ),
                    child: child,
                  );
                },
                child: _buildNumberButtons(),
              ),

              const Spacer(),

              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberLine() {
    final round = _rounds[_currentRound];
    final count = round.correct.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // The number line with slots
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth - 20;
              final slotWidth = ((availableWidth / count) - 8).clamp(48.0, 72.0);
              final slotHeight = slotWidth;

              return Column(
                children: [
                  // Slots row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(count, (index) {
                      final hasValue = _answerSlots[index] != null;
                      final isNextSlot = index == _answerSlots.indexOf(null);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: slotWidth,
                        height: slotHeight,
                        decoration: BoxDecoration(
                          color: hasValue
                              ? Colors.green.shade400
                              : isNextSlot
                                  ? AppColors.level2[0].withValues(alpha: 0.15)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: hasValue
                                ? Colors.green.shade600
                                : isNextSlot
                                    ? AppColors.level2[0]
                                    : AppColors.level2[0]
                                        .withValues(alpha: 0.3),
                            width: isNextSlot ? 3 : 2.5,
                          ),
                          boxShadow: [
                            if (hasValue)
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            if (isNextSlot)
                              BoxShadow(
                                color: AppColors.level2[0]
                                    .withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Center(
                          child: hasValue
                              ? Text(
                                  _answerSlots[index]!.toArabicDigits(),
                                  style: TextStyle(
                                    fontSize: slotWidth > 60 ? 26 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : isNextSlot
                                  ? ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Text(
                                        '؟',
                                        style: TextStyle(
                                          fontSize: slotWidth > 60 ? 24 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.level2[0]
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '؟',
                                      style: TextStyle(
                                        fontSize: slotWidth > 60 ? 20 : 16,
                                        color: AppColors.level2[0]
                                            .withValues(alpha: 0.25),
                                      ),
                                    ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 8),

                  // The actual number line bar
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.level2[0].withValues(alpha: 0.3),
                          AppColors.level2[0],
                          AppColors.level2[1],
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Tick marks and labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(count, (index) {
                      return SizedBox(
                        width: slotWidth,
                        child: Column(
                          children: [
                            Container(
                              width: 2,
                              height: 10,
                              color: AppColors.level2[0].withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (index + 1).toArabicDigits(),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.level2[0]
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: List.generate(_currentOrder.length, (index) {
          final isUsed = _usedIndices.contains(index);
          return GestureDetector(
            onTap: isUsed ? null : () => _onNumberTapped(index),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isUsed ? 0.3 : 1.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isUsed ? 0.85 : 1.0,
                child: Container(
                  width: 80,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: isUsed
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade400,
                            ],
                          )
                        : LinearGradient(
                            colors: AppColors.level2,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isUsed
                        ? []
                        : [
                            BoxShadow(
                              color:
                                  AppColors.level2[0].withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      _currentOrder[index].toArabicDigits(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isUsed ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_rounds.length, (index) {
          Color color;
          if (index < _currentRound) {
            color = Colors.green;
          } else if (index == _currentRound) {
            color = AppColors.level2[0];
          } else {
            color = Colors.grey.shade300;
          }

          return Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: index == _currentRound
                  ? Border.all(color: AppColors.level2[0], width: 2)
                  : null,
            ),
          );
        }),
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
                const Text('🏆', style: TextStyle(fontSize: 80)),
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
                  'لقد أكملت ترتيب المضاعفات على خط الأعداد',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
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

/// Arabic tens names for TTS
const Map<int, String> _arabicTensNames = {
  10: 'عشرة',
  20: 'عشرون',
  30: 'ثلاثون',
  40: 'أربعون',
  50: 'خمسون',
  60: 'ستون',
  70: 'سبعون',
  80: 'ثمانون',
  90: 'تسعون',
  100: 'مائة',
};
