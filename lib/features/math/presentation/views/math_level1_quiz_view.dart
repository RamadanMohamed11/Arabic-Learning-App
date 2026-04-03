import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel1QuizView extends StatefulWidget {
  const MathLevel1QuizView({super.key});

  @override
  State<MathLevel1QuizView> createState() => _MathLevel1QuizViewState();
}

class _MathLevel1QuizViewState extends State<MathLevel1QuizView> {
  int currentQuestionIndex = 0;
  
  final List<Map<String, dynamic>> questions = [
    {
      'image': 'assets/svg/numbers/level1_Activity/Activity1/1.jpeg',
      'choices': ['٢', '٥', '١٠'],
      'answer': '١٠',
      'tts_answer': 'عشرة',
    },
    {
      'image': 'assets/svg/numbers/level1_Activity/Activity1/2.jpeg',
      'choices': ['٣', '٥', '٢'],
      'answer': '٢',
      'tts_answer': 'اثنان',
    },
    {
      'image': 'assets/svg/numbers/level1_Activity/Activity1/3.jpeg',
      'choices': ['١٠', '٩', '٦'],
      'answer': '٩',
      'tts_answer': 'تسعة',
    },
    {
      'image': 'assets/svg/numbers/level1_Activity/Activity1/4.jpeg',
      'choices': ['٥', '٨', '٤'],
      'answer': '٥',
      'tts_answer': 'خمسة',
    },
  ];

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speak("اختار الرقم الصحيح");
  }

  void _answerQuestion(String choice) async {
    final correct = questions[currentQuestionIndex]['answer'];
    final ttsAnswer = questions[currentQuestionIndex]['tts_answer'];
    
    if (choice == correct) {
      await AppTtsService.instance.speak("أحسنت! الإجابة صحيحة، $ttsAnswer");
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
        });
      } else {
        await AppTtsService.instance.speak("رائع! لقد أكملت الاختبار بنجاح");
        if (mounted) {
          _showCompletionDialog();
        }
      }
    } else {
      await AppTtsService.instance.speak("حاول مرة أخرى");
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                'لقد أنهيت المستوى الأول بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.level1[0],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close quiz view
                },
                child: const Text('المتابعة', style: TextStyle(fontSize: 20, color: Colors.white)),
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
        title: const Text('اختبار المستوى الأول', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.level1[0],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "اختار الرقم الصحيح",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        question['image'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: (question['choices'] as List<String>).map((choice) {
                  return GestureDetector(
                    onTap: () => _answerQuestion(choice),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.level1,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.level1[0].withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        choice,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
