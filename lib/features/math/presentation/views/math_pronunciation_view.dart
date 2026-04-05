import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/models/math_number_model.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathPronunciationView extends StatefulWidget {
  final MathNumberModel numberModel;
  final MathLevelModel levelModel;

  const MathPronunciationView({
    super.key,
    required this.numberModel,
    required this.levelModel,
  });

  @override
  State<MathPronunciationView> createState() => _MathPronunciationViewState();
}

class _MathPronunciationViewState extends State<MathPronunciationView>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String? _speechErrorMessage;
  String _recognizedWords = "";

  bool _isSuccess = false;
  bool _isFailure = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initSpeechToText();
    _playIntro();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'اضغط على الميكروفون وانطق الرقمْ',
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
    await _speechToText.stop();
    await AppTtsService.instance.stop();
    setState(() {
      _speechErrorMessage = null;
      _isListening = true;
      _recognizedWords = "";
      _isSuccess = false;
      _isFailure = false;
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

    if (result.finalResult ||
        _isNumberCorrect(recognized, widget.numberModel.number)) {
      _stopListening();
      if (_isNumberCorrect(recognized, widget.numberModel.number)) {
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
      if (targetWords.contains(word)) {
        return true;
      }
    }

    // Check full string just in case
    for (var target in targetWords) {
      if (recognized.contains(target)) return true;
    }

    return false;
  }

  Future<void> _handleSuccess() async {
    setState(() {
      _isSuccess = true;
    });

    AppTtsService.instance.speak('أحسنت! إجابة صحيحة');

    final progressService = await MathProgressService.getInstance();
    await progressService.completeActivity(
      widget.levelModel.level,
      widget.numberModel.number,
      4, // Activity ID 4 for Pronunciation
    );

    if (!mounted) return;
    // Increase delay to give 'أحسنت! إجابة صحيحة' enough time to play before the screen pops
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _handleFailure() async {
    setState(() {
      _isFailure = true;
    });
    AppTtsService.instance.speak('حاول مرة أخرى');

    if (!mounted) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isFailure = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.levelModel.level == 1
        ? AppColors.level1[0]
        : widget.levelModel.level == 2
        ? AppColors.level2[0]
        : AppColors.primaryGradient[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('انطق الرقم'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    widget.numberModel.label,
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
              if (_isSuccess)
                const Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'أحسنت!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              else if (_isFailure)
                const Column(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'حاول مرة أخرى',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                          color: _recognizedWords.isEmpty
                              ? Colors.grey
                              : Colors.black87,
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
                              color:
                                  (_isListening
                                          ? Colors.redAccent
                                          : primaryColor)
                                      .withValues(alpha: 0.4),
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
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      )
                    else if (_isListening)
                      const Text(
                        'جاري الاستماع...',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
