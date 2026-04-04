import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/data/letter_names.dart';

/// Revision pronunciation practice for 4 letters
class RevisionPronunciationPractice extends StatefulWidget {
  final List<String> letters;
  final VoidCallback onComplete;

  const RevisionPronunciationPractice({
    super.key,
    required this.letters,
    required this.onComplete,
  });

  @override
  State<RevisionPronunciationPractice> createState() =>
      _RevisionPronunciationPracticeState();
}

class _RevisionPronunciationPracticeState
    extends State<RevisionPronunciationPractice> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  String _recognizedWords = '';
  String _feedbackMessage = 'اضغط على الميكروفون وقل اسم الحرف';
  Color _feedbackColor = Colors.grey;
  bool _isSpeaking = false;
  int _currentLetterIndex = 0;
  bool _currentLetterCompleted = false;
  bool _hasSpokenCorrection = false; // Track if correction TTS has been spoken

  List<LetterName?> _letterNames = [];
  List<bool> _completedLetters = [];

  @override
  void initState() {
    super.initState();
    _letterNames = widget.letters
        .map((letter) => getLetterName(letter))
        .toList();
    _completedLetters = List.filled(widget.letters.length, false);
    _initSpeech();
    _initTts();
  }

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
            // Speak the correct letter name (only once)
            final letterName = _letterNames[_currentLetterIndex];
            if (letterName != null && !_hasSpokenCorrection) {
              _hasSpokenCorrection = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                _speak(letterName.nameWithDiacritics);
              });
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
            // Speak the correct letter name (only once)
            if (_recognizedWords.isEmpty && !_hasSpokenCorrection) {
              final letterName = _letterNames[_currentLetterIndex];
              if (letterName != null) {
                _hasSpokenCorrection = true;
                Future.delayed(const Duration(milliseconds: 500), () {
                  _speak(letterName.nameWithDiacritics);
                });
              }
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
        // Speak the correct letter name
        final letterName = _letterNames[_currentLetterIndex];
        if (letterName != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _speak(letterName.nameWithDiacritics);
          });
        }
      }
    }
  }

  Future<void> _initTts() async {
    await TtsConfig.configure(_flutterTts, speechRate: 0.4, pitch: 1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
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
        // Speak the correct letter name (only once)
        final letterName = _letterNames[_currentLetterIndex];
        if (letterName != null && !_hasSpokenCorrection) {
          _hasSpokenCorrection = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            _speak(letterName.nameWithDiacritics);
          });
        }
      }
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        String originalRecognized = result.recognizedWords;
        String currentLetter = widget.letters[_currentLetterIndex];

        // Special case handling for commonly confused letters
        if (currentLetter == 'ث') {
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'ساء' ||
              normalized.contains('ساء') ||
              normalized == 'ثائن' ||
              normalized.contains('ثائن') ||
              normalized == 'ثاءن' ||
              normalized.contains('ثاءن') ||
              normalized == 'سائن' ||
              normalized.contains('سائن')) {
            _recognizedWords = 'ثاء';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (currentLetter == 'س') {
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'ثاء' || normalized.contains('ثاء')) {
            _recognizedWords = 'ساء';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (currentLetter == 'ذ') {
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'زال' ||
              normalized.contains('زال') ||
              normalized == 'زاي' ||
              normalized.contains('زاي') ||
              normalized == 'زين' ||
              normalized.contains('زين')) {
            _recognizedWords = 'ذال';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (currentLetter == 'ز') {
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'ذال' ||
              normalized.contains('ذال') ||
              normalized == 'زال' ||
              normalized.contains('زال')) {
            _recognizedWords = 'زاي';
          } else if (normalized == 'زين' || normalized.contains('زين')) {
            _recognizedWords = 'زاي';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (currentLetter == 'ت') {
          // If user says تاء but speech engine recognizes as كائن, تائن, etc., display تاء
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'كائن' ||
              normalized.contains('كائن') ||
              normalized == 'تائن' ||
              normalized.contains('تائن') ||
              normalized == 'تاءن' ||
              normalized.contains('تاءن')) {
            _recognizedWords = 'تاء';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (currentLetter == 'ب') {
          // If user says باء but speech engine recognizes as بائن, etc., display باء
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'بائن' ||
              normalized.contains('بائن') ||
              normalized == 'باءن' ||
              normalized.contains('باءن')) {
            _recognizedWords = 'باء';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else {
          _recognizedWords = originalRecognized;
        }
      });

      if (result.finalResult) {
        _stopListening();
        _checkPronunciation();
      }
    }
  }

  void _checkPronunciation() {
    final letterName = _letterNames[_currentLetterIndex];
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
        _currentLetterCompleted = true;
        _completedLetters[_currentLetterIndex] = true;
      });
    } else {
      setState(() {
        _feedbackMessage = '❌ خطأ! النطق الصحيح هو: ${letterName.name}';
        _feedbackColor = Colors.red;
      });

      // Speak the correct letter name (only once)
      if (!_hasSpokenCorrection) {
        _hasSpokenCorrection = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          _speak(letterName.nameWithDiacritics);
        });
      }
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

    // Synonym groups for commonly confused letters
    final thSeGroup = {'ثاء', 'ساء'};
    final zDhGroup = {'ذال', 'زال', 'زاي', 'زين'};

    // Accept letter names with common speech recognition misinterpretations
    // When saying تاءٍ (with tanween), speech engine often recognizes it as تائن, كائن, etc.
    final taGroup = {'تاء', 'تا', 'ت', 'تائن', 'تاءن', 'كائن'};
    final baGroup = {'باء', 'با', 'ب', 'بائن', 'باءن'};
    final thaGroup = {'ثاء', 'ثا', 'ث', 'ثائن', 'ثاءن', 'ساء', 'سائن'};
    final haGroup = {'هاء', 'ها', 'ه', 'هائن', 'هاءن'};
    final yaGroup = {'ياء', 'يا', 'ي', 'يائن', 'ياءن'};
    final raGroup = {'راء', 'را', 'ر', 'رائن', 'راءن'};
    final zaGroup = {'زاي', 'زا', 'ز', 'زاين'};
    final daGroup = {'دال', 'دا', 'د'};
    final faGroup = {'فاء', 'فا', 'ف', 'فائن', 'فاءن'};
    final waGroup = {'واو', 'وا', 'و'};
    final jimGroup = {'جيم', 'ج'};
    final haSmallGroup = {'حاء', 'حا', 'ح', 'حائن', 'حاءن'};
    final khaGroup = {'خاء', 'خا', 'خ', 'خائن', 'خاءن'};

    if (thSeGroup.contains(cleanTarget) &&
        thSeGroup.contains(cleanRecognized)) {
      return true;
    }
    if (zDhGroup.contains(cleanTarget) && zDhGroup.contains(cleanRecognized)) {
      return true;
    }
    if (taGroup.contains(cleanTarget) && taGroup.contains(cleanRecognized)) {
      return true;
    }
    if (baGroup.contains(cleanTarget) && baGroup.contains(cleanRecognized)) {
      return true;
    }
    if (thaGroup.contains(cleanTarget) && thaGroup.contains(cleanRecognized)) {
      return true;
    }
    if (haGroup.contains(cleanTarget) && haGroup.contains(cleanRecognized)) {
      return true;
    }
    if (yaGroup.contains(cleanTarget) && yaGroup.contains(cleanRecognized)) {
      return true;
    }
    if (raGroup.contains(cleanTarget) && raGroup.contains(cleanRecognized)) {
      return true;
    }
    if (zaGroup.contains(cleanTarget) && zaGroup.contains(cleanRecognized)) {
      return true;
    }
    if (daGroup.contains(cleanTarget) && daGroup.contains(cleanRecognized)) {
      return true;
    }
    if (faGroup.contains(cleanTarget) && faGroup.contains(cleanRecognized)) {
      return true;
    }
    if (waGroup.contains(cleanTarget) && waGroup.contains(cleanRecognized)) {
      return true;
    }
    if (jimGroup.contains(cleanTarget) && jimGroup.contains(cleanRecognized)) {
      return true;
    }
    if (haSmallGroup.contains(cleanTarget) &&
        haSmallGroup.contains(cleanRecognized)) {
      return true;
    }
    if (khaGroup.contains(cleanTarget) && khaGroup.contains(cleanRecognized)) {
      return true;
    }

    // Special check: if first character matches and recognized ends with common misinterpretation patterns
    if (cleanTarget.isNotEmpty && cleanRecognized.isNotEmpty) {
      String targetFirstChar = cleanTarget[0];
      String recognizedFirstChar = cleanRecognized[0];

      if (targetFirstChar == recognizedFirstChar) {
        if (cleanRecognized.endsWith('ائن') ||
            cleanRecognized.endsWith('اءن') ||
            cleanRecognized.endsWith('اين')) {
          return true;
        }
      }
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
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    setState(() {
      _isSpeaking = true;
    });
    await _flutterTts.speak(text);
  }

  void _handleNextButton() {
    if (_currentLetterIndex < widget.letters.length - 1) {
      setState(() {
        _currentLetterIndex++;
        _currentLetterCompleted = false;
        _recognizedWords = '';
        _feedbackMessage = 'اضغط على الميكروفون وقل اسم الحرف';
        _feedbackColor = Colors.grey;
      });
    } else {
      // All letters completed - onComplete callback handles navigation
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'نطق الحروف (${_currentLetterIndex + 1}/${widget.letters.length})',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.exercise2[0],
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
              AppColors.exercise2[0].withValues(alpha: 0.2),
              AppColors.exercise2[1].withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.exercise2[0].withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.letters.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _completedLetters[index]
                                  ? Colors.green
                                  : index == _currentLetterIndex
                                  ? AppColors.exercise2[0]
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: _completedLetters[index]
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Text(
                                      widget.letters[index],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: index == _currentLetterIndex
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.letters[index],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: index <= _currentLetterIndex
                                  ? AppColors.textPrimary
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'قل اسم الحرف التالي:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Letter Card
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.exercise2[0].withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.letters[_currentLetterIndex],
                                style: const TextStyle(
                                  fontSize: 100,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _letterNames[_currentLetterIndex]?.name ?? '',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Recognized Text
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

                        const SizedBox(height: 15),

                        // Feedback Message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _feedbackColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _feedbackColor, width: 2),
                          ),
                          child: Text(
                            _feedbackMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _feedbackColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

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
                                  : AppColors.exercise2[0],
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_speechToText.isListening
                                              ? Colors.red
                                              : AppColors.exercise2[0])
                                          .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              _speechToText.isListening
                                  ? Icons.mic
                                  : Icons.mic_none,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

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

                        if (!_speechEnabled)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'الرجاء السماح بالوصول إلى الميكروفون',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Next/Finish button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _currentLetterCompleted
                        ? _handleNextButton
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentLetterCompleted
                          ? Colors.teal
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _currentLetterCompleted ? 3 : 0,
                    ),
                    child: Text(
                      _currentLetterIndex < widget.letters.length - 1
                          ? 'التالي'
                          : 'إنهاء',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
