import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';

class _OrderRound {
  final List<int> scrambled;
  final List<int> correct;
  final bool isAscending;

  const _OrderRound({
    required this.scrambled,
    required this.correct,
    required this.isAscending,
  });
}

class MathLevel3OrderingView extends StatefulWidget {
  const MathLevel3OrderingView({super.key});

  @override
  State<MathLevel3OrderingView> createState() => _MathLevel3OrderingViewState();
}

class _MathLevel3OrderingViewState extends State<MathLevel3OrderingView>
    with TickerProviderStateMixin {
  final List<_OrderRound> _rounds = [
    const _OrderRound(scrambled: [34, 45, 23, 12, 56], correct: [12, 23, 34, 45, 56], isAscending: true),
    const _OrderRound(scrambled: [45, 56, 32, 21, 67], correct: [21, 32, 45, 56, 67], isAscending: true),
    const _OrderRound(scrambled: [89, 78, 90, 67, 56], correct: [90, 89, 78, 67, 56], isAscending: false),
    const _OrderRound(scrambled: [12, 34, 45, 23, 56], correct: [56, 45, 34, 23, 12], isAscending: false),
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
    _initRound();
    _playIntro();
  }

  Future<void> _playIntro() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'ترتيب الأرقام. رتب الأرقام كما هو مطلوب. تصاعدي أو تنازلي',
      isMounted: () => mounted,
    );
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
      setState(() {
        _answerSlots.add(number);
        _usedIndices.add(index);
      });

      if (_answerSlots.length == _rounds[_currentRound].correct.length) {
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
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentRound++;
            _initRound();
          });
        }
      });
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
    final isAscending = round.isAscending;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ترتيب الأرقام (${(_currentRound + 1).toArabicDigits()}/${_rounds.length.toArabicDigits()})',
        ),
        backgroundColor: AppColors.level3[0],
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
            colors: [AppColors.level3[0].withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.level3[0].withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.level3[0], width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      _roundCorrect ? Icons.check_circle : (isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                      color: _roundCorrect ? Colors.green : AppColors.level3[0],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _roundCorrect
                            ? 'أحسنت! الترتيب صحيح 🎉'
                            : (isAscending ? 'رتب تصاعدياً (من الأصغر للأكبر)' : 'رتب تنازلياً (من الأكبر للأصغر)'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _roundCorrect ? Colors.green.shade700 : AppColors.level3[0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildAnswerSlots(round),
              const SizedBox(height: 40),
              Icon(
                Icons.touch_app,
                size: 36,
                color: AppColors.level3[0].withValues(alpha: 0.5),
              ),
              Text(
                'اختر بالترتيب',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.level3[0].withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value *
                          ((_shakeController.status == AnimationStatus.forward) ? 1 : -1),
                      0,
                    ),
                    child: child,
                  );
                },
                child: _buildNumberButtons(),
              ),
              const Spacer(),
              _buildProgressIndicator(),
              const SizedBox(height: 20),
            ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerSlots(_OrderRound round) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double totalHPadding = 40;
        const double minSpacing = 6;
        final int count = round.correct.length;
        final double availableWidth = constraints.maxWidth - totalHPadding;
        final double slotSize =
            ((availableWidth - (minSpacing * 2 * count)) / count).clamp(40.0, 64.0);
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
                    color: hasValue ? Colors.green.shade600 : AppColors.level3[0].withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    if (hasValue)
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: hasValue
                      ? Text(
                          _answerSlots[index].toArabicDigits(),
                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : Text(
                          (index + 1).toArabicDigits(),
                          style: TextStyle(fontSize: fontSize * 0.65, color: AppColors.level3[0].withValues(alpha: 0.3)),
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
                      ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                      : LinearGradient(
                          colors: AppColors.level3,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isUsed
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.level3[0].withValues(alpha: 0.3),
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
            color = AppColors.level3[0];
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
                  ? Border.all(color: AppColors.level3[0], width: 2)
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
            colors: [AppColors.level3[0], AppColors.level3[1]],
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
                  label: const Text('إنهاء', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.level3[0],
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
