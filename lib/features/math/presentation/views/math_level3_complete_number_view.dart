import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel3CompleteNumberView extends StatefulWidget {
  const MathLevel3CompleteNumberView({super.key});

  @override
  State<MathLevel3CompleteNumberView> createState() => _MathLevel3CompleteNumberViewState();
}

class _MathLevel3CompleteNumberViewState extends State<MathLevel3CompleteNumberView> {
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

  // .... + 4 = 34
  final List<Map<String, dynamic>> _questions = [
    {'total': 34, 'ones': 4, 'correct': 30},
    {'total': 92, 'ones': 2, 'correct': 90},
    {'total': 45, 'ones': 5, 'correct': 40},
    {'total': 67, 'ones': 7, 'correct': 60},
    {'total': 78, 'ones': 8, 'correct': 70},
    {'total': 89, 'ones': 9, 'correct': 80},
    {'total': 91, 'ones': 1, 'correct': 90},
    {'total': 56, 'ones': 6, 'correct': 50},
  ];

  List<int> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    _playIntro();
    _generateOptionsForCurrent();
  }

  void _generateOptionsForCurrent() {
    final q = _questions[_currentIndex];
    int correct = q['correct'];
    _currentOptions = [
      correct,
      correct - 10 > 0 ? correct - 10 : correct + 20,
      correct + 10 < 100 ? correct + 10 : correct - 20,
    ]..shuffle();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'كمل الرقم. اختر الإجابة الصحيحة',
      isMounted: () => mounted,
    );
  }

  void _onOptionSelected(int option) {
    if (_showSuccess || _showFailure || _isFinished) return;

    if (option == _questions[_currentIndex]['correct']) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('كمل الرقم'),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors[0]),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: [
                  Text(
                    _toArabic(q['total']),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colors[0]),
                  ),
                  Text(
                    ' = ',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colors[0]),
                  ),
                  Text(
                    '___',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colors[0]),
                  ),
                  Text(
                    ' + ',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colors[0]),
                  ),
                  Text(
                    _toArabic(q['ones']),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colors[0]),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: _currentOptions.map((opt) {
                        return GestureDetector(
                          onTap: () => _onOptionSelected(opt),
                          child: Container(
                            width: 90,
                            height: 90,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors[0], width: 2),
                              boxShadow: [
                                  BoxShadow(color: colors[0].withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Text(
                              _toArabic(opt),
                              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: colors[0]),
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
