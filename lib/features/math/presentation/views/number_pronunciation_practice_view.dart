import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/math/data/models/math_number_model.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';

/// Number pronunciation practice view
/// Allows students to practice pronouncing Arabic numbers
class NumberPronunciationPracticeView extends StatefulWidget {
  final MathNumberModel numberModel;
  final MathLevelModel levelModel;
  final VoidCallback? onComplete;

  const NumberPronunciationPracticeView({
    super.key,
    required this.numberModel,
    required this.levelModel,
    this.onComplete,
  });

  @override
  State<NumberPronunciationPracticeView> createState() =>
      _NumberPronunciationPracticeViewState();
}

class _NumberPronunciationPracticeViewState
    extends State<NumberPronunciationPracticeView> {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _recognizedWords = '';
  String _feedbackMessage = 'اضغط على الميكروفون وقل اسم الرقم';
  Color _feedbackColor = Colors.grey;
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _isCorrect = true; // Track if last attempt was correct
  bool _hasSpokenCorrection = false; // Track if correction TTS has been spoken
  bool _isSpeaking = false;

  // Expected words mapped for specific numbers based on common pronunciations
  final Map<int, List<String>> _numberPronunciations = {
    1: ['واحد'],
    2: ['اثنان', 'إثنان', 'اثنين', 'إثنين', 'اتنين', 'اتنان'],
    3: ['ثلاثة', 'تلاتة', 'ثلاثه', 'تلاته'],
    4: ['أربعة', 'اربعة', 'اربعه', 'أربعه'],
    5: ['خمسة', 'خمسه'],
    6: ['ستة', 'سته'],
    7: ['سبعة', 'سبعه'],
    8: ['ثمانية', 'تمانية', 'ثمانيه', 'تمانيه', 'تمنيه', 'ثماني'],
    9: ['تسعة', 'تسعه'],
    10: ['عشرة', 'عشره'],
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initInstructionTts();
  }

  Future<void> _initInstructionTts() async {
    await AppTtsService.instance.speakScreenIntro(
      'تدريب نطق الرقم ${widget.numberModel.label}. اضغط على زر الميكروفون وانطق اسم الرقم',
      isMounted: () => mounted,
    );
  }

  /// Initialize speech recognition
  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          if (mounted) {
            setState(() {
              if (_recognizedWords.isEmpty) {
                _feedbackMessage = 'استمع للنطق الصحيح 🔊';
                _feedbackColor = Colors.blue;
              }
            });
            // Speak the correct number name (only once)
            if (!_hasSpokenCorrection) {
              _hasSpokenCorrection = true;
              _speak(_getCorrectPronunciation());
            }
          }
        },
        onStatus: (status) {
          if (status == 'notListening' && mounted) {
            setState(() {
              if (_recognizedWords.isEmpty &&
                  _feedbackMessage == '...جارٍ الاستماع') {
                _feedbackMessage = 'استمع للنطق الصحيح 🔊';
                _feedbackColor = Colors.blue;
              }
            });
            // Speak the correct number name (only once)
            if (_recognizedWords.isEmpty && !_hasSpokenCorrection) {
              _hasSpokenCorrection = true;
              _speak(_getCorrectPronunciation());
            }
          }
        },
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackMessage = 'استمع للنطق الصحيح 🔊';
          _feedbackColor = Colors.blue;
        });
        _speak(_getCorrectPronunciation());
      }
    }
  }

  /// Get the standard correct pronunciation for the number
  String _getCorrectPronunciation() {
    return _numberPronunciations[widget.numberModel.number]?.first ??
        widget.numberModel.label;
  }

  /// Start listening to user's speech
  void _startListening() async {
    if (!_speechEnabled) {
      setState(() {
        _feedbackMessage = 'خدمة التعرف على الكلام غير متاحة';
        _feedbackColor = Colors.red;
      });
      return;
    }

    try {
      setState(() {
        _recognizedWords = '';
        _feedbackMessage = '...جارٍ الاستماع';
        _feedbackColor = Colors.blue;
        _hasSpokenCorrection = false; // Reset flag for new attempt
      });

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: "ar-SA",
        listenOptions: SpeechListenOptions(listenMode: ListenMode.confirmation),
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 10),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackMessage = 'استمع للنطق الصحيح 🔊';
          _feedbackColor = Colors.blue;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _speak(_getCorrectPronunciation());
        });
      }
    }
  }

  /// Stop listening
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// Handle speech recognition result
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _recognizedWords = result.recognizedWords;
      });

      if (result.finalResult) {
        _stopListening();
        _checkPronunciation();
      }
    }
  }

  /// Check if pronunciation is correct
  void _checkPronunciation() {
    _totalAttempts++;

    final recognizedWord = _recognizedWords.trim();
    debugPrint('🎯 Target: "${widget.numberModel.number}" | Recognized: "$recognizedWord"');

    if (_wordsMatch(widget.numberModel.number, recognizedWord)) {
      setState(() {
        _correctCount++;
        _feedbackMessage = 'ممتاز! نطق صحيح ✅';
        _feedbackColor = Colors.green;
        _isCorrect = true;
      });

      // Automatically complete the exercise
      if (_correctCount == 1 && widget.onComplete != null) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            widget.onComplete!();
            Navigator.pop(context);
          }
        });
      }
    } else {
      final String correctWord = _getCorrectPronunciation();
      setState(() {
        _feedbackMessage = '❌ خطأ! النطق الصحيح هو: $correctWord';
        _feedbackColor = Colors.red;
        _isCorrect = false;
      });

      // Speak correct number name
      if (!_hasSpokenCorrection) {
        _hasSpokenCorrection = true;
        _speak(correctWord);
      }
    }
  }

  /// Normalize Arabic text for comparison
  String _normalizeWord(String text) {
    String normalized = text.toLowerCase().trim();
    // Remove diacritics
    normalized = normalized.replaceAll(RegExp(r'[\u064b-\u065f]'), '');
    normalized = normalized.replaceAll('ً', '');
    normalized = normalized.replaceAll('ٌ', '');
    normalized = normalized.replaceAll('ٍ', '');
    normalized = normalized.replaceAll('\u0640', '');
    normalized = normalized.replaceAll('ة', 'ه');
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    normalized = normalized.replaceAll('ى', 'ي');
    return normalized;
  }

  /// Check if words match using predefined mappings and normalization
  bool _wordsMatch(int targetNumber, String recognized) {
    String cleanRecognized = _normalizeWord(recognized);
    
    // Fallback: check if the recognized word matches the label
    if (cleanRecognized.contains(_normalizeWord(widget.numberModel.label))) {
      return true;
    }

    final allowedVariations = _numberPronunciations[targetNumber];
    if (allowedVariations != null) {
      for (final variation in allowedVariations) {
        String cleanVariation = _normalizeWord(variation);
        if (cleanRecognized.contains(cleanVariation) || cleanVariation.contains(cleanRecognized)) {
          return true;
        }
      }
    }

    // Direct check of digits if they say the digit and it's transcribed as a number
    if (recognized.contains(targetNumber.toString())) {
      return true;
    }

    // Arabic numeric representation
    final arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    if (targetNumber >= 0 && targetNumber <= 9) {
       if (recognized.contains(arabicNumerals[targetNumber])) {
         return true;
       }
    }

    return false;
  }

  /// Speak text using TTS
  Future<void> _speak(String text) async {
    setState(() {
      _isSpeaking = true;
    });
    await AppTtsService.instance.speak(text);
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تدريب نطق الرقم',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.level1[0].withValues(alpha: 0.2),
              AppColors.level1[1].withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with statistics
              _buildHeader(),

              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'قل اسم الرقم التالي:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Number Card
                        _buildNumberCard(),

                        const SizedBox(height: 30),

                        // Recognized Text
                        if (_recognizedWords.isNotEmpty) _buildRecognizedText(),

                        const SizedBox(height: 20),

                        // Feedback Message
                        _buildFeedbackMessage(),

                        const SizedBox(height: 20),

                        // Instructions
                        if (!_speechEnabled) _buildPermissionWarning(),
                      ],
                    ),
                  ),
                ),
              ),

              // Microphone Button
              _buildMicrophoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.check_circle,
            'صحيح',
            _correctCount,
            Colors.green,
          ),
          Container(width: 2, height: 40, color: Colors.grey.shade300),
          _buildStatItem(
            Icons.analytics,
            'المحاولات',
            _totalAttempts,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, int value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberCard() {
    return Card(
      elevation: 8,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.numberModel.label,
              style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            // Speaker button to hear the number name (only when wrong or requested)
            if (!_isCorrect && _totalAttempts > 0)
              ElevatedButton.icon(
                onPressed: () => _speak(_getCorrectPronunciation()),
                icon: Icon(_isSpeaking ? Icons.volume_off : Icons.volume_up),
                label: const Text(
                  'استمع للنطق الصحيح',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecognizedText() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'سمعتك تقول:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _recognizedWords,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _feedbackColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _feedbackColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_feedbackColor == Colors.green)
            const Icon(Icons.stars, color: Colors.green, size: 28)
          else if (_feedbackColor == Colors.red)
            const Icon(Icons.error_outline, color: Colors.red, size: 28)
          else
            Icon(Icons.info_outline, color: _feedbackColor, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _feedbackMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _feedbackColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'يرجى السماح للتطبيق باستخدام الميكروفون لتمكين التعرف على الصوت.',
              style: TextStyle(color: Colors.brown, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    bool isListening = _speechToText.isListening;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (isListening) {
              _stopListening();
            } else {
              _startListening();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isListening ? 90 : 80,
            height: isListening ? 90 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening ? Colors.red : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: (isListening ? Colors.red : AppColors.primary)
                      .withValues(alpha: 0.4),
                  blurRadius: isListening ? 20 : 15,
                  spreadRadius: isListening ? 5 : 2,
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: isListening ? 50 : 40,
            ),
          ),
        ),
      ),
    );
  }
}
