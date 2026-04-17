import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_level4_data.dart';

class MathLevel4FruitCountingView extends StatefulWidget {
  const MathLevel4FruitCountingView({super.key});

  @override
  State<MathLevel4FruitCountingView> createState() => _MathLevel4FruitCountingViewState();
}

class _MathLevel4FruitCountingViewState extends State<MathLevel4FruitCountingView> {
  int _currentQuestionIndex = 0;
  List<int> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _generateOptions();
    AppTtsService.instance.speakScreenIntro(
      'كم عدد الفواكه بالأسفل؟ اختر الإجابة الصحيحة.',
      isMounted: () => mounted,
    );
  }

  void _generateOptions() {
    final answer = kFruitAdditionRounds[_currentQuestionIndex].answer;
    _options = [answer];
    
    while (_options.length < 3) {
      int wrongAnswer = answer + (DateTime.now().millisecond % 5) - 2;
      if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    
    _options.shuffle();
  }

  Future<void> _handleOptionTap(int selectedAnswer) async {
    if (_isAnswered) return;
    
    final correct = kFruitAdditionRounds[_currentQuestionIndex].answer;
    
    if (selectedAnswer == correct) {
      setState(() => _isAnswered = true);
      await AppTtsService.instance.speak('ممتاز');
      
      if (!mounted) return;

      if (_currentQuestionIndex < kFruitAdditionRounds.length - 1) {
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
    await progressService.completeActivity(4, 1, 1);

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
    if (kFruitAdditionRounds.isEmpty) return const SizedBox();
    
    final round = kFruitAdditionRounds[_currentQuestionIndex];
    
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
            'عد الفواكه',
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
                      '${(_currentQuestionIndex + 1).toArabicDigits()} / ${kFruitAdditionRounds.length.toArabicDigits()}',
                      style: const TextStyle(fontSize: 24, color: AppColors.surface, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Fruits Display
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 5,
                              runSpacing: 5,
                              children: List.generate(
                                round.leftCount,
                                (i) => Text(round.emoji, style: const TextStyle(fontSize: 40)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              '+',
                              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: AppColors.level4.last),
                            ),
                          ),
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 5,
                              runSpacing: 5,
                              children: List.generate(
                                round.rightCount,
                                (i) => Text(round.emoji, style: const TextStyle(fontSize: 40)),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              '=',
                              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _isAnswered ? AppColors.success.withValues(alpha: 0.1) : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isAnswered ? AppColors.success : AppColors.divider,
                                width: 3,
                                style: _isAnswered ? BorderStyle.solid : BorderStyle.none,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _isAnswered ? round.answer.toString().toArabicDigits() : '؟',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: _isAnswered ? AppColors.success : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
