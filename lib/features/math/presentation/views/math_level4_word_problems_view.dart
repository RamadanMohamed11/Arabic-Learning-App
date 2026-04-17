import 'package:flutter/material.dart';
import 'dart:math';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_level4_data.dart';

class MathLevel4WordProblemsView extends StatefulWidget {
  const MathLevel4WordProblemsView({super.key});

  @override
  State<MathLevel4WordProblemsView> createState() => _MathLevel4WordProblemsViewState();
}

class _MathLevel4WordProblemsViewState extends State<MathLevel4WordProblemsView> {
  int _currentQuestionIndex = 0;
  List<int> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _generateOptions();
    AppTtsService.instance.speakScreenIntro(
      'هيا نحل المسائل الحياتية، اقرأ ثم اختر الإجابة',
      isMounted: () => mounted,
    );
  }

  void _generateOptions() {
    final answer = kWordProblems[_currentQuestionIndex].answer;
    _options = [answer];
    
    final random = Random();

    while (_options.length < 3) {
      int offset = random.nextInt(15) + 1;
      bool add = random.nextBool();
      int wrongAnswer = add ? answer + offset : answer - offset;
      
      if (wrongAnswer > 10 && wrongAnswer < 200 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    
    _options.shuffle();
  }

  Future<void> _handleOptionTap(int selectedAnswer) async {
    if (_isAnswered) return;
    
    final correct = kWordProblems[_currentQuestionIndex].answer;
    
    if (selectedAnswer == correct) {
      setState(() => _isAnswered = true);
      await AppTtsService.instance.speak('ممتاز');
      
      if (!mounted) return;

      if (_currentQuestionIndex < kWordProblems.length - 1) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          setState(() {
            _currentQuestionIndex++;
            _isAnswered = false;
            _generateOptions();
          });
        });
      } else {
        _handleActivityComplete();
      }
    } else {
      AppTtsService.instance.speak('حاول مرة أخرى');
    }
  }

  Future<void> _handleActivityComplete() async {
    final progressService = await MathProgressService.getInstance();
    await progressService.completeActivity(4, 2, 3);

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('رائع جداً!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary)),
        content: const Text(
          'أنت بطل حقيقي في حل المسائل الحياتية!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('موافق', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kWordProblems.isEmpty) return const SizedBox();
    
    final problem = kWordProblems[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'المسائل الحياتية',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: AppColors.level4,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(_currentQuestionIndex + 1).toArabicDigits()} / ${kWordProblems.length.toArabicDigits()}',
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Word Problem Card
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          problem.icon,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          problem.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                        if (_isAnswered)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              'الإجابة هي ${problem.answer.toString().toArabicDigits()}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              
              // Multiple Choice
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _options.map((opt) {
                    bool isCorrect = opt == problem.answer;
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () => _handleOptionTap(opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 80,
                            decoration: BoxDecoration(
                              color: _isAnswered && isCorrect ? Colors.green : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                opt.toString().toArabicDigits(),
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: _isAnswered && isCorrect ? Colors.white : AppColors.level4.last,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
