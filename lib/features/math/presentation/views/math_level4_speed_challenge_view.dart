import 'package:flutter/material.dart';
import 'dart:async';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_level4_data.dart';

class MathLevel4SpeedChallengeView extends StatefulWidget {
  const MathLevel4SpeedChallengeView({super.key});

  @override
  State<MathLevel4SpeedChallengeView> createState() => _MathLevel4SpeedChallengeViewState();
}

class _MathLevel4SpeedChallengeViewState extends State<MathLevel4SpeedChallengeView> {
  int _currentQuestionIndex = 0;
  List<int> _options = [];
  
  // Timer state
  Timer? _timer;
  int _secondsRemaining = kSpeedChallengeDurationSeconds;
  bool _isChallengeComplete = false;

  // Track results
  int _correctAnswers = 0;
  List<Map<String, dynamic>> _userAnswers = []; // Used for correction screen at the end

  @override
  void initState() {
    super.initState();
    _startTimer();
    _generateOptions();
    
    AppTtsService.instance.speakScreenIntro(
      'تحدي السرعة! أجب عن أكبر عدد من الأسئلة قبل انتهاء الوقت',
      isMounted: () => mounted,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _endChallenge();
      }
    });
  }

  void _generateOptions() {
    final answer = kSpeedChallengeQuestions[_currentQuestionIndex]['answer']!;
    _options = [answer];
    
    while (_options.length < 4) {
      int wrongAnswer = answer + (DateTime.now().millisecond % 20) - 10;
      if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    
    _options.shuffle();
  }

  void _handleOptionTap(int selectedAnswer) {
    if (_isChallengeComplete) return;

    final q = kSpeedChallengeQuestions[_currentQuestionIndex];
    final isCorrect = selectedAnswer == q['answer'];
    
    if (isCorrect) {
      _correctAnswers++;
      AppTtsService.instance.speak('ممتاز');
    } else {
      AppTtsService.instance.speak('حاول مرة أخرى');
    } // Record answers silently without interrupting flow too much

    _userAnswers.add({
      'question': q,
      'selected': selectedAnswer,
      'isCorrect': isCorrect,
    });

    if (_currentQuestionIndex < kSpeedChallengeQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _generateOptions();
      });
    } else {
      _endChallenge();
    }
  }

  void _endChallenge() async {
    _timer?.cancel();
    setState(() {
      _isChallengeComplete = true;
    });

    final targetScore = (kSpeedChallengeQuestions.length * kSpeedChallengePassThreshold).ceil();
    final isPassed = _correctAnswers >= targetScore;

    if (isPassed) {
      final progressService = await MathProgressService.getInstance();
      await progressService.completeActivity(4, 2, 4);
    }

    if (!mounted) return;
    
    _showResultsDialog(isPassed, targetScore);
  }

  void _showResultsDialog(bool passed, int targetScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          passed ? 'ممتاز!' : 'حاول مرة أخرى', 
          textAlign: TextAlign.center, 
          style: TextStyle(color: passed ? Colors.green : Colors.red, fontSize: 32)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'النتيجة: ${_correctAnswers.toArabicDigits()} من ${kSpeedChallengeQuestions.length.toArabicDigits()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              passed 
                  ? 'لقد اجتزت التحدي بنجاح!' 
                  : 'عليك الإجابة عن ${targetScore.toArabicDigits()} أسئلة على الأقل لاجتياز التحدي.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              // We stay on the page to view corrections, or user can press system back.
            },
            child: const Text('عرض الإجابات', style: TextStyle(color: Colors.white)),
          ),
          if (passed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // back to hub
              },
              child: const Text('إنهاء', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}'.toArabicDigits();
  }

  @override
  void dispose() {
    _timer?.cancel();
    AppTtsService.instance.stop();
    super.dispose();
  }

  Widget _buildCorrectionScreen() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _userAnswers.length,
      itemBuilder: (context, index) {
        final answerInfo = _userAnswers[index];
        final q = answerInfo['question'];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: answerInfo['isCorrect'] ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                answerInfo['isCorrect'] ? Icons.check_circle : Icons.cancel,
                color: answerInfo['isCorrect'] ? Colors.green : Colors.red,
                size: 40,
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${q['a'].toString().toArabicDigits()} + ${q['b'].toString().toArabicDigits()} = ${q['answer'].toString().toArabicDigits()}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              if (!answerInfo['isCorrect'])
                Text(
                  'إجابتك: ${answerInfo['selected']?.toString().toArabicDigits() ?? 'لم تُجب'}',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'تحدي السرعة',
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
            colors: [Color(0xFFE53935), Color(0xFFD32F2F)], // Red intense theme
          ),
        ),
        child: SafeArea(
          child: _isChallengeComplete 
          ? _buildCorrectionScreen()
          : Column(
            children: [
              // Top Bar with Timer and Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            _formatTime(_secondsRemaining),
                            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(_currentQuestionIndex + 1).toArabicDigits()} / ${kSpeedChallengeQuestions.length.toArabicDigits()}',
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
                          color: Colors.black.withValues(alpha: 0.2),
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
                            kSpeedChallengeQuestions[_currentQuestionIndex]['a'].toString().toArabicDigits(),
                            style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              '+',
                              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                          Text(
                            kSpeedChallengeQuestions[_currentQuestionIndex]['b'].toString().toArabicDigits(),
                            style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Keypad / Multiple Choice
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 15,
                  children: _options.map((opt) {
                    return GestureDetector(
                      onTap: () => _handleOptionTap(opt),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 35,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD32F2F),
                            ),
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
      ),
    );
  }
}
