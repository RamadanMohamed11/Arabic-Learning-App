import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Level3Activity2View extends StatefulWidget {
  const Level3Activity2View({super.key});

  @override
  State<Level3Activity2View> createState() => _Level3Activity2ViewState();
}

class _Level3Activity2ViewState extends State<Level3Activity2View>
    with SingleTickerProviderStateMixin {
  // ─── بيانات القصة ───────────────────────────────────────────────

  /// عنوان القصة
  static const String _storyTitle = 'كوب ماء يغيّر يومك 💧';

  /// جمل القصة للعرض (بدون تشكيل)
  final List<String> _displayLines = [
    'في الصباح، خرجت سارة من منزلها مسرعة ونسيت أن تشرب الماء.',
    'بعد قليل شعرت بالتعب والصداع، ولم تستطع التركيز في عملها.',
    'تذكّرت أن جسدها يحتاج إلى الماء، فشربت كوبين.',
    'فعادت إليها طاقتها وأصبحت أكثر تركيزًا.',
    'ومنذ ذلك اليوم، قررت أن تبدأ يومها بكوب ماء.',
  ];

  /// جمل القصة للنطق (بالتشكيل)
  final List<String> _ttsLines = [
    'فِي الصَّبَاحِ، خَرَجَتْ سَارَةُ مِنْ مَنْزِلِهَا مُسْرِعَةً وَنَسِيَتْ أَنْ تَشْرَبَ الْمَاءَ.',
    'بَعْدَ قَلِيلٍ شَعَرَتْ بِالتَّعَبِ وَالصُّدَاعِ، وَلَمْ تَسْتَطِعِ التَّرْكِيزَ فِي عَمَلِهَا.',
    'تَذَكَّرَتْ أَنَّ جَسَدَهَا يَحْتَاجُ إِلَى الْمَاءِ، فَشَرِبَتْ كُوبَيْنِ.',
    'فَعَادَتْ إِلَيْهَا طَاقَتُهَا وَأَصْبَحَتْ أَكْثَرَ تَرْكِيزًا.',
    'وَمُنْذُ ذَلِكَ الْيَوْمِ، قَرَّرَتْ أَنْ تَبْدَأَ يَوْمَهَا بِكُوبِ مَاءٍ.',
  ];

  // ─── بيانات الأسئلة ─────────────────────────────────────────────

  final List<_QuizQuestion> _questions = [
    _QuizQuestion(
      imagePath: 'assets/images/Arabic/Level3/Activity1/story2/1.jpeg',
      options: [
        'خرجت سارة من منزلها بهدوء.',
        'خرجت سارة من منزلها مسرعة.',
        'جلست سارة في منزلها.',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      imagePath: 'assets/images/Arabic/Level3/Activity1/story2/2.jpeg',
      options: [
        'شعرت سارة بالسعادة والنشاط.',
        'شعرت سارة بالجوع فقط.',
        'شعرت سارة بالتعب والصداع.',
      ],
      correctIndex: 2,
    ),
    _QuizQuestion(
      imagePath: 'assets/images/Arabic/Level3/Activity1/story2/3.jpeg',
      options: [
        'شربت سارة العصير.',
        'شربت سارة كوبين من الماء.',
        'تجاهلت سارة شرب الماء.',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      imagePath: 'assets/images/Arabic/Level3/Activity1/story2/4.jpeg',
      options: [
        'أصبحت سارة أكثر تعبًا.',
        'نامت سارة فورًا.',
        'أصبحت سارة أكثر نشاطًا وتركيزًا.',
      ],
      correctIndex: 2,
    ),
  ];

  // ─── الحالة ─────────────────────────────────────────────────────

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  /// 0 = القصة كاملة, 1 = قراءة جملة جملة, 2 = أسئلة, 3 = انتهى
  int _currentPhase = 0;
  int _currentLineIndex = 0;

  String _recognizedText = '';
  bool _isLineSuccess = false;

  // تتبع سطر القراءة الحالي (المرحلة 0)
  int _spokenLineIndex = -1;
  bool _isPlayingFullStory = false;

  // حالة الأسئلة
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _isAnswerCorrect = false;
  bool _hasAnswered = false;
  bool _hasReadAnswer = false;
  int _score = 0;

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
          setState(() => _isListening = status == 'listening');
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) {
      setState(() => _speechEnabled = available);
    }
  }

  // ─── قراءة القصة كاملة ──────────────────────────────────────────

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
        _spokenLineIndex >= _ttsLines.length ||
        !_isPlayingFullStory) {
      if (mounted) {
        setState(() {
          _isPlayingFullStory = false;
          _spokenLineIndex = -1;
        });
      }
      return;
    }

    AppTtsService.instance.setCompletionHandler(() {
      if (!mounted || !_isPlayingFullStory) return;
      final nextIndex = _spokenLineIndex + 1;
      if (nextIndex < _ttsLines.length) {
        setState(() => _spokenLineIndex = nextIndex);
        _speakCurrentFullStoryLine();
      } else {
        setState(() {
          _isPlayingFullStory = false;
          _spokenLineIndex = -1;
        });
      }
    });

    AppTtsService.instance.speak(_ttsLines[_spokenLineIndex], pitch: 0.8);
  }

  // ─── قراءة جملة جملة ────────────────────────────────────────────

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
    await AppTtsService.instance.speak(
      _ttsLines[_currentLineIndex],
      pitch: 0.8,
    );
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeechToText();
      if (!_speechEnabled) {
        AppTtsService.instance.speak('خاصية التعرف على الصوت غير مفعلة');
        return;
      }
    }
    await _speechToText.stop();
    await AppTtsService.instance.stop();
    setState(() {
      _recognizedText = '';
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
    setState(() => _recognizedText = result.recognizedWords.trim());
    if (result.finalResult) {
      _checkMatch(_recognizedText);
    }
  }

  String _cleanArabicText(String text) {
    String clean = text.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
    clean = clean.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    clean =
        clean.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    clean = clean.replaceAll('ى', 'ي');
    clean = clean.replaceAll('ة', 'ه');
    return clean.trim();
  }

  void _checkMatch(String spokenText) async {
    String expected = _cleanArabicText(_ttsLines[_currentLineIndex]);
    String actual = _cleanArabicText(spokenText);

    bool match = false;
    if (actual.contains(expected) ||
        expected.contains(actual) && actual.length > expected.length ~/ 2) {
      match = true;
    } else {
      final expectedWords =
          expected.split(' ').where((w) => w.isNotEmpty).toList();
      final actualWords = actual.split(' ').where((w) => w.isNotEmpty).toList();
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
      await AppTtsService.instance.speak('أحسنت! قراءة ممتازة');
    } else {
      await AppTtsService.instance.speak('حاول مرة أخرى');
    }
  }

  void _nextLine() {
    if (_currentLineIndex < _displayLines.length - 1) {
      setState(() {
        _currentLineIndex++;
        _recognizedText = '';
        _isLineSuccess = false;
      });
      _playCurrentLine();
    } else {
      // انتقل للأسئلة
      setState(() {
        _currentPhase = 2;
        _currentQuestionIndex = 0;
        _selectedOption = null;
        _hasAnswered = false;
        _hasReadAnswer = false;
        _score = 0;
      });
      AppTtsService.instance.speak(
        'ممتاز! الآن أجب عن الأسئلة واقرأ الإجابة الصحيحة',
      );
    }
  }

  // ─── الأسئلة ────────────────────────────────────────────────────

  void _selectOption(int index) {
    if (_hasAnswered) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = index == question.correctIndex;

    setState(() {
      _selectedOption = index;
      _hasAnswered = true;
      _isAnswerCorrect = isCorrect;
      if (isCorrect) _score++;
    });

    if (isCorrect) {
      AppTtsService.instance.speak('إجابة صحيحة! الآن اقرأ الإجابة بصوتك');
    } else {
      AppTtsService.instance.speak(
        'إجابة خاطئة. الإجابة الصحيحة هي: ${question.options[question.correctIndex]}',
      );
      // auto-set to read after wrong answer
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_hasReadAnswer) {
          setState(() => _hasReadAnswer = true);
        }
      });
    }
  }

  Future<void> _readAnswer() async {
    if (!_speechEnabled) {
      await _initSpeechToText();
      if (!_speechEnabled) {
        AppTtsService.instance.speak('خاصية التعرف على الصوت غير مفعلة');
        return;
      }
    }
    await _speechToText.stop();
    await AppTtsService.instance.stop();
    setState(() {
      _recognizedText = '';
      _isListening = true;
    });

    await _speechToText.listen(
      onResult: _onAnswerSpeechResult,
      localeId: 'ar-SA',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _onAnswerSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _recognizedText = result.recognizedWords.trim());
    if (result.finalResult) {
      _checkAnswerRead(result.recognizedWords.trim());
    }
  }

  void _checkAnswerRead(String spokenText) async {
    final question = _questions[_currentQuestionIndex];
    final correctText = question.options[question.correctIndex];
    final expected = _cleanArabicText(correctText);
    final actual = _cleanArabicText(spokenText);

    bool match = false;
    if (actual.contains(expected) ||
        expected.contains(actual) && actual.length > expected.length ~/ 3) {
      match = true;
    } else {
      final expectedWords =
          expected.split(' ').where((w) => w.isNotEmpty).toList();
      final actualWords = actual.split(' ').where((w) => w.isNotEmpty).toList();
      int matchCount = 0;
      for (var w in expectedWords) {
        if (actualWords.contains(w)) matchCount++;
      }
      if (matchCount >= (expectedWords.length / 2).ceil()) {
        match = true;
      }
    }

    if (match) {
      setState(() => _hasReadAnswer = true);
      await AppTtsService.instance.speak('أحسنت! قراءة رائعة');
    } else {
      await AppTtsService.instance.speak('حاول مرة أخرى');
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _hasAnswered = false;
        _hasReadAnswer = false;
        _isAnswerCorrect = false;
        _recognizedText = '';
      });
    } else {
      setState(() => _currentPhase = 3);
      AppTtsService.instance.speak(
        'ممتاز! لقد أنهيت القصة والأسئلة بنجاح! أحسنت!',
      );
    }
  }

  // ─── التنظيف ────────────────────────────────────────────────────

  @override
  void dispose() {
    _pulseController.dispose();
    AppTtsService.instance.stop();
    _speechToText.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  البناء
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كوب ماء يغيّر يومك',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFD946EF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFD946EF).withValues(alpha: 0.1),
              const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: _currentPhase == 0
              ? _buildFullStoryPhase()
              : _currentPhase == 1
                  ? _buildTrainingPhase()
                  : _currentPhase == 2
                      ? _buildQuizPhase()
                      : _buildCompletionPhase(),
        ),
      ),
    );
  }

  // ── المرحلة الأولى: القصة كاملة ─────────────────────────────────
  Widget _buildFullStoryPhase() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                // عنوان
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_stories, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        _storyTitle,
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

                // نص القصة مع تأثير التتبع
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFFD946EF).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFD946EF).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children:
                        List.generate(_displayLines.length, (index) {
                      final isCurrent =
                          _isPlayingFullStory && _spokenLineIndex == index;
                      final isSpoken =
                          _isPlayingFullStory && _spokenLineIndex > index;
                      final isWaiting =
                          _isPlayingFullStory && _spokenLineIndex < index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFFD946EF)
                                  .withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isCurrent
                              ? Border.all(
                                  color: const Color(0xFFD946EF)
                                      .withValues(alpha: 0.4),
                                  width: 1.5)
                              : null,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: TextStyle(
                            fontSize: isCurrent ? 24 : 20,
                            height: 1.8,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCurrent
                                ? const Color(0xFFD946EF)
                                : isSpoken
                                    ? const Color(0xFF2D1B69)
                                        .withValues(alpha: 0.4)
                                    : isWaiting
                                        ? const Color(0xFF2D1B69)
                                            .withValues(alpha: 0.5)
                                        : const Color(0xFF2D1B69),
                          ),
                          child: Text(
                            _displayLines[index],
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

        // أزرار ثابتة
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
                        backgroundColor: const Color(0xFFD946EF),
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
                    foregroundColor: const Color(0xFFD946EF),
                    side: const BorderSide(color: Color(0xFFD946EF), width: 2),
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
            children: List.generate(_displayLines.length, (i) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i < _currentLineIndex
                        ? Colors.green
                        : i == _currentLineIndex
                            ? const Color(0xFFD946EF)
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
                        color:
                            const Color(0xFFD946EF).withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    _displayLines[_currentLineIndex],
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
                            color:
                                _isLineSuccess ? Colors.green : Colors.orange,
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
                  label:
                      const Text('استمع', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
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
                  onPressed: _isLineSuccess ? _nextLine : _startListening,
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
                            : const Color(0xFFD946EF),
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

  // ── المرحلة الثالثة: الأسئلة ────────────────────────────────────
  Widget _buildQuizPhase() {
    final question = _questions[_currentQuestionIndex];

    return Column(
      children: [
        // شريط تقدم الأسئلة
        Container(
          margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              Text(
                'سؤال ${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD946EF),
                ),
              ),
              const Spacer(),
              Text(
                'النقاط: $_score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // صورة السؤال
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    question.imagePath,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),

                // الخيارات
                ...List.generate(question.options.length, (i) {
                  final isSelected = _selectedOption == i;
                  final isCorrectOption = i == question.correctIndex;

                  Color bgColor = Colors.white;
                  Color borderColor = Colors.grey.shade300;
                  Color textColor = const Color(0xFF2D1B69);

                  if (_hasAnswered) {
                    if (isCorrectOption) {
                      bgColor = Colors.green.withValues(alpha: 0.15);
                      borderColor = Colors.green;
                      textColor = Colors.green.shade800;
                    } else if (isSelected && !_isAnswerCorrect) {
                      bgColor = Colors.red.withValues(alpha: 0.15);
                      borderColor = Colors.red;
                      textColor = Colors.red.shade800;
                    }
                  } else if (isSelected) {
                    bgColor =
                        const Color(0xFFD946EF).withValues(alpha: 0.1);
                    borderColor = const Color(0xFFD946EF);
                  }

                  return GestureDetector(
                    onTap: () => _selectOption(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // حرف الخيار
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: borderColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                ['أ', 'ب', 'ج'][i],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[i],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (_hasAnswered && isCorrectOption)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 28),
                          if (_hasAnswered &&
                              isSelected &&
                              !isCorrectOption)
                            const Icon(Icons.cancel,
                                color: Colors.red, size: 28),
                        ],
                      ),
                    ),
                  );
                }),

                // نتيجة قراءة الإجابة
                if (_hasAnswered && _isAnswerCorrect && !_hasReadAnswer) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD946EF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD946EF),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎤 اقرأ الإجابة الصحيحة بصوتك',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD946EF),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _readAnswer,
                          icon: Icon(
                            _isListening ? Icons.hearing : Icons.mic,
                            size: 24,
                          ),
                          label: Text(
                            _isListening ? 'جارٍ الاستماع...' : 'اضغط واقرأ',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isListening
                                ? Colors.red
                                : const Color(0xFFD946EF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // زر التالي (يظهر بعد الإجابة والقراءة)
        if (_hasAnswered && (_hasReadAnswer || !_isAnswerCorrect))
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_back, size: 24),
                label: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'السؤال التالي'
                      : 'إنهاء',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 6,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── المرحلة الأخيرة: الاحتفال ───────────────────────────────────
  Widget _buildCompletionPhase() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              'أحسنت!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD946EF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لقد أنهيت قصة "$_storyTitle"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF2D1B69),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD946EF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'النقاط: $_score / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentPhase = 0;
                      _currentLineIndex = 0;
                      _currentQuestionIndex = 0;
                      _score = 0;
                      _recognizedText = '';
                      _isLineSuccess = false;
                      _hasAnswered = false;
                      _hasReadAnswer = false;
                      _selectedOption = null;
                    });
                    _playFullStory();
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('إعادة', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label:
                      const Text('إنهاء', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── نموذج السؤال ─────────────────────────────────────────────────
class _QuizQuestion {
  final String imagePath;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.imagePath,
    required this.options,
    required this.correctIndex,
  });
}
