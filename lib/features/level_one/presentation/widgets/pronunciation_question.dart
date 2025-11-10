import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_one/data/models/final_test_model.dart';
import 'package:arabic_learning_app/core/data/letter_names.dart';

/// Widget for pronunciation practice questions
/// User must speak the letter name correctly
class PronunciationQuestion extends StatefulWidget {
  final FinalTestQuestion question;
  final VoidCallback onCorrect;
  final VoidCallback onNext;

  const PronunciationQuestion({
    super.key,
    required this.question,
    required this.onCorrect,
    required this.onNext,
  });

  @override
  State<PronunciationQuestion> createState() => _PronunciationQuestionState();
}

class _PronunciationQuestionState extends State<PronunciationQuestion> {
  final SpeechToText _speechToText = SpeechToText();
  late FlutterTts _flutterTts;

  bool _speechEnabled = false;
  String _recognizedWords = '';
  String _feedbackMessage = 'اضغط على الميكروفون وقل اسم الحرف';
  Color _feedbackColor = Colors.grey;
  bool _isSpeaking = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          if (mounted) {
            setState(() {
              if (_recognizedWords.isEmpty) {
                _feedbackMessage = 'حدث خطأ في التعرف على الصوت';
                _feedbackColor = Colors.orange;
              }
            });
          }
        },
        onStatus: (status) {
          if (status == 'notListening' && mounted) {
            setState(() {
              if (_recognizedWords.isEmpty &&
                  _feedbackMessage == '...جارٍ الاستماع') {
                _feedbackMessage = 'اضغط على الميكروفون وقل اسم الحرف';
                _feedbackColor = Colors.grey;
              }
            });
          }
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _speechEnabled = false;
          _feedbackMessage = 'خدمة التعرف على الكلام غير متاحة';
          _feedbackColor = Colors.red;
        });
      }
    }
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((message) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

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
      });

      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() => _recognizedWords = result.recognizedWords);
            if (result.finalResult) {
              _stopListening();
              _checkPronunciation();
            }
          }
        },
        localeId: "ar-SA",
        listenMode: ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 10),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackMessage = 'حدث خطأ في التعرف على الصوت';
          _feedbackColor = Colors.red;
        });
      }
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _checkPronunciation() {
    final letterName = getLetterName(widget.question.correctAnswer);
    
    if (letterName == null) {
      setState(() {
        _feedbackMessage = 'خطأ: الحرف غير موجود';
        _feedbackColor = Colors.red;
      });
      return;
    }

    final targetName = letterName.name;
    final recognizedWord = _recognizedWords.trim();

    if (_wordsMatch(targetName, recognizedWord)) {
      setState(() {
        _feedbackMessage = 'ممتاز! نطق صحيح ✅';
        _feedbackColor = Colors.green;
        _isCorrect = true;
      });
      widget.onCorrect();
    } else {
      setState(() {
        _feedbackMessage = '❌ خطأ! النطق الصحيح هو: ${letterName.name}';
        _feedbackColor = Colors.red;
      });

      // Speak the correct pronunciation
      Future.delayed(const Duration(milliseconds: 500), () {
        _speak(letterName.nameWithDiacritics);
      });
    }
  }

  bool _wordsMatch(String target, String recognized) {
    String cleanTarget = _normalizeWord(target);
    String cleanRecognized = _normalizeWord(recognized);

    if (cleanTarget == cleanRecognized) return true;

    if (cleanRecognized.contains(cleanTarget) ||
        cleanTarget.contains(cleanRecognized)) {
      return true;
    }

    return false;
  }

  String _normalizeWord(String text) {
    String normalized = text.toLowerCase().trim();
    normalized = normalized.replaceAll(RegExp(r'[\u064b-\u065f]'), '');
    normalized = normalized.replaceAll('\u0640', '');
    normalized = normalized.replaceAll('ة', 'ه');
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    normalized = normalized.replaceAll('ى', 'ي');
    return normalized;
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letterName = getLetterName(widget.question.correctAnswer);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Section Title
        const Text(
          '✏ ثانيًا: قراءة الحروف',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),

        // Question Text
        const Text(
          'اقرأ الحرف بصوت واضح',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 32),

        // Letter Card
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                widget.question.correctAnswer,
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                letterName?.name ?? '',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Recognized Text Display
        if (_recognizedWords.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'سمعت: $_recognizedWords',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        // Feedback Message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _feedbackColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _feedbackColor, width: 2),
          ),
          child: Text(
            _feedbackMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _feedbackColor == Colors.grey
                  ? _feedbackColor
                  : _feedbackColor.withOpacity(0.9),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Microphone Button
        GestureDetector(
          onTap: () {
            if (_speechToText.isListening) {
              _stopListening();
            } else {
              _startListening();
            }
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _speechToText.isListening
                  ? Colors.red.shade400
                  : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: (_speechToText.isListening
                          ? Colors.red
                          : AppColors.primary)
                      .withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              _speechToText.isListening ? Icons.mic : Icons.mic_none,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          _speechToText.isListening
              ? 'استمع...'
              : 'اضغط على الميكروفون وقل اسم الحرف',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Next Button (shown when correct)
        if (_isCorrect)
          ElevatedButton(
            onPressed: widget.onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'السؤال التالي',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
      ],
    );
  }
}
