import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel3ListenChooseView extends StatefulWidget {
  const MathLevel3ListenChooseView({super.key});

  @override
  State<MathLevel3ListenChooseView> createState() => _MathLevel3ListenChooseViewState();
}

class _MathLevel3ListenChooseViewState extends State<MathLevel3ListenChooseView> {
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
    {'text': "واحد وعشرين", 'correct': 21, 'options': [21, 12, 20]},
    {'text': "ثلاثة وعشرين", 'correct': 23, 'options': [23, 32, 20]},
    {'text': "أربعة وثلاثين", 'correct': 34, 'options': [34, 43, 30]},
    {'text': "خمسة وأربعين", 'correct': 45, 'options': [45, 54, 40]},
    {'text': "ستة وخمسين", 'correct': 56, 'options': [56, 65, 50]},
    {'text': "سبعة وستين", 'correct': 67, 'options': [67, 76, 60]},
    {'text': "ثمانية وسبعين", 'correct': 78, 'options': [78, 87, 70]},
    {'text': "تسعة وثمانين", 'correct': 89, 'options': [89, 98, 80]},
  ];

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'اسمع واختار الرقم الصحيح',
      isMounted: () => mounted,
    );
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 3), _speakCurrentNumber);
  }

  Future<void> _speakCurrentNumber() async {
    if (!mounted || _isFinished) return;
    await AppTtsService.instance.speak(_questions[_currentIndex]['text']);
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
            for (var element in _questions) {
              Set.from(element['options']).toList().shuffle(); // Keep options slightly varied?
              // The lists are pre-populated, we can shuffle them per question run
            }
            (_questions[_currentIndex]['options'] as List).shuffle();
          });
          _speakCurrentNumber();
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
    final options = List<int>.from(q['options']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اسمع واختار'),
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
              GestureDetector(
                onTap: _speakCurrentNumber,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: colors[0].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors[0], width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.volume_up, size: 64, color: colors[0]),
                      const SizedBox(height: 16),
                      Text(
                        'استمع واختر الرقم',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors[0]),
                      ),
                    ],
                  ),
                ),
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
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: options.map((opt) {
                        return GestureDetector(
                          onTap: () => _onOptionSelected(opt),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colors[1], width: 3),
                              boxShadow: [
                                BoxShadow(color: colors[1].withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _toArabic(opt),
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colors[1]),
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
