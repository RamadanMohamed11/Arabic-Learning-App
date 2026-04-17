import 'package:flutter/material.dart';
import 'dart:math';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_level4_data.dart';

class MathLevel4DirectAdditionView extends StatefulWidget {
  final bool isHalf2;

  const MathLevel4DirectAdditionView({super.key, required this.isHalf2});

  @override
  State<MathLevel4DirectAdditionView> createState() => _MathLevel4DirectAdditionViewState();
}

class _MathLevel4DirectAdditionViewState extends State<MathLevel4DirectAdditionView> {
  late List<Map<String, int>> _questions;
  int _currentQuestionIndex = 0;
  List<int> _options = [];
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.isHalf2 ? kDirectAdditionH2 : kDirectAdditionH1;
    _questions.shuffle();
    _generateOptions();
    
    AppTtsService.instance.speakScreenIntro(
      'اختر الإجابة الصحيحة للجمع',
      isMounted: () => mounted,
    );
  }

  void _generateOptions() {
    final answer = _questions[_currentQuestionIndex]['answer']!;
    _options = [answer];
    
    final random = Random();
    int minVal = widget.isHalf2 ? 10 : 1;
    int maxVal = widget.isHalf2 ? 200 : 20;

    while (_options.length < 3) {
      // Generate plausible distractors
      int offset = random.nextInt(6) + 1;
      bool add = random.nextBool();
      int wrongAnswer = add ? answer + offset : answer - offset;
      
      if (wrongAnswer >= minVal && wrongAnswer <= maxVal && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    
    _options.shuffle();
  }

  Future<void> _handleOptionTap(int selectedAnswer) async {
    if (_isAnswered) return;
    
    final correct = _questions[_currentQuestionIndex]['answer']!;
    
    if (selectedAnswer == correct) {
      setState(() => _isAnswered = true);
      await AppTtsService.instance.speak('ممتاز');
      
      if (!mounted) return;

      if (_currentQuestionIndex < _questions.length - 1) {
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
    
    if (widget.isHalf2) {
      await progressService.completeActivity(4, 2, 1);
    } else {
      await progressService.completeActivity(4, 1, 2);
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('أحسنت!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary)),
        content: const Text(
          'لقد أنهيت التدريب بنجاح!',
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
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to activities menu
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
    if (_questions.isEmpty) return const SizedBox();
    
    final q = _questions[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'الجمع المباشر',
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
                      '${(_currentQuestionIndex + 1).toArabicDigits()} / ${_questions.length.toArabicDigits()}',
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              // Equation
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(40),
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
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            q['a'].toString().toArabicDigits(),
                            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              '+',
                              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                          Text(
                            q['b'].toString().toArabicDigits(),
                            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              '=',
                              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _isAnswered ? Colors.green.shade100 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isAnswered ? Colors.green : Colors.grey.shade400,
                                width: 3,
                                style: _isAnswered ? BorderStyle.solid : BorderStyle.none,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _isAnswered ? q['answer'].toString().toArabicDigits() : '؟',
                                style: TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: _isAnswered ? Colors.green : Colors.grey,
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
                    bool isCorrect = opt == q['answer'];
                    
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
                                  fontSize: 36,
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
