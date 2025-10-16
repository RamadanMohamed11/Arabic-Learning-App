import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

// كلمات التدريب على النطق
class PracticeWord {
  final String word;
  final String emoji;
  final String description;

  const PracticeWord({
    required this.word,
    required this.emoji,
    required this.description,
  });
}

const List<PracticeWord> practiceWords = [
  PracticeWord(word: 'شمس', emoji: '☀️', description: 'الشمس في السماء'),
  PracticeWord(word: 'قمر', emoji: '🌙', description: 'القمر في الليل'),
  PracticeWord(word: 'بحر', emoji: '🌊', description: 'البحر الأزرق'),
  PracticeWord(word: 'جبل', emoji: '⛰️', description: 'الجبل العالي'),
  PracticeWord(word: 'نهر', emoji: '🏞️', description: 'النهر الجاري'),
  PracticeWord(word: 'شجرة', emoji: '🌳', description: 'الشجرة الخضراء'),
  PracticeWord(word: 'وردة', emoji: '🌹', description: 'الوردة الجميلة'),
  PracticeWord(word: 'نجمة', emoji: '⭐', description: 'النجمة المضيئة'),
  PracticeWord(word: 'سحابة', emoji: '☁️', description: 'السحابة البيضاء'),
  PracticeWord(word: 'مطر', emoji: '🌧️', description: 'المطر ينزل'),
  PracticeWord(word: 'رعد', emoji: '⚡', description: 'صوت الرعد'),
  PracticeWord(word: 'ريح', emoji: '💨', description: 'الريح تهب'),
  PracticeWord(word: 'كتاب', emoji: '📚', description: 'كتاب للقراءة'),
  PracticeWord(word: 'قلم', emoji: '✏️', description: 'قلم للكتابة'),
  PracticeWord(word: 'مدرسة', emoji: '🏫', description: 'المدرسة للتعليم'),
  PracticeWord(word: 'بيت', emoji: '🏠', description: 'البيت الجميل'),
  PracticeWord(word: 'باب', emoji: '🚪', description: 'باب المنزل'),
  PracticeWord(word: 'نافذة', emoji: '🪟', description: 'النافذة المفتوحة'),
  PracticeWord(word: 'كرسي', emoji: '🪑', description: 'كرسي للجلوس'),
  PracticeWord(word: 'طاولة', emoji: '🪑', description: 'طاولة الطعام'),
  PracticeWord(word: 'سرير', emoji: '🛏️', description: 'سرير للنوم'),
  PracticeWord(word: 'مصباح', emoji: '💡', description: 'مصباح منير'),
  PracticeWord(word: 'ساعة', emoji: '⏰', description: 'ساعة الوقت'),
  PracticeWord(word: 'هاتف', emoji: '📱', description: 'هاتف محمول'),
  PracticeWord(word: 'حاسوب', emoji: '💻', description: 'حاسوب للعمل'),
  PracticeWord(word: 'سيارة', emoji: '🚗', description: 'سيارة سريعة'),
  PracticeWord(word: 'طائرة', emoji: '✈️', description: 'طائرة تطير'),
  PracticeWord(word: 'قطار', emoji: '🚂', description: 'قطار سريع'),
  PracticeWord(word: 'دراجة', emoji: '🚲', description: 'دراجة هوائية'),
  PracticeWord(word: 'حديقة', emoji: '🏞️', description: 'حديقة جميلة'),
];

class PronunciationPracticeViewBody extends StatefulWidget {
  const PronunciationPracticeViewBody({super.key});

  @override
  State<PronunciationPracticeViewBody> createState() =>
      _PronunciationPracticeViewBodyState();
}

