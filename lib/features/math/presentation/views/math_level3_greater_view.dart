import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel3GreaterView extends StatefulWidget {
  const MathLevel3GreaterView({super.key});

  @override
  State<MathLevel3GreaterView> createState() => _MathLevel3GreaterViewState();
}

class _MathLevel3GreaterViewState extends State<MathLevel3GreaterView> {
  int currentQuestionIndex = 0;
  String? _selectedChoice;
  bool? _isCorrectSelection;

  final Map<int, String> arabicNumbers = {
    0: '٠', 1: '١', 2: '٢', 3: '٣', 4: '٤', 5: '٥',
    6: '٦', 7: '٧', 8: '٨', 9: '٩'
  };

  String _toArabic(int number) {
    if (number < 10) return arabicNumbers[number] ?? '$number';
    return number.toString().split('').map((char) => arabicNumbers[int.parse(char)] ?? char).join('');
  }

  final List<Map<String, dynamic>> questions = [
    {
      'choices': [34, 45],
      'answer': 45,
      'tts_answer': 'خمسة وأربعون',
    },
    {
      'choices': [23, 12],
      'answer': 23,
      'tts_answer': 'ثلاثة وعشرون',
    },
    {
      'choices': [56, 32],
      'answer': 56,
      'tts_answer': 'ستة وخمسون',
    },
    {
      'choices': [21, 67],
      'answer': 67,
      'tts_answer': 'سبعة وستون',
    },
    {
      'choices': [89, 78],
      'answer': 89,
      'tts_answer': 'تسعة وثمانون',
    },
    {
      'choices': [67, 56],
      'answer': 67,
      'tts_answer': 'سبعة وستون',
    },
  ];

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  bool _hasPlayedIntro = false;

  Future<void> _playIntro() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      "أي أكبر؟ اختر الرقم الأكبر",
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  void _answerQuestion(int choice) async {
    if (_selectedChoice != null) return; 

    final correct = questions[currentQuestionIndex]['answer'];
    final ttsAnswer = questions[currentQuestionIndex]['tts_answer'];

    final isCorrect = (choice == correct);

    setState(() {
      _selectedChoice = choice.toString();
      _isCorrectSelection = isCorrect;
    });

    if (isCorrect) {
      await AppTtsService.instance.speak("أحسنت! الإجابة صحيحة، $ttsAnswer");

      if (currentQuestionIndex < questions.length - 1) {
        if (mounted) {
          setState(() {
            currentQuestionIndex++;
            _selectedChoice = null;
            _isCorrectSelection = null;
          });
        }
      } else {
        await AppTtsService.instance.speak("رائع! لقد أكملت النشاط بنجاح");
        if (mounted) {
          _showCompletionDialog();
        }
      }
    } else {
      await AppTtsService.instance.speak("حاول مرة أخرى");
      if (mounted) {
        setState(() {
          _selectedChoice = null;
          _isCorrectSelection = null;
        });
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 80),
              const SizedBox(height: 16),
              const Text(
                'عمل رائع!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'أكملت النشاط بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.level3[0],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx); 
                  Navigator.pop(context, true); 
                },
                child: const Text(
                  'المتابعة',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= questions.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'أي أكبر؟',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.level3[0],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "أي أكبر؟",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.level3[0],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: (question['choices'] as List<int>).map((choiceInt) {
                    final choiceStr = choiceInt.toString();
                    final choiceArabic = _toArabic(choiceInt);
                    final isSelected = _selectedChoice == choiceStr;
                    List<Color> buttonColors = AppColors.level3;

                    if (isSelected && _isCorrectSelection != null) {
                      if (_isCorrectSelection!) {
                        buttonColors = [
                          Colors.green.shade400,
                          Colors.green.shade600,
                        ];
                      } else {
                        buttonColors = [Colors.red.shade400, Colors.red.shade600];
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: GestureDetector(
                        onTap: () => _answerQuestion(choiceInt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: isSelected ? 160 : 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: buttonColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: buttonColors[0].withValues(alpha: 0.4),
                                blurRadius: isSelected ? 15 : 10,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            choiceArabic,
                            style: TextStyle(
                              fontSize: isSelected ? 70 : 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
    );
  }
}
