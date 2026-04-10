import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
    setState(() {
      _currentPhase = 1;
      _currentLineIndex = 0;
      _recognizedText = "";
      _isLineSuccess = false;
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

    if (result.finalResult) {
      _checkMatch(_recognizedText);
    }
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

  void _checkMatch(String spokenText) async {
    String expected = _cleanArabicText(storyLines[_currentLineIndex]);
    String actual = _cleanArabicText(spokenText);

    bool match = false;
    // مطابقة مرنة قليلاً
    if (actual.contains(expected) ||
        expected.contains(actual) && actual.length > expected.length ~/ 2) {
      match = true;
    } else {
      // Check word by word
      final expectedWords =
          expected.split(' ').where((w) => w.isNotEmpty).toList();
      final actualWords =
          actual.split(' ').where((w) => w.isNotEmpty).toList();
      int matchCount = 0;
      for (var w in expectedWords) {
        if (actualWords.contains(w)) matchCount++;
      }
      if (matchCount >= (expectedWords.length / 1.5).ceil()) {
        match = true;
      }
    }

    if (match) {
      setState(() => _isLineSuccess = true);
      await AppTtsService.instance.speak("أحسنت! قراءة ممتازة");
    } else {
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
        title: const Text('أقرأ مع التطبيق',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B5CF6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              const Color(0xFFD946EF).withValues(alpha: 0.05),
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
                      colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'القصة الأولى 📖',
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
                            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
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
                              ? const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isCurrent
                              ? Border.all(
                                  color: const Color(0xFF8B5CF6)
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
                                ? const Color(0xFF8B5CF6)
                                : isSpoken
                                    ? const Color(0xFF2D1B69)
                                        .withValues(alpha: 0.4)
                                    : isWaiting
                                        ? const Color(0xFF2D1B69)
                                            .withValues(alpha: 0.5)
                                        : const Color(0xFF2D1B69),
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
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _playFullStory,
                  icon: const Icon(Icons.volume_up_rounded, size: 22),
                  label: const Text("استمع للقصة",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: ElevatedButton.icon(
                    onPressed: _startLineTraining,
                    icon: const Icon(Icons.play_arrow_rounded, size: 24),
                    label: const Text("اضغط لتبدأ القراءة",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD946EF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── المرحلة الثانية: قراءة جملة جملة مع الصورة المعبرة ─────────────
  Widget _buildTrainingPhase() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // مؤشر التقدم
              _buildProgressIndicator(),
              const SizedBox(height: 16),

              // الصورة المعبرة عن الجملة
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    lineImages[_currentLineIndex],
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // التعليمات
              const Text('اقرأ هذه الجملة:',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),

              // الجملة المطلوب قراءتها
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF8B5CF6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  displayLines[_currentLineIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Color(0xFF2D1B69),
                  ),
                ),
              ),

              // زر الاستماع للجملة
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _playCurrentLine,
                icon: const Icon(Icons.volume_up_rounded,
                    color: Color(0xFF8B5CF6), size: 28),
                label: const Text("استمع",
                    style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),

              // نتيجة التعرف على الصوت
              if (_recognizedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isLineSuccess
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isLineSuccess
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isLineSuccess
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: _isLineSuccess ? Colors.green : Colors.red,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'سمعتك تقول: "$_recognizedText"',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _isLineSuccess ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // زر التالي أو الميكروفون
              if (_isLineSuccess)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _nextSequence,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(
                      _currentLineIndex < storyLines.length - 1
                          ? "الجملة التالية"
                          : "إنهاء القصة 🎉",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _isListening
                      ? () => _speechToText.stop()
                      : _startListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isListening ? 90 : 75,
                    height: _isListening ? 90 : 75,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.red
                          : const Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? Colors.red
                                  : const Color(0xFF8B5CF6))
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: _isListening ? 8 : 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 36,
                        ),
                        if (!_isListening)
                          const Text(
                            'اقرأ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ── مؤشر التقدم ──────────────────────────────────────────────────
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(storyLines.length, (index) {
        bool isCompleted = index < _currentLineIndex;
        bool isCurrent = index == _currentLineIndex;
        return Container(
          width: isCurrent ? 36 : 28,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isCompleted
                ? Colors.green
                : isCurrent
                    ? const Color(0xFF8B5CF6)
                    : Colors.grey.withValues(alpha: 0.3),
          ),
        );
      }),
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
                  color: Color(0xFF8B5CF6)),
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
                backgroundColor: const Color(0xFF8B5CF6),
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
