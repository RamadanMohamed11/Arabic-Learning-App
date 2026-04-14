import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel3DecomposeView extends StatefulWidget {
  const MathLevel3DecomposeView({super.key});

  @override
  State<MathLevel3DecomposeView> createState() => _MathLevel3DecomposeViewState();
}

class _MathLevel3DecomposeViewState extends State<MathLevel3DecomposeView> {
  int _currentIndex = 0;
  bool _showSuccess = false;
  bool _showFailure = false;
  bool _isFinished = false;

  final Map<int, String> arabicNumbers = {
    0: '٠', 1: '١', 2: '٢', 3: '٣', 4: '٤', 5: '٥',
    6: '٦', 7: '٧', 8: '٨', 9: '٩'
  };

  String _toArabic(int number) {
    if (number < 10) return arabicNumbers[number] ?? '$number';
    return number.toString().split('').map((char) => arabicNumbers[int.parse(char)] ?? char).join('');
  }

  final List<Map<String, dynamic>> _questions = [
    {'number': 21, 'tens': 20, 'ones': 1},
    {'number': 23, 'tens': 20, 'ones': 3},
    {'number': 34, 'tens': 30, 'ones': 4},
    {'number': 45, 'tens': 40, 'ones': 5},
    {'number': 56, 'tens': 50, 'ones': 6},
    {'number': 67, 'tens': 60, 'ones': 7},
    {'number': 78, 'tens': 70, 'ones': 8},
    {'number': 89, 'tens': 80, 'ones': 9},
    {'number': 92, 'tens': 90, 'ones': 2},
    {'number': 47, 'tens': 40, 'ones': 7},
  ];

  List<Map<String, int>> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    _playIntro();
    _generateOptionsForCurrent();
  }

  void _generateOptionsForCurrent() {
    final q = _questions[_currentIndex];
    int tens = q['tens'];
    int ones = q['ones'];
    _currentOptions = [
      {'tens': tens, 'ones': ones},
      {'tens': tens, 'ones': (ones + 1) % 10},
      {'tens': tens - 10 > 0 ? tens - 10 : tens + 10, 'ones': ones},
    ]..shuffle();
  }

  Future<void> _handleCorrectAnswer() async {
    setState(() {
      _showSuccess = true;
    });

    await AppTtsService.instance.speak('أحسنت إجابة صحيحة');

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _currentIndex++;
            _generateOptionsForCurrent();
          });
        }
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'فك الأرقام. اختر الإجابة الصحيحة',
      isMounted: () => mounted,
    );
  }

  void _onOptionSelected(Map<String, int> option) {
    if (_showSuccess || _showFailure || _isFinished) return;

    final q = _questions[_currentIndex];
    if (option['tens'] == q['tens'] && option['ones'] == q['ones']) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
  }

  Future<void> _handleWrongAnswer() async {
    setState(() {
      _showFailure = true;
    });

    await AppTtsService.instance.speak('حاول مرة أخرى');

    if (!mounted) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFailure = false;
        });
      }
    });
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.primaryGradient;
    
    if (_isFinished) {
      return Scaffold(
        body: Center(
          child: Icon(Icons.check_circle, color: Colors.green, size: 100),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final options = _currentOptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('فك الأعداد'),
        backgroundColor: colors[0],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'السؤال ${_currentIndex + 1} من ${_questions.length}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors[0],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${_toArabic(q['number'])} = ___ + ___',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colors[0],
                ),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 20),
              if (_showSuccess) ...[
                const Spacer(),
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text('أحسنت!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                const Spacer(flex: 2),
              ]
              else if (_showFailure) ...[
                const Spacer(),
                const Icon(Icons.cancel, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text('حاول مرة أخرى', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
                const Spacer(flex: 2),
              ]
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: options.map((opt) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => _onOptionSelected(opt),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: colors[0], width: 2),
                                boxShadow: [
                                  BoxShadow(color: colors[0].withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Text(
                                '${_toArabic(opt['tens']!)} + ${_toArabic(opt['ones']!)}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors[0]),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
