import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel3TrueFalseView extends StatefulWidget {
  const MathLevel3TrueFalseView({super.key});

  @override
  State<MathLevel3TrueFalseView> createState() => _MathLevel3TrueFalseViewState();
}

class _MathLevel3TrueFalseViewState extends State<MathLevel3TrueFalseView> {
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
    {'equation': '23 = 20 + 3', 'tens': 20, 'ones': 3, 'result': 23, 'correct': true},
    {'equation': '45 = 40 + 6', 'tens': 40, 'ones': 6, 'result': 45, 'correct': false},
    {'equation': '67 = 60 + 7', 'tens': 60, 'ones': 7, 'result': 67, 'correct': true},
    {'equation': '78 = 70 + 9', 'tens': 70, 'ones': 9, 'result': 78, 'correct': false},
    {'equation': '89 = 80 + 9', 'tens': 80, 'ones': 9, 'result': 89, 'correct': true},
    {'equation': '92 = 90 + 3', 'tens': 90, 'ones': 3, 'result': 92, 'correct': false},
  ];

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'صح ولا غلط. هل المعادلة صحيحة أم خاطئة',
      isMounted: () => mounted,
    );
  }

  void _onOptionSelected(bool userChoice) {
    if (_showSuccess || _showFailure || _isFinished) return;

    if (userChoice == _questions[_currentIndex]['correct']) {
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
        title: const Text('صح ولا غلط'),
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
              Text(
                '${_toArabic(q['result'])} = ${_toArabic(q['tens'])} + ${_toArabic(q['ones'])}',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colors[0]),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 60),
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
                      spacing: 40,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _onOptionSelected(true),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 4),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, color: Colors.green, size: 48),
                                Text('صح', style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _onOptionSelected(false),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red, width: 4),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close, color: Colors.red, size: 48),
                                Text('غلط', style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
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
}
