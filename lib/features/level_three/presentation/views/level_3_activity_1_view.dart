import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class Level3Activity1View extends StatefulWidget {
  const Level3Activity1View({super.key});

  @override
  State<Level3Activity1View> createState() => _Level3Activity1ViewState();
}

class _Level3Activity1ViewState extends State<Level3Activity1View>
    with SingleTickerProviderStateMixin {
  // القصة كاملة للعرض
  final String fullStoryDisplay =
      "ابني يطلب مني أن أقرأ له الكلمات في الواجب\n"
      "وفي يوم قال لي: لماذا لا تقرأ لي؟ فشعرت بالخجل\n"
      "لأني لا أعرف القراءة والكتابة.\n"
      "فقررت أن أتعلم القراءة خطوة خطوة مهما كان سني.\n"
      "وتعلمت أن العلم نور، وأنه لا وقت متأخر على البداية.";

  // القصة كاملة للنطق (بالتشكيل)
  final String fullStoryTts =
      "اِبْنِي يَطْلُبُ مِنِّي أَنْ أَقْرَأَ لَهُ الْكَلِمَاتِ فِي الْوَاجِبِ. "
      "وَفِي يَوْمٍ قَالَ لِي: لِمَاذَا لَا تَقْرَأُ لِي؟ فَشَعَرْتُ بِالْخَجَلِ "
      "لِأَنِّي لَا أَعْرِفُ الْقِرَاءَةَ وَالْكِتَابَةَ. "
      "فَقَرَّرْتُ أَنْ أَتَعَلَّمَ الْقِرَاءَةَ خُطْوَةً خُطْوَةً مَهْمَا كَانَ سِنِّي. "
      "وَتَعَلَّمْتُ أَنَّ الْعِلْمَ نُورٌ، وَأَنَّهُ لَا وَقْتَ مُتَأَخِّرٌ عَلَى الْبِدَايَةِ.";

  // الجمل للعرض (بدون تشكيل)
  final List<String> displayLines = [
    "ابني يطلب مني أن أقرأ له الكلمات في الواجب",
    "وفي يوم قال لي: لماذا لا تقرأ لي؟ فشعرت بالخجل",
    "فقررت أن أتعلم القراءة خطوة خطوة مهما كان سني",
    "تعلمت أن العلم نور، وأنه لا وقت متأخر على البداية",
  ];

  // الجمل للنطق (بالتشكيل)
  final List<String> storyLines = [
    "اِبْنِي يَطْلُبُ مِنِّي أَنْ أَقْرَأَ لَهُ الْكَلِمَاتِ فِي الْوَاجِبِ",
    "وَفِي يَوْمٍ قَالَ لِي: لِمَاذَا لَا تَقْرَأُ لِي؟ فَشَعَرْتُ بِالْخَجَلِ",
    "فَقَرَّرْتُ أَنْ أَتَعَلَّمَ الْقِرَاءَةَ خُطْوَةً خُطْوَةً مَهْمَا كَانَ سِنِّي",
    "تَعَلَّمْتُ أَنَّ الْعِلْمَ نُورٌ، وَأَنَّهُ لَا وَقْتَ مُتَأَخِّرٌ عَلَى الْبِدَايَةِ",
  ];

  // صور كل جملة
  final List<String> lineImages = [
    'assets/images/Arabic/Level3/Activity1/1.jpeg',
    'assets/images/Arabic/Level3/Activity1/2.jpeg',
    'assets/images/Arabic/Level3/Activity1/3.jpeg',
    'assets/images/Arabic/Level3/Activity1/4.jpeg',
  ];

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  int _currentPhase = 0; // 0 = عرض القصة كاملة, 1 = قراءة جملة جملة, 2 = انتهى
  int _currentLineIndex = 0;

  String _recognizedText = "";
  bool _isLineSuccess = false;

  // تتبع السطر الحالي أثناء قراءة القصة كاملة
  int _spokenLineIndex = -1; // -1 = لم تبدأ القراءة بعد
  bool _isPlayingFullStory = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _initAnimations();
    _playFullStory();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSpeechToText() async {
    final available = await _speechToText.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _isListening = status == 'listening';
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _speechEnabled = available;
      });
    }
  }

  /// The display lines split into individual sentences for the full story view
  final List<String> _fullStoryDisplayLines = [
    "ابني يطلب مني أن أقرأ له الكلمات في الواجب",
    "وفي يوم قال لي: لماذا لا تقرأ لي؟ فشعرت بالخجل",
    "لأني لا أعرف القراءة والكتابة.",
    "فقررت أن أتعلم القراءة خطوة خطوة مهما كان سني.",
    "وتعلمت أن العلم نور، وأنه لا وقت متأخر على البداية.",
  ];

  /// The TTS lines corresponding to each display line (with tashkeel)
  final List<String> _fullStoryTtsLines = [
    "اِبْنِي يَطْلُبُ مِنِّي أَنْ أَقْرَأَ لَهُ الْكَلِمَاتِ فِي الْوَاجِبِ",
    "وَفِي يَوْمٍ قَالَ لِي: لِمَاذَا لَا تَقْرَأُ لِي؟ فَشَعَرْتُ بِالْخَجَلِ",
    "لِأَنِّي لَا أَعْرِفُ الْقِرَاءَةَ وَالْكِتَابَةَ",
    "فَقَرَّرْتُ أَنْ أَتَعَلَّمَ الْقِرَاءَةَ خُطْوَةً خُطْوَةً مَهْمَا كَانَ سِنِّي",
    "وَتَعَلَّمْتُ أَنَّ الْعِلْمَ نُورٌ، وَأَنَّهُ لَا وَقْتَ مُتَأَخِّرٌ عَلَى الْبِدَايَةِ",
  ];

  Future<void> _playFullStory() async {
    setState(() {
      _currentPhase = 0;
      _spokenLineIndex = 0;
      _isPlayingFullStory = true;
    });
    _speakCurrentFullStoryLine();
  }

  void _speakCurrentFullStoryLine() {
    if (_spokenLineIndex < 0 ||
        _spokenLineIndex >= _fullStoryTtsLines.length ||
        !_isPlayingFullStory) {
      // انتهت القراءة
      if (mounted) {
        setState(() {
          _isPlayingFullStory = false;
          _spokenLineIndex = -1;
        });
      }
      return;
    }

    // set the completion handler to advance to next line
    AppTtsService.instance.setCompletionHandler(() {
      if (!mounted || !_isPlayingFullStory) return;
      final nextIndex = _spokenLineIndex + 1;
      if (nextIndex < _fullStoryTtsLines.length) {
        setState(() => _spokenLineIndex = nextIndex);
        _speakCurrentFullStoryLine();
      } else {
        // القصة انتهت
        setState(() {
          _isPlayingFullStory = false;
          _spokenLineIndex = -1;
        });
      }
    });

    AppTtsService.instance
        .speak(_fullStoryTtsLines[_spokenLineIndex], pitch: 0.8);
  }

  Future<void> _startLineTraining() async {
    await AppTtsService.instance.stop();
    setState(() {
      _currentPhase = 1;
      _currentLineIndex = 0;
      _recognizedText = '';
      _isLineSuccess = false;
      _isPlayingFullStory = false;
    });
    _playCurrentLine();
  }

  Future<void> _playCurrentLine() async {
    await AppTtsService.instance
        .speak(storyLines[_currentLineIndex], pitch: 0.8);
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeechToText();
      if (!_speechEnabled) {
        AppTtsService.instance.speak("خاصية التعرف على الصوت غير مفعلة");
        return;
      }
    }
    await _speechToText.stop();
    await AppTtsService.instance.stop();
    setState(() {
      _recognizedText = "";
      _isListening = true;
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'ar-SA',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;

    setState(() {
      _recognizedText = result.recognizedWords.trim();
    });

    _checkMatch(_recognizedText, isFinal: result.finalResult);
  }

  String _cleanArabicText(String text) {
    // إزالة التشكيل وعلامات الترقيم لتحسين المطابقة
    String clean = text.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
    clean = clean.replaceAll(RegExp(r'[\u064B-\u065F]'), ''); // حركات
    clean =
        clean.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    clean = clean.replaceAll('ى', 'ي');
    clean = clean.replaceAll('ة', 'ه');
    return clean.trim();
  }

  void _checkMatch(String spokenText, {bool isFinal = false}) async {
    // إذا تمت الإجابة بنجاح مسبقاً في هذه الجملة، لا تفعل شيئاً.
    if (_isLineSuccess) return;

    String expected = _cleanArabicText(storyLines[_currentLineIndex]);
    String actual = _cleanArabicText(spokenText);

    bool match = false;
    // مطابقة صارمة: يجب أن يتطابق النص بشكل كبير
    if (actual.contains(expected) ||
        (expected.contains(actual) && actual.length >= expected.length * 0.85)) {
      match = true;
    } else {
      // Word-by-word matching with order awareness
      final expectedWords =
          expected.split(' ').where((w) => w.isNotEmpty).toList();
      final actualWords =
          actual.split(' ').where((w) => w.isNotEmpty).toList();

      // Count matching words (exact match)
      int matchCount = 0;
      for (var w in expectedWords) {
        if (actualWords.contains(w)) matchCount++;
      }

      // Also check sequential/ordered matching
      int orderedMatchCount = 0;
      int searchFrom = 0;
      for (var w in expectedWords) {
        for (int j = searchFrom; j < actualWords.length; j++) {
          if (actualWords[j] == w) {
            orderedMatchCount++;
            searchFrom = j + 1;
            break;
          }
        }
      }

      // Require at least 90% of expected words to match
      // AND at least 80% to be in correct order
      final threshold = (expectedWords.length * 0.9).ceil();
      final orderThreshold = (expectedWords.length * 0.8).ceil();
      if (matchCount >= threshold && orderedMatchCount >= orderThreshold) {
        match = true;
      }
    }

    if (match) {
      await _speechToText.stop();
      if (!mounted) return;
      setState(() {
        _isLineSuccess = true;
        _isListening = false;
      });
      await AppTtsService.instance.stop();
      await AppTtsService.instance.speak("أحسنت! قراءة ممتازة");
    } else if (isFinal) {
      await AppTtsService.instance.stop();
      await AppTtsService.instance.speak("حاول مرة أخرى");
    }
  }

  void _nextSequence() {
    if (_currentLineIndex < storyLines.length - 1) {
      setState(() {
        _currentLineIndex++;
        _recognizedText = "";
        _isLineSuccess = false;
      });
      _playCurrentLine();
    } else {
      setState(() => _currentPhase = 2);
      AppTtsService.instance.speak("ممتاز! لقد أنهيت القصة بنجاح!");
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    AppTtsService.instance.stop();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ابني والواجب',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slateBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.slateBlue.withValues(alpha: 0.1),
              AppColors.softTeal.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: _currentPhase == 0
              ? _buildFullStoryPhase()
              : _currentPhase == 1
                  ? _buildTrainingPhase()
                  : _buildCompletionPhase(),
        ),
      ),
    );
  }

  // ── المرحلة الأولى: عرض القصة كاملة ──────────────────────────────
  Widget _buildFullStoryPhase() {
    return Column(
      children: [
        // المحتوى القابل للتمرير (صورة + نص)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                // عنوان القصة
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.slateBlue, AppColors.softTeal],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'ابني والواجب 📖',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // صورة القصة
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/Arabic/Level3/Activity1/story1.jpeg',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),

                // نص القصة كاملة مع تأثير التتبع
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.slateBlue.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.slateBlue.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: List.generate(_fullStoryDisplayLines.length,
                        (index) {
                      final isCurrent =
                          _isPlayingFullStory && _spokenLineIndex == index;
                      final isSpoken = _isPlayingFullStory &&
                          _spokenLineIndex > index;
                      final isWaiting = _isPlayingFullStory &&
                          _spokenLineIndex < index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.slateBlue
                                  .withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isCurrent
                              ? Border.all(
                                  color: AppColors.slateBlue
                                      .withValues(alpha: 0.4),
                                  width: 1.5)
                              : null,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: TextStyle(
                            fontSize: isCurrent ? 26 : 22,
                            height: 1.8,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCurrent
                                ? AppColors.slateBlue
                                : isSpoken
                                    ? AppColors.textPrimary
                                        .withValues(alpha: 0.4)
                                    : isWaiting
                                        ? AppColors.textPrimary
                                            .withValues(alpha: 0.5)
                                        : AppColors.textPrimary,
                          ),
                          child: Text(
                            _fullStoryDisplayLines[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

        // الأزرار (ثابتة في الأسفل)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              if (!_isPlayingFullStory) ...[
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startLineTraining,
                      icon: const Icon(Icons.record_voice_over, size: 28),
                      label: const Text('ابدأ القراءة 🎤',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.slateBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppTtsService.instance.stop();
                    setState(() {
                      _isPlayingFullStory = false;
                      _spokenLineIndex = -1;
                    });
                    _playFullStory();
                  },
                  icon: const Icon(Icons.replay, size: 22),
                  label: const Text('إعادة الاستماع',
                      style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.slateBlue,
                    side: const BorderSide(color: AppColors.slateBlue, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── المرحلة الثانية: القراءة جملة جملة ──────────────────────────
  Widget _buildTrainingPhase() {
    return Column(
      children: [
        // شريط التقدم
        Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: List.generate(displayLines.length, (i) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i < _currentLineIndex
                        ? Colors.green
                        : i == _currentLineIndex
                            ? AppColors.slateBlue
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // الجملة الحالية
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.slateBlue.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    displayLines[_currentLineIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ما قاله المتعلم
                if (_recognizedText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isLineSuccess
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isLineSuccess ? Colors.green : Colors.orange,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isLineSuccess ? '✅ ممتاز!' : '🗣️ قلت:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isLineSuccess ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _recognizedText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // أزرار التدريب
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              // استمع
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _playCurrentLine,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('استمع', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slateBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // تسجيل / التالي
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLineSuccess ? _nextSequence : _startListening,
                  icon: Icon(
                      _isLineSuccess ? Icons.arrow_back : Icons.mic,
                      size: 24),
                  label: Text(
                    _isLineSuccess ? 'التالي' : 'اقرأ',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLineSuccess
                        ? Colors.green
                        : _isListening
                            ? Colors.red
                            : AppColors.softTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── شاشة الانتهاء ────────────────────────────────────────────────
  Widget _buildCompletionPhase() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة النجاح
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.3),
                    Colors.orange.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child:
                  const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
            ),
            const SizedBox(height: 24),
            const Text(
              'أحسنت! 🌟',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slateBlue),
            ),
            const SizedBox(height: 16),
            const Text(
              'لقد قرأت القصة الأولى بنجاح!',
              style: TextStyle(fontSize: 22, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'استمر في القراءة والتعلم 💪',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('العودة للمستوى الثالث',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slateBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
