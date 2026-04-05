import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel2GreaterView extends StatefulWidget {
  const MathLevel2GreaterView({super.key});

  @override
  State<MathLevel2GreaterView> createState() => _MathLevel2GreaterViewState();
}

class _MathLevel2GreaterViewState extends State<MathLevel2GreaterView> {
  int currentQuestionIndex = 0;
  String? _selectedChoice;
  bool? _isCorrectSelection;

  final List<Map<String, dynamic>> questions = [
    {
      'choices': ['٢٠', '٧٠'],
      'answer': '٧٠',
      'tts_answer': 'سبعون',
    },
    {
      'choices': ['١٠', '٥٠'],
      'answer': '٥٠',
      'tts_answer': 'خمسون',
    },
    {
      'choices': ['٩٠', '١٠٠'],
      'answer': '١٠٠',
      'tts_answer': 'مائة',
    },
    {
      'choices': ['٦٠', '٣٠'],
      'answer': '٦٠',
      'tts_answer': 'ستون',
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

  void _answerQuestion(String choice) async {
    if (_selectedChoice != null) return; // Prevent clicking while animating

    final correct = questions[currentQuestionIndex]['answer'];
    final ttsAnswer = questions[currentQuestionIndex]['tts_answer'];

    final isCorrect = (choice == correct);

    setState(() {
      _selectedChoice = choice;
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
                  backgroundColor: AppColors.level2[0],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // close dialog
                  Navigator.pop(context, true); // return true → activity done
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
        backgroundColor: AppColors.level2[0],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "أي أكبر؟",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: (question['choices'] as List<String>).map((choice) {
                    final isSelected = _selectedChoice == choice;
                    List<Color> buttonColors = AppColors.level2;

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
                        onTap: () => _answerQuestion(choice),
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
                            choice,
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
