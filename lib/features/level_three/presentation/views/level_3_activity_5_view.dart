import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class Level3Activity5View extends StatefulWidget {
  const Level3Activity5View({super.key});

  @override
  State<Level3Activity5View> createState() => _Level3Activity5ViewState();
}

class _Level3Activity5ViewState extends State<Level3Activity5View>
    with SingleTickerProviderStateMixin {
  // ─── بيانات القصة ───────────────────────────────────────────────

  /// عنوان القصة
  static const String _storyTitle = 'الصدق';

  /// جمل القصة للعرض — كل سطر يُظهر اسم المتحدث
  final List<String> _displayLines = [
    'قَالَ يُوسُفُ: "وَجَدْتُ مَحْفَظَةً فِي الشَّارِعِ وَبِهَا نُقُودٌ."',
    'قَالَ عُمَرُ: "اِحْتَفِظْ بِهَا، لَنْ يَعْرِفَ أَحَدٌ."',
    'قَالَ يُوسُفُ: "لَا، هَذَا لَيْسَ صَحِيحًا. هَذِهِ لَيْسَتْ لِي."',
    'قَالَ عُمَرُ: "وَمَاذَا سَتَفْعَلُ إِذَنْ؟"',
    'قَالَ يُوسُفُ: "سَأَبْحَثُ عَنْ صَاحِبِهَا أَوْ أُسَلِّمُهَا لِلشُّرْطَةِ."',
    'قَالَ عُمَرُ: "مَعَكَ حَقٌّ، الصِّدْقُ أَفْضَلُ مِنْ أَيِّ شَيْءٍ."',
  ];

  /// جمل القصة للنطق (بدون علامات ترقيم زائدة)
  final List<String> _ttsLines = [
    'قَالَ يُوسُفُ: وَجَدْتُ مَحْفَظَةً فِي الشَّارِعِ وَبِهَا نُقُودٌ.',
    'قَالَ عُمَرُ: اِحْتَفِظْ بِهَا، لَنْ يَعْرِفَ أَحَدٌ.',
    'قَالَ يُوسُفُ: لَا، هَذَا لَيْسَ صَحِيحًا. هَذِهِ لَيْسَتْ لِي.',
    'قَالَ عُمَرُ: وَمَاذَا سَتَفْعَلُ إِذَنْ؟',
    'قَالَ يُوسُفُ: سَأَبْحَثُ عَنْ صَاحِبِهَا أَوْ أُسَلِّمُهَا لِلشُّرْطَةِ.',
    'قَالَ عُمَرُ: مَعَكَ حَقٌّ، الصِّدْقُ أَفْضَلُ مِنْ أَيِّ شَيْءٍ.',
  ];

  /// تحديد المتحدث لكل سطر: true = يوسف، false = عمر
  /// يوسف: pitch منخفض (0.7)  — صوت أعمق
  /// عمر:  pitch مرتفع (1.2)  — صوت أعلى
  final List<bool> _isYousef = [true, false, true, false, true, false];

  double _pitchForLine(int index) {
    return _isYousef[index] ? 0.7 : 1.2;
  }

  double _rateForLine(int index) {
    return _isYousef[index] ? 0.38 : 0.42;
  }

  /// لون مميز لكل شخصية في العرض
  Color _speakerColor(int index) {
    return _isYousef[index] ? AppColors.softTeal : AppColors.slateBlue;
  }

  String _speakerName(int index) {
    return _isYousef[index] ? 'يوسف' : 'عمر';
  }

  // ─── بيانات الأسئلة ─────────────────────────────────────────────

  final List<_QuizQuestion> _questions = [
    _QuizQuestion(
      questionText: '1: فكر عمر في الاحتفاظ بالمحفظة.',
      options: ['صحيح ✅', 'خطأ ❌'],
      correctIndex: 0,
    ),
    _QuizQuestion(
      questionText: '2: قرر يوسف أن يأخذ المال لنفسه.',
      options: ['صحيح ✅', 'خطأ ❌'],
      correctIndex: 1,
    ),
    _QuizQuestion(
      questionText: '3: تصرف يوسف يدل على أنه:',
      options: ['أ) أناني', 'ب) أمين وصادق', 'ج) لا يهتم'],
      correctIndex: 1,
    ),
    _QuizQuestion(
      questionText: '4: اقتراح عمر في البداية كان:',
      options: ['أ) إعادة المحفظة', 'ب) الاحتفاظ بها', 'ج) البحث عن صاحبها'],
      correctIndex: 1,
    ),
    _QuizQuestion(
      questionText: '5: أفضل تصرف عند العثور على شيء مفقود هو:',
      options: ['أ) أخذه لنفسي', 'ب) تركه في الشارع', 'ج) إعادته لصاحبه أو تسليمه للمسؤولين'],
      correctIndex: 2,
    ),
  ];

  // ─── الحالة ─────────────────────────────────────────────────────

  /// 0 = القصة كاملة, 2 = أسئلة, 3 = انتهى
  int _currentPhase = 0;

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

  // ─── قراءة القصة كاملة مع أصوات مختلفة ──────────────────────────

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
        // تأخير بسيط بين السطور لتمييز الأصوات
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted || !_isPlayingFullStory) return;
          setState(() => _spokenLineIndex = nextIndex);
          _speakCurrentFullStoryLine();
        });
      } else {
        setState(() {
          _isPlayingFullStory = false;
          _spokenLineIndex = -1;
        });
      }
    });

    // استخدام pitch مختلف لكل شخصية
    AppTtsService.instance.speak(
      _ttsLines[_spokenLineIndex],
      pitch: _pitchForLine(_spokenLineIndex),
      speechRate: _rateForLine(_spokenLineIndex),
    );
  }

  // ─── الأسئلة ────────────────────────────────────────────────────

  void _startQuiz() {
    AppTtsService.instance.stop();
    setState(() {
      _currentPhase = 2;
      _isPlayingFullStory = false;
    });
  }

  void _checkAnswers() {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء الإجابة على جميع الأسئلة'),
            backgroundColor: Colors.orange),
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
      AppTtsService.instance
          .speak('ممتاز! لقد أنهيت القصة والأسئلة بنجاح! أحسنت!');
      setState(() => _currentPhase = 3);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'حصلت على $_score من ${_questions.length}. بعض الإجابات تحتاج مراجعة!'),
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
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  البناء
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استمع واقرأ',
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

                // صورة القصة
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      'assets/images/Arabic/Level3/Activity1/story5/1.jpeg',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // مفتاح الشخصيات
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // يوسف
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.softTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.softTeal.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, color: AppColors.softTeal, size: 18),
                            SizedBox(width: 4),
                            Text('يوسف',
                                style: TextStyle(
                                    color: AppColors.softTeal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // عمر
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.slateBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppColors.slateBlue.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person, color: AppColors.slateBlue, size: 18),
                            SizedBox(width: 4),
                            Text('عمر',
                                style: TextStyle(
                                    color: AppColors.slateBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // نص القصة مع تأثير التتبع — كل سطر بلون المتحدث
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.softTeal.withValues(alpha: 0.15),
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
                      final lineColor = _speakerColor(index);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? lineColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isCurrent
                              ? Border.all(
                                  color: lineColor.withValues(alpha: 0.5),
                                  width: 2)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // بادج اسم المتحدث
                            if (isCurrent)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: lineColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _speakerName(index),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 400),
                              style: TextStyle(
                                fontSize: isCurrent ? 22 : 19,
                                height: 1.8,
                                fontWeight: isCurrent
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isCurrent
                                    ? lineColor
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
                          ],
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
                      onPressed: _startQuiz,
                      icon: const Icon(Icons.quiz, size: 28),
                      label: const Text('ابدأ الأسئلة 📝',
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
                    side:
                        const BorderSide(color: AppColors.softTeal, width: 2),
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

  // ── المرحلة الثانية: الأسئلة ────────────────────────────────────
  Widget _buildQuizPhase() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.softTeal.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.slateBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.help_outline,
                    color: AppColors.slateBlue),
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
                    onPressed:
                        _isQuizCompleted && _score == _questions.length
                            ? () {
                                setState(() => _currentPhase = 3);
                              }
                            : _checkAnswers,
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
                      _isQuizCompleted && _score == _questions.length
                          ? 'التالي'
                          : 'التأكد من الإجابات',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
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
                          return isSelected
                              ? AppColors.softTeal
                              : Colors.grey.shade300;
                        }
                        if (isCorrectOption) return AppColors.success;
                        if (isSelected && !isCorrectOption) {
                          return AppColors.error;
                        }
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? getStatusColor().withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: getStatusColor(),
                              width: isSelected ||
                                      (showStatus && isCorrectOption)
                                  ? 2
                                  : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? (showStatus
                                        ? (isCorrectOption
                                            ? Icons.check_circle
                                            : Icons.cancel)
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
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : Colors.grey.shade800,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                      _score = 0;
                      _selectedAnswers.clear();
                      _isQuizCompleted = false;
                    });
                    _playFullStory();
                  },
                  icon: const Icon(Icons.replay),
                  label:
                      const Text('إعادة', style: TextStyle(fontSize: 18)),
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
  final String? questionText;
  final List<String> options;
  final int correctIndex;

  _QuizQuestion({
    this.questionText,
    required this.options,
    required this.correctIndex,
  });
}
