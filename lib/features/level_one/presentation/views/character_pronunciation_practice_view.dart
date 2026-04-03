import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/data/letter_names.dart';

/// Character pronunciation practice view
/// Allows students to practice pronouncing Arabic letters
/// If they say it wrong, the app will speak the correct letter name
class CharacterPronunciationPracticeView extends StatefulWidget {
  final String letter;
  final int? letterIndex;
  final VoidCallback? onComplete;

  const CharacterPronunciationPracticeView({
    super.key,
    required this.letter,
    this.letterIndex,
    this.onComplete,
  });

  @override
  State<CharacterPronunciationPracticeView> createState() =>
      _CharacterPronunciationPracticeViewState();
}

class _CharacterPronunciationPracticeViewState
    extends State<CharacterPronunciationPracticeView> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  String _recognizedWords = '';
  String _feedbackMessage = 'اضغط على الميكروفون وقل اسم الحرف';
  Color _feedbackColor = Colors.grey;
  int _correctCount = 0;
  int _totalAttempts = 0;
  bool _isSpeaking = false;
  LetterName? _letterName;
  bool _isCorrect = true; // Track if last attempt was correct
  bool _hasSpokenCorrection = false; // Track if correction TTS has been spoken

  @override
  void initState() {
    super.initState();
    _letterName = getLetterName(widget.letter);
    _initSpeech();
    _initTts();
    _initInstructionTts();
  }

  Future<void> _initInstructionTts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await AppTtsService.instance.speak(
        'تدريب نطق حرف ${widget.letter}. اضغط على زر الميكروفون وانطق اسم الحرف',
      );
    }
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
            // Speak the correct letter name (only once)
            if (_letterName != null && !_hasSpokenCorrection) {
              _hasSpokenCorrection = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                _speak(_letterName!.nameWithDiacritics);
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
            if (_recognizedWords.isEmpty &&
                _letterName != null &&
                !_hasSpokenCorrection) {
              _hasSpokenCorrection = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                _speak(_letterName!.nameWithDiacritics);
              });
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
        if (_letterName != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _speak(_letterName!.nameWithDiacritics);
          });
        }
      }
    }
  }

  /// Initialize text-to-speech
  Future<void> _initTts() async {
    await TtsConfig.configure(_flutterTts, speechRate: 0.4, pitch: 1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
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
        listenMode: ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 10),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackMessage = 'استمع للنطق الصحيح 🔊';
          _feedbackColor = Colors.blue;
        });
        // Speak the correct letter name
        if (_letterName != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _speak(_letterName!.nameWithDiacritics);
          });
        }
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
        // Store the original recognized words
        String originalRecognized = result.recognizedWords;

        // Special case: if user says ساء for ث, display ثاء instead
        if (_letterName != null && widget.letter == 'ث') {
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'ساء' || normalized.contains('ساء')) {
            _recognizedWords = 'ثاء';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (_letterName != null && widget.letter == 'س') {
          // If user says ثاء for س, display ساء instead
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'ثاء' || normalized.contains('ثاء')) {
            _recognizedWords = 'ساء';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (_letterName != null && widget.letter == 'ذ') {
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'زال' ||
              normalized.contains('زال') ||
              normalized == 'زاي' ||
              normalized.contains('زاي')) {
            _recognizedWords = 'ذال';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (_letterName != null && widget.letter == 'ز') {
          String normalized = _normalizeWord(originalRecognized);
          if (normalized == 'ذال' ||
              normalized.contains('ذال') ||
              normalized == 'زال' ||
              normalized.contains('زال')) {
            _recognizedWords = 'زاي';
          } else {
            _recognizedWords = originalRecognized;
          }
        } else if (_letterName != null && widget.letter == 'ت') {
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
        } else if (_letterName != null && widget.letter == 'ب') {
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

  /// Check if pronunciation is correct
  void _checkPronunciation() {
    _totalAttempts++;

    if (_letterName == null) {
      setState(() {
        _feedbackMessage = 'خطأ: الحرف غير موجود';
        _feedbackColor = Colors.red;
        _isCorrect = false;
      });
      return;
    }

    final targetName = _letterName!.name;
    final recognizedWord = _recognizedWords.trim();

    // Debug logging
    print('🎯 Target: "$targetName" | Recognized: "$recognizedWord"');
    print(
      '🔧 Normalized Target: "${_normalizeWord(targetName)}" | Normalized Recognized: "${_normalizeWord(recognizedWord)}"',
    );

    if (_wordsMatch(targetName, recognizedWord)) {
      setState(() {
        _correctCount++;
        _feedbackMessage = 'ممتاز! نطق صحيح ✅';
        _feedbackColor = Colors.green;
        _isCorrect = true;
      });

      // Automatically complete the exercise after first correct attempt
      if (_correctCount == 1 && widget.onComplete != null) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            widget.onComplete!();
            Navigator.pop(context);
          }
        });
      }
    } else {
      setState(() {
        _feedbackMessage = '❌ خطأ! النطق الصحيح هو: ${_letterName!.name}';
        _feedbackColor = Colors.red;
        _isCorrect = false;
      });

      // Speak the correct letter name with diacritics when wrong (only once)
      if (!_hasSpokenCorrection) {
        _hasSpokenCorrection = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          _speak(_letterName!.nameWithDiacritics);
        });
      }
    }
  }

  /// Check if two words match (with normalization)
  bool _wordsMatch(String target, String recognized) {
    String cleanTarget = _normalizeWord(target);
    String cleanRecognized = _normalizeWord(recognized);

    print(
      '   🔍 Clean Target: "$cleanTarget" | Clean Recognized: "$cleanRecognized"',
    );

    // Direct match
    if (cleanTarget == cleanRecognized) {
      print('   ✅ Direct match!');
      return true;
    }

    // Contains match
    if (cleanRecognized.contains(cleanTarget) ||
        cleanTarget.contains(cleanRecognized)) {
      print('   ✅ Contains match!');
      return true;
    }

    // Synonym groups for commonly confused letters
    final thSeGroup = {'ثاء', 'ساء'};
    final zDhGroup = {'ذال', 'زال', 'زاي'};

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
      print('   ✅ Th/Se group match!');
      return true;
    }
    if (zDhGroup.contains(cleanTarget) && zDhGroup.contains(cleanRecognized)) {
      print('   ✅ Z/Dh group match!');
      return true;
    }

    if (taGroup.contains(cleanTarget) && taGroup.contains(cleanRecognized)) {
      print('   ✅ Ta group match (تاء/تائن/etc)!');
      return true;
    }
    if (baGroup.contains(cleanTarget) && baGroup.contains(cleanRecognized)) {
      print('   ✅ Ba group match (باء/بائن/etc)!');
      return true;
    }
    if (thaGroup.contains(cleanTarget) && thaGroup.contains(cleanRecognized)) {
      print('   ✅ Tha group match (ثاء/ثائن/etc)!');
      return true;
    }
    if (haGroup.contains(cleanTarget) && haGroup.contains(cleanRecognized)) {
      print('   ✅ Ha group match (هاء/هائن/etc)!');
      return true;
    }
    if (yaGroup.contains(cleanTarget) && yaGroup.contains(cleanRecognized)) {
      print('   ✅ Ya group match (ياء/يائن/etc)!');
      return true;
    }
    if (raGroup.contains(cleanTarget) && raGroup.contains(cleanRecognized)) {
      print('   ✅ Ra group match (راء/رائن/etc)!');
      return true;
    }
    if (zaGroup.contains(cleanTarget) && zaGroup.contains(cleanRecognized)) {
      print('   ✅ Za group match!');
      return true;
    }
    if (daGroup.contains(cleanTarget) && daGroup.contains(cleanRecognized)) {
      print('   ✅ Da group match!');
      return true;
    }
    if (faGroup.contains(cleanTarget) && faGroup.contains(cleanRecognized)) {
      print('   ✅ Fa group match!');
      return true;
    }
    if (waGroup.contains(cleanTarget) && waGroup.contains(cleanRecognized)) {
      print('   ✅ Wa group match!');
      return true;
    }
    if (jimGroup.contains(cleanTarget) && jimGroup.contains(cleanRecognized)) {
      print('   ✅ Jim group match!');
      return true;
    }
    if (haSmallGroup.contains(cleanTarget) &&
        haSmallGroup.contains(cleanRecognized)) {
      print('   ✅ Ha (small) group match!');
      return true;
    }
    if (khaGroup.contains(cleanTarget) && khaGroup.contains(cleanRecognized)) {
      print('   ✅ Kha group match!');
      return true;
    }

    // Special check: if first character matches and recognized ends with common misinterpretation patterns
    if (cleanTarget.isNotEmpty && cleanRecognized.isNotEmpty) {
      String targetFirstChar = cleanTarget[0];
      String recognizedFirstChar = cleanRecognized[0];

      // Check if the first letter matches and recognized word ends with ائن or اء
      if (targetFirstChar == recognizedFirstChar) {
        if (cleanRecognized.endsWith('ائن') ||
            cleanRecognized.endsWith('اءن') ||
            cleanRecognized.endsWith('اين')) {
          print('   ✅ First char match with common suffix pattern!');
          return true;
        }
      }
    }

    print('   ❌ No match found');
    return false;
  }

  /// Normalize Arabic text for comparison
  String _normalizeWord(String text) {
    String normalized = text.toLowerCase().trim();

    // Remove all diacritics including tanween (ً ٌ ٍ)
    // Unicode range U+064B to U+065F covers all Arabic diacritics
    normalized = normalized.replaceAll(RegExp(r'[\u064b-\u065f]'), '');

    // Explicitly remove common tanween characters as backup
    normalized = normalized.replaceAll('ً', ''); // Fathatan
    normalized = normalized.replaceAll('ٌ', ''); // Dammatan
    normalized = normalized.replaceAll('ٍ', ''); // Kasratan

    // Remove tatweel (ـ)
    normalized = normalized.replaceAll('\u0640', '');

    // Normalize ه and ة
    normalized = normalized.replaceAll('ة', 'ه');

    // Normalize أ, إ, آ with ا
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');

    // Normalize ى with ي
    normalized = normalized.replaceAll('ى', 'ي');

    return normalized;
  }

  /// Speak text using TTS
  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    setState(() {
      _isSpeaking = true;
    });
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_letterName == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تدريب النطق'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('الحرف غير متوفر', style: TextStyle(fontSize: 24)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تدريب نطق الحرف',
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
              AppColors.level1[0].withOpacity(0.2),
              AppColors.level1[1].withOpacity(0.2),
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
                          'قل اسم الحرف التالي:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Letter Card
                        _buildLetterCard(),

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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLetterCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // The letter
          Text(
            widget.letter,
            style: const TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Letter name
          Text(
            _letterName!.name,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),

          // Letter name with diacritics
          Text(
            _letterName!.nameWithDiacritics,
            style: TextStyle(fontSize: 28, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Speaker button to hear the letter name (only when wrong)
          if (!_isCorrect && _totalAttempts > 0)
            ElevatedButton.icon(
              onPressed: () => _speak(_letterName!.nameWithDiacritics),
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
    );
  }

  Widget _buildRecognizedText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'النطق المُتعرف عليه:',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _recognizedWords,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _feedbackColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _feedbackColor.withOpacity(0.3), width: 2),
      ),
      child: Text(
        _feedbackMessage,
        style: TextStyle(
          fontSize: 20,
          color: _feedbackColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
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
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'يرجى السماح بالوصول للميكروفون من إعدادات التطبيق',
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FloatingActionButton.extended(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        backgroundColor: _speechToText.isListening
            ? Colors.red
            : AppColors.primary,
        icon: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
          size: 28,
        ),
        label: Text(
          _speechToText.isListening ? 'إيقاف' : 'ابدأ النطق',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
