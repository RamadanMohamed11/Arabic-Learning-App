import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';

class _OrderRound {
  final List<int> scrambled;
  final List<int> correct;

  const _OrderRound({required this.scrambled, required this.correct});
}

class NumberOrderingView extends StatefulWidget {
  const NumberOrderingView({super.key});

  @override
  State<NumberOrderingView> createState() => _NumberOrderingViewState();
}

class _NumberOrderingViewState extends State<NumberOrderingView>
    with TickerProviderStateMixin {
  final List<_OrderRound> _rounds = [
    _OrderRound(scrambled: [2, 5, 3, 4, 1], correct: [1, 2, 3, 4, 5]),
    _OrderRound(scrambled: [9, 10, 7, 8, 6], correct: [6, 7, 8, 9, 10]),
    _OrderRound(scrambled: [4, 8, 6, 5, 7], correct: [4, 5, 6, 7, 8]),
  ];

  int _currentRound = 0;
  int _score = 0;
  bool _isComplete = false;
  bool _roundCorrect = false;

  late List<int> _currentOrder;
  late List<int> _answerSlots;
  late Set<int> _usedIndices;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

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
    _initRound();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await AppTtsService.instance.speak(
        'رتب الأرقام من الأصغر إلى الأكبر. اضغط على الأرقام بالترتيب الصحيح!',
      );
    }
  }

  void _initRound() {
    final round = _rounds[_currentRound];
    _currentOrder = List.from(round.scrambled);
    _answerSlots = [];
    _usedIndices = {};
    _roundCorrect = false;
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberTapped(int index) {
    if (_roundCorrect || _usedIndices.contains(index)) return;

    final number = _currentOrder[index];
    final expectedNumber = _rounds[_currentRound].correct[_answerSlots.length];

    if (number == expectedNumber) {
      // Correct
      setState(() {
        _answerSlots.add(number);
        _usedIndices.add(index);
      });

      // Speak the number
      final name = _arabicNumberNames[number] ?? number.toArabicDigits();
      AppTtsService.instance.speak(name);

      // Check if round complete
      if (_answerSlots.length == _rounds[_currentRound].correct.length) {
        _onRoundComplete();
      }
    } else {
      // Wrong - shake
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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_currentRound < _rounds.length - 1) {
      setState(() {
        _currentRound++;
        _initRound();
      });

      // Play next round instruction
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await AppTtsService.instance.speak('رتب الأرقام التالية');
      }
    } else {
      setState(() {
        _isComplete = true;
      });
      await AppTtsService.instance.speak(
        'ممتاز! لقد أكملت نشاط ترتيب الأرقام بنجاح!',
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

    final round = _rounds[_currentRound];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ترتيب الأرقام (${(_currentRound + 1).toArabicDigits()}/${_rounds.length.toArabicDigits()})',
        ),
        backgroundColor: AppColors.level1[0],
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
            colors: [AppColors.level1[0].withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Instruction text
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.level1[0].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.level1[0], width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      _roundCorrect ? Icons.check_circle : Icons.sort,
                      color: _roundCorrect ? Colors.green : AppColors.level1[0],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _roundCorrect
                            ? 'أحسنت! الترتيب صحيح 🎉'
                            : 'رتب الأرقام من الأصغر إلى الأكبر ⬆️',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _roundCorrect
                              ? Colors.green.shade700
                              : AppColors.level1[0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Answer slots
              _buildAnswerSlots(round),

              const SizedBox(height: 40),

              // Arrow
              Icon(
                Icons.arrow_upward,
                size: 36,
                color: AppColors.level1[0].withOpacity(0.5),
              ),
              Text(
                'اختر بالترتيب',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.level1[0].withOpacity(0.7),
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

  Widget _buildAnswerSlots(_OrderRound round) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate slot size to always fit within screen
        const double totalHPadding = 40;
        const double minSpacing = 6;
        final int count = round.correct.length;
        final double availableWidth = constraints.maxWidth - totalHPadding;
        final double slotSize =
            ((availableWidth - (minSpacing * 2 * count)) / count).clamp(
              40.0,
              64.0,
            );
        final double fontSize = slotSize > 55 ? 28 : 22;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final hasValue = index < _answerSlots.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: slotSize,
                height: slotSize,
                margin: const EdgeInsets.symmetric(horizontal: minSpacing),
                decoration: BoxDecoration(
                  color: hasValue ? Colors.green.shade400 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasValue
                        ? Colors.green.shade600
                        : AppColors.level1[0].withOpacity(0.4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    if (hasValue)
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: hasValue
                      ? Text(
                          _answerSlots[index].toArabicDigits(),
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          (index + 1).toArabicDigits(),
                          style: TextStyle(
                            fontSize: fontSize * 0.65,
                            color: AppColors.level1[0].withOpacity(0.3),
                          ),
                        ),
                ),
              );
            }),
          ),
        );
      },
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
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: isUsed
                      ? LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        )
                      : LinearGradient(
                          colors: AppColors.level1,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isUsed
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.level1[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    _currentOrder[index].toArabicDigits(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isUsed ? Colors.grey : Colors.white,
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
            color = AppColors.level1[0];
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
                  ? Border.all(color: AppColors.level1[0], width: 2)
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
            colors: [AppColors.level1[0], AppColors.level1[1]],
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
                  'لقد أكملت نشاط ترتيب الأرقام',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.9),
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
                  label: const Text('إنهاء', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.level1[0],
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
