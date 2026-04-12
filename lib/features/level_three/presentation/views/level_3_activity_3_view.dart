import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class Level3Activity3View extends StatefulWidget {
  const Level3Activity3View({super.key});

  @override
  State<Level3Activity3View> createState() => _Level3Activity3ViewState();
}

class _Level3Activity3ViewState extends State<Level3Activity3View>
    with SingleTickerProviderStateMixin {
  // ─── بيانات القصة ───────────────────────────────────────────────

  /// عنوان القصة
  static const String _storyTitle = 'أمنيه والنظافة 🧹';

  /// جمل القصة للعرض
  final List<String> _displayLines = [
    'أُمْنِيَةُ طِفْلَةٌ صَغِيرَةٌ تُحِبُّ تَنَاوُلَ الْحَلْوَى.',
    'فِي يَوْمٍ مِنَ الْأَيَّامِ، أَكَلَتْ أُمْنِيَةُ حَلْوَى،',
    'ثُمَّ رَمَتِ الْغِلَافَ عَلَى الْأَرْضِ.',
    'قَالَتْ لَهَا أُمُّهَا: يَا أُمْنِيَةُ، هَذَا خَطَأٌ،',
    'يَجِبُ أَنْ تَكُونَ الْأَرْضُ نَظِيفَةً.',
    'فَكَّرَتْ أُمْنِيَةُ قَلِيلًا،',
    'ثُمَّ فَهِمَتِ الصَّوَابَ.',
    'ذَهَبَتْ وَأَحْضَرَتِ الْغِلَافَ،',
    'وَرَمَتْهُ فِي سَلَّةِ الْقُمَامَةِ.',
    'وَقَالَتْ: سَأُحَافِظُ عَلَى نَظَافَةِ الْمَكَانِ.',
  ];

  /// جمل القصة للنطق
  final List<String> _ttsLines = [
    'أُمْنِيَةُ طِفْلَةٌ صَغِيرَةٌ تُحِبُّ تَنَاوُلَ الْحَلْوَى.',
    'فِي يَوْمٍ مِنَ الْأَيَّامِ، أَكَلَتْ أُمْنِيَةُ حَلْوَى،',
    'ثُمَّ رَمَتِ الْغِلَافَ عَلَى الْأَرْضِ.',
    'قَالَتْ لَهَا أُمُّهَا: يَا أُمْنِيَةُ، هَذَا خَطَأٌ،',
    'يَجِبُ أَنْ تَكُونَ الْأَرْضُ نَظِيفَةً.',
    'فَكَّرَتْ أُمْنِيَةُ قَلِيلًا،',
    'ثُمَّ فَهِمَتِ الصَّوَابَ.',
    'ذَهَبَتْ وَأَحْضَرَتِ الْغِلَافَ،',
    'وَرَمَتْهُ فِي سَلَّةِ الْقُمَامَةِ.',
    'وَقَالَتْ: سَأُحَافِظُ عَلَى نَظَافَةِ الْمَكَانِ.',
  ];

  // ─── بيانات الأسئلة ─────────────────────────────────────────────

  final List<_QuizQuestion> _questions = [
    _QuizQuestion(
      questionText: '1. هل تصرّف أمنية في رمي الغلاف على الأرض صحيح أم خطأ؟',
      options: ['أ) صحيح', 'ب) خطأ'],
      correctIndex: 1,
    ),
    _QuizQuestion(
      questionText: '2. ماذا قالت الأم؟',
      options: ['أ) هذا صحيح', 'ب) هذا خطأ ويجب أن نحافظ على النظافة', 'ج) لا تهتمي'],
      correctIndex: 1,
    ),
    _QuizQuestion(
      questionText: '3. أين يجب أن نرمي القمامة؟',
      options: ['أ) في الأرض', 'ب) في الشارع', 'ج) في سلة القمامة'],
      correctIndex: 2,
    ),
    _QuizQuestion(
      questionText: '4. ماذا فعلت أمنية في النهاية؟',
      options: ['أ) تركت الغلاف', 'ب) رمت الغلاف في سلة القمامة', 'ج) لعبت بالغلاف'],
      correctIndex: 1,
    ),
    _QuizQuestion(
      questionText: '5. ماذا تعلمت من قصة أمنية؟',
      options: ['أ) نرمي القمامة في أي مكان', 'ب) نحافظ على نظافة المكان', 'ج) نترك المكان متسخًا'],
      correctIndex: 1,
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
  final Map<int, int> _selectedAnswers = {};
  bool _isQuizCompleted = false;
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
    _checkMatch(_recognizedText, isFinal: result.finalResult);
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

  void _checkMatch(String spokenText, {bool isFinal = false}) async {
    // إذا تمت الإجابة بنجاح مسبقاً في هذه الجملة، لا تفعل شيئاً.
    if (_isLineSuccess) return;

    String expected = _cleanArabicText(_ttsLines[_currentLineIndex]);
    String actual = _cleanArabicText(spokenText);

    bool match = false;
    // مطابقة مرنة قليلاً للنتيجة النهائية أو الجزئية
    if (actual.contains(expected) ||
        (expected.contains(actual) && actual.length >= expected.length * 0.7)) {
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
      await _speechToText.stop();
      if (!mounted) return;
      setState(() {
        _isLineSuccess = true;
        _isListening = false;
      });
      await AppTtsService.instance.stop();
      await AppTtsService.instance.speak('أحسنت! قراءة ممتازة');
    } else if (isFinal) {
      await AppTtsService.instance.stop();
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
        _selectedAnswers.clear();
        _isQuizCompleted = false;
        _score = 0;
      });
      AppTtsService.instance.speak(
        'ممتاز! الآن قم بحل الأسئلة الممتعة',
      );
    }
  }

  // ─── الأسئلة ────────────────────────────────────────────────────

  void _checkAnswers() {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء الإجابة على جميع الأسئلة'), backgroundColor: Colors.orange),
      );
      return;
    }

    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctIndex) {
        correct++;
      }
    }

    setState(() {
      _score = correct;
      _isQuizCompleted = true;
    });

    if (correct == _questions.length) {
      AppTtsService.instance.speak('ممتاز! لقد أنهيت القصة والأسئلة بنجاح! أحسنت!');
      setState(() => _currentPhase = 3);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حصلت على $_score من ${_questions.length}. بعض الإجابات تحتاج مراجعة!'),
          backgroundColor: AppColors.error,
        ),
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
        backgroundColor: AppColors.softTeal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.softTeal.withValues(alpha: 0.1),
              AppColors.slateBlue.withValues(alpha: 0.05),
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
                      colors: [AppColors.softTeal, AppColors.slateBlue],
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      'assets/images/Arabic/Level3/Activity1/story3/1.jpeg',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
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
                            AppColors.softTeal.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.softTeal.withValues(alpha: 0.2),
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
                              ? AppColors.softTeal
                                  .withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isCurrent
                              ? Border.all(
                                  color: AppColors.softTeal
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
                                ? AppColors.softTeal
                                : isSpoken
                                    ? AppColors.textPrimary
                                        .withValues(alpha: 0.4)
                                    : isWaiting
                                        ? AppColors.textPrimary
                                            .withValues(alpha: 0.5)
                                        : AppColors.textPrimary,
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
                        backgroundColor: AppColors.softTeal,
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
                    foregroundColor: AppColors.softTeal,
                    side: const BorderSide(color: AppColors.softTeal, width: 2),
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
                            ? AppColors.softTeal
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
                            AppColors.softTeal.withValues(alpha: 0.15),
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

  // ── المرحلة الثالثة: الأسئلة ────────────────────────────────────
  Widget _buildQuizPhase() {
    return Column(
      children: [
        // Questions Header
        Container(
          margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.slateBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: AppColors.slateBlue),
              ),
              const SizedBox(width: 12),
              const Text(
                'الأسئلة:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slateBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: _questions.length + 1,
            itemBuilder: (context, index) {
              if (index == _questions.length) {
                // Submit Button
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 40),
                  child: ElevatedButton(
                    onPressed: _isQuizCompleted && _score == _questions.length ? () {
                      setState(() => _currentPhase = 3);
                    } : _checkAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _isQuizCompleted && _score == _questions.length ? 'التالي' : 'التأكد من الإجابات',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              
              final q = _questions[index];
              int correctIndex = q.correctIndex;
              int? selectedIndex = _selectedAnswers[index];
              bool showStatus = _isQuizCompleted;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.softTeal.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.questionText ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(q.options.length, (optIndex) {
                      bool isSelected = selectedIndex == optIndex;
                      bool isCorrectOption = correctIndex == optIndex;
                      
                      Color getStatusColor() {
                        if (!showStatus) {
                          return isSelected ? AppColors.softTeal : Colors.grey.shade300;
                        }
                        if (isCorrectOption) return AppColors.success;
                        if (isSelected && !isCorrectOption) return AppColors.error;
                        return Colors.grey.shade300;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!_isQuizCompleted) {
                            setState(() {
                              _selectedAnswers[index] = optIndex;
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? getStatusColor().withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getStatusColor(),
                              width: isSelected || (showStatus && isCorrectOption) ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected 
                                    ? (showStatus 
                                          ? (isCorrectOption ? Icons.check_circle : Icons.cancel)
                                          : Icons.radio_button_checked)
                                    : (showStatus && isCorrectOption
                                          ? Icons.check_circle_outline
                                          : Icons.radio_button_unchecked),
                                color: getStatusColor(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  q.options[optIndex],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected ? AppColors.textPrimary : Colors.grey.shade800,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
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
                color: AppColors.softTeal,
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
                  colors: [AppColors.softTeal, AppColors.slateBlue],
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
                      _score = 0;
                      _recognizedText = '';
                      _isLineSuccess = false;
                      _selectedAnswers.clear();
                      _isQuizCompleted = false;
                    });
                    _playFullStory();
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('إعادة', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softTeal,
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
  final String? imagePath;
  final String? questionText;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    this.imagePath,
    this.questionText,
    required this.options,
    required this.correctIndex,
  });
}