class _PronunciationPracticeViewBodyState
    extends State<PronunciationPracticeViewBody> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _recognizedWords = '';
  String _feedbackMessage = 'اضغط على الميكروفون وابدأ في النطق';
  Color _feedbackColor = Colors.grey;
  int _currentWordIndex = 0;
  int _correctCount = 0;
  int _totalAttempts = 0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // تهيئة خدمة التعرف على الكلام
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        setState(() {
          _feedbackMessage = 'خطأ في التعرف على الكلام';
          _feedbackColor = Colors.red;
        });
      },
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() {});
        }
      },
    );
    setState(() {});
  }

  // بدء عملية الاستماع
  void _startListening() async {
    if (!_speechEnabled) {
      setState(() {
        _feedbackMessage = 'خدمة التعرف على الكلام غير متاحة';
        _feedbackColor = Colors.red;
      });
      return;
    }

    setState(() {
      _recognizedWords = '';
      _feedbackMessage = '...جارٍ الاستماع';
      _feedbackColor = Colors.blue;
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: "ar-SA", // اللغة العربية
      listenMode: ListenMode.confirmation,
    );
  }

  // إيقاف عملية الاستماع
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  // هذه الدالة يتم استدعاؤها عند التعرف على أي كلام
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedWords = result.recognizedWords;
    });
    // التحقق من النتيجة النهائية بعد توقف المستخدم عن الكلام
    if (result.finalResult) {
      _checkPronunciation();
    }
  }

  // التحقق من صحة الكلمة المنطوقة
  void _checkPronunciation() {
    _totalAttempts++;
    final targetWord = practiceWords[_currentWordIndex].word;
    final recognizedWord = _recognizedWords.trim();

    if (_wordsMatch(targetWord, recognizedWord)) {
      setState(() {
        _correctCount++;
        _feedbackMessage = 'ممتاز! نطق صحيح ✅';
        _feedbackColor = Colors.green;
      });
      // الانتقال للكلمة التالية بعد ثانيتين
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _nextWord();
        }
      });
    } else {
      setState(() {
        _feedbackMessage = 'حاول مرة أخرى! ❌';
        _feedbackColor = Colors.red;
      });
    }
  }

  // مقارنة ذكية للكلمات مع معالجة ه/ة و أ/ا
  bool _wordsMatch(String target, String recognized) {
    // تنظيف الكلمات
    String cleanTarget = _normalizeWord(target);
    String cleanRecognized = _normalizeWord(recognized);

    // مقارنة مباشرة
    if (cleanTarget == cleanRecognized) return true;

    // مقارنة إذا كانت إحداهما تحتوي على الأخرى
    if (cleanRecognized.contains(cleanTarget) || cleanTarget.contains(cleanRecognized)) {
      return true;
    }

    return false;
  }

  // تطبيع الكلمة: إزالة التشكيل وتوحيد الحروف المتشابهة
  String _normalizeWord(String text) {
    String normalized = text.toLowerCase().trim();
    
    // إزالة التشكيل
    normalized = normalized.replaceAll(RegExp(r'[\u064b-\u065f]'), '');
    
    // توحيد ه و ة
    normalized = normalized.replaceAll('ة', 'ه');
    
    // توحيد أ و إ و آ مع ا
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    
    return normalized;
  }

  void _nextWord() {
    setState(() {
      _currentWordIndex = (_currentWordIndex + 1) % practiceWords.length;
      _recognizedWords = '';
      _feedbackMessage = 'اضغط على الميكروفون وابدأ في النطق';
      _feedbackColor = Colors.grey;
    });
  }

  void _previousWord() {
    setState(() {
      _currentWordIndex =
          (_currentWordIndex - 1 + practiceWords.length) % practiceWords.length;
      _recognizedWords = '';
      _feedbackMessage = 'اضغط على الميكروفون وابدأ في النطق';
      _feedbackColor = Colors.grey;
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = practiceWords[_currentWordIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade50, Colors.cyan.shade50],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🎤', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 12),
                      Text(
                        'تمرين النطق',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00796B),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('🎤', style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Statistics
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          'صحيح: $_correctCount',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.analytics, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                          'المحاولات: $_totalAttempts',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'انطق الكلمة التالية:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Word Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Emoji
                            Text(
                              currentWord.emoji,
                              style: const TextStyle(fontSize: 80),
                            ),
                            const SizedBox(height: 16),
                            // Word
                            Text(
                              currentWord.word,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00796B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Description
                            Text(
                              currentWord.description,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Navigation Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _previousWord,
                            icon: const Icon(Icons.arrow_back_ios),
                            iconSize: 32,
                            color: const Color(0xFF00796B),
                          ),
                          const SizedBox(width: 40),
                          Text(
                            '${_currentWordIndex + 1} / ${practiceWords.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 40),
                          IconButton(
                            onPressed: _nextWord,
                            icon: const Icon(Icons.arrow_forward_ios),
                            iconSize: 32,
                            color: const Color(0xFF00796B),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Recognized Text
                      if (_recognizedWords.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'النطق المُتعرف عليه:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
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
                        ),

                      const SizedBox(height: 20),

                      // Feedback Message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _feedbackColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _feedbackColor.withOpacity(0.3),
                            width: 2,
                          ),
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
                      ),

                      const SizedBox(height: 20),

                      // Instructions
                      if (!_speechEnabled)
                        Container(
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Microphone Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton.extended(
                onPressed:
                    _speechToText.isListening ? _stopListening : _startListening,
                backgroundColor:
                    _speechToText.isListening ? Colors.red : const Color(0xFF00796B),
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
            ),
          ],
        ),
      ),
    );
  }
}
