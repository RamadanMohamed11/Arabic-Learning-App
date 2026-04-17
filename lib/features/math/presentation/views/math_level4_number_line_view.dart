import 'package:flutter/material.dart';
import 'dart:math';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_level4_data.dart';

class MathLevel4NumberLineView extends StatefulWidget {
  const MathLevel4NumberLineView({super.key});

  @override
  State<MathLevel4NumberLineView> createState() => _MathLevel4NumberLineViewState();
}

class _MathLevel4NumberLineViewState extends State<MathLevel4NumberLineView> {
  int _currentQuestionIndex = 0;
  List<int> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _generateOptions();
    AppTtsService.instance.speakScreenIntro(
      'استخدم خط الأعداد لحل مسألة الجمع',
      isMounted: () => mounted,
    );
  }

  void _generateOptions() {
    final answer = kNumberLineRounds[_currentQuestionIndex].answer;
    _options = [answer];
    
    final random = Random();

    while (_options.length < 3) {
      int offset = random.nextInt(4) + 1;
      bool add = random.nextBool();
      int wrongAnswer = add ? answer + offset : answer - offset;
      
      if (wrongAnswer >= 0 && wrongAnswer <= 10 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    
    _options.shuffle();
  }

  Future<void> _handleOptionTap(int selectedAnswer) async {
    if (_isAnswered) return;
    
    final correct = kNumberLineRounds[_currentQuestionIndex].answer;
    
    if (selectedAnswer == correct) {
      setState(() => _isAnswered = true);
      await AppTtsService.instance.speak('ممتاز');
      
      if (!mounted) return;

      if (_currentQuestionIndex < kNumberLineRounds.length - 1) {
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
    await progressService.completeActivity(4, 1, 3);

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('أحسنت!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.level4.last)),
        content: const Text(
          'لقد أنهيت التدريب بنجاح!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level4.last,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('موافق', style: TextStyle(color: AppColors.surface)),
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
    if (kNumberLineRounds.isEmpty) return const SizedBox();
    final round = kNumberLineRounds[_currentQuestionIndex];
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.level4,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0x00000000),
        appBar: AppBar(
          title: const Text(
            'خط الأعداد',
            style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0x00000000),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.surface),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(_currentQuestionIndex + 1).toArabicDigits()} / ${kNumberLineRounds.length.toArabicDigits()}',
                      style: const TextStyle(fontSize: 24, color: AppColors.surface, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Equation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  '${round.start.toString().toArabicDigits()} + ${round.move.toString().toArabicDigits()} = ؟',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.surface,
                  ),
                ),
              ),
              
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Custom visualization of jumps
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            'قفز ${round.move.toString().toArabicDigits()} خطوات من ${round.start.toString().toArabicDigits()}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.level4.last,
                            ),
                          ),
                        ),
                        // Number Line Drawing Container
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // The line
                              Positioned(
                                top: 60,
                                left: 20,
                                right: 20,
                                child: Container(
                                  height: 4,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              // The ticks and numbers
                              Positioned(
                                top: 50,
                                left: 20,
                                right: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(11, (index) {
                                    bool isStart = index == round.start;
                                    bool isAnswer = index == round.answer && _isAnswered;
                                    return Column(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          color: isStart ? AppColors.level4.first : (isAnswer ? AppColors.success : AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          index.toString().toArabicDigits(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: isStart || isAnswer ? FontWeight.bold : FontWeight.normal,
                                            color: isStart ? AppColors.level4.first : (isAnswer ? AppColors.success : AppColors.textPrimary),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                              // The Jump Arcs (Simulated simply)
                              if (_isAnswered)
                                Positioned(
                                  top: 10,
                                  child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 60),
                                )
                            ],
                          ),
                        ),
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
                    bool isCorrect = opt == round.answer;
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () => _handleOptionTap(opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 80,
                            decoration: BoxDecoration(
                              color: _isAnswered && isCorrect ? AppColors.success : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                opt.toString().toArabicDigits(),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: _isAnswered && isCorrect ? AppColors.surface : AppColors.level4.last,
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
