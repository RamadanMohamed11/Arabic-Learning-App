import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel1TestPronounceView extends StatefulWidget {
  final int part; // 1 for 1..5, 2 for 6..10

  const MathLevel1TestPronounceView({super.key, required this.part});

  @override
  State<MathLevel1TestPronounceView> createState() =>
      _MathLevel1TestPronounceViewState();
}

class _MathLevel1TestPronounceViewState
    extends State<MathLevel1TestPronounceView> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;
  String? _speechErrorMessage;
  String _recognizedWords = "";

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  late List<int> _numbersToTest;
  int _currentIndex = 0;
  bool _showSuccess = false;
  bool _showFailure = false;
  bool _isFinished = false;

  final Map<int, String> arabicLabels = {
    1: '١', 2: '٢', 3: '٣', 4: '٤', 5: '٥',
    6: '٦', 7: '٧', 8: '٨', 9: '٩', 10: '١٠'
  };

  @override
  void initState() {
    super.initState();
    _numbersToTest = widget.part == 1 ? [1, 2, 3, 4, 5] : [6, 7, 8, 9, 10];

    _initAnimation();
    _initSpeechToText();
    _playIntro();
  }

  void _initAnimation() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'اضغط على الميكروفون وانطق الرقم',
      isMounted: () => mounted,
    );
  }

  Future<void> _initSpeechToText() async {
    final available = await _speechToText.initialize(
      onStatus: _handleSpeechStatus,
      onError: _handleSpeechError,
    );
    if (mounted) {
      setState(() {
        _speechEnabled = available;
      });
    }
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) return;
    setState(() {
      _isListening = status == 'listening';
    });
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _speechErrorMessage = error.errorMsg;
    });
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeechToText();
      if (!_speechEnabled) return;
    }
    if (_showSuccess || _showFailure || _isFinished) return;

    await _speechToText.stop();
    await AppTtsService.instance.stop();

    setState(() {
      _speechErrorMessage = null;
      _isListening = true;
      _recognizedWords = "";
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'ar-SA',
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    final recognized = result.recognizedWords.trim();
    if (recognized.isEmpty) return;

    setState(() {
      _recognizedWords = recognized;
    });

    final targetNumber = _numbersToTest[_currentIndex];
    final isCorrect = _isNumberCorrect(recognized, targetNumber);

    if (result.finalResult || isCorrect) {
      _stopListening();
      if (isCorrect) {
        _handleSuccess();
      } else if (result.finalResult) {
        _handleFailure();
      }
    }
  }

  bool _isNumberCorrect(String recognized, int targetNumber) {
    final Map<int, List<String>> validPronunciations = {
      1: ['واحد', 'واحده', '١', '1'],
      2: ['اثنان', 'اثنين', 'اتنين', 'اتنان', '٢', '2'],
      3: ['ثلاثة', 'ثلاثه', 'تلاتة', 'تلاته', '٣', '3'],
      4: ['أربعة', 'اربعة', 'اربع', 'اربعه', '٤', '4'],
      5: ['خمسة', 'خمسه', '٥', '5'],
      6: ['ستة', 'سته', '٦', '6'],
      7: ['سبعة', 'سبعه', '٧', '7'],
      8: ['ثمانية', 'تمانية', 'ثمانيه', 'تمانيه', '٨', '8'],
      9: ['تسعة', 'تسعه', '٩', '9'],
      10: ['عشرة', 'عشره', '١٠', '10'],
    };

    final words = recognized.split(' ');
    final targetWords = validPronunciations[targetNumber] ?? [];

    for (var word in words) {
      if (targetWords.contains(word)) return true;
    }
    for (var target in targetWords) {
      if (recognized.contains(target)) return true;
    }
    return false;
  }

  Future<void> _handleSuccess() async {
    setState(() {
      _showSuccess = true;
    });

    await AppTtsService.instance.speak('أحسنت إجابة صحيحة');

    if (!mounted) return;

    if (_currentIndex < _numbersToTest.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _recognizedWords = "";
            _currentIndex++;
            _animationController.forward(from: 0.0);
          });
        }
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context, 'finished');
        }
      });
    }
  }

  Future<void> _handleFailure() async {
    setState(() {
      _showFailure = true;
    });

    await AppTtsService.instance.speak('حاول مرة أخرى');

    if (!mounted) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFailure = false;
          _recognizedWords = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechToText.stop();
    _speechToText.cancel();
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.part == 1 ? AppColors.level1 : AppColors.level2;
    final primaryColor = colors[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('انطق الرقم'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isFinished
            ? Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'الرقم ${_currentIndex + 1} من ${_numbersToTest.length}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Spacer(),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          arabicLabels[_numbersToTest[_currentIndex]] ?? '',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    if (_showSuccess)
                      const Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 64),
                          SizedBox(height: 16),
                          Text(
                            'أحسنت!',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      )
                    else if (_showFailure)
                      const Column(
                        children: [
                          Icon(Icons.cancel, color: Colors.red, size: 64),
                          SizedBox(height: 16),
                          Text(
                            'حاول مرة أخرى',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _recognizedWords.isEmpty
                                  ? 'اضغط على الميكروفون للتحدث'
                                  : _recognizedWords,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: _recognizedWords.isEmpty ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: _isListening ? _stopListening : _startListening,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: _isListening ? Colors.redAccent : primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isListening ? Colors.redAccent : primaryColor).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_speechErrorMessage != null)
                            Text(
                              _speechErrorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                            )
                          else if (_isListening)
                            const Text(
                              'جاري الاستماع...',
                              style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    const Spacer(),
                  ],
                ),
              ),
      ),
    );
  }
}
