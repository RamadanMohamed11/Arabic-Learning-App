import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/exercises/data/models/revision_test_model.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/automated_letter_trace_screen.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

class RevisionTestView extends StatefulWidget {
  final int groupNumber;
  final VoidCallback? onLetterUnlocked;
  final bool isStandalone;

  const RevisionTestView({
    super.key,
    required this.groupNumber,
    this.onLetterUnlocked,
    this.isStandalone = false,
  });

  @override
  State<RevisionTestView> createState() => _RevisionTestViewState();
}

class _RevisionTestViewState extends State<RevisionTestView> {
  late FlutterTts _flutterTts;
  late RevisionTestGroup _testGroup;
  late List<RevisionQuestion> _questions; // shuffled questions
  late List<List<String>> _shuffledOptions; // per-question shuffled options
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isTestComplete = false;
  bool _isPlaying = false;
  UserProgressService? _progressService;
  bool _letterWasUnlocked = false;

  @override
  void initState() {
    super.initState();
    _testGroup = revisionTestGroups[widget.groupNumber];
    _prepareQuestions();
    _initTts();
    _loadProgressService();
    // تشغيل الصوت تلقائياً عند بدء كل سؤال
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakLetter(_questions[_currentQuestionIndex].correctAnswer);
    });
  }

  void _prepareQuestions() {
    _questions = List<RevisionQuestion>.of(_testGroup.questions);
    _questions.shuffle();
    _shuffledOptions = _questions.map((q) {
      final opts = List<String>.of(q.options);
      opts.shuffle();
      return opts;
    }).toList();
  }

  Future<void> _loadProgressService() async {
    _progressService = await UserProgressService.getInstance();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await TtsConfig.configure(_flutterTts, speechRate: 0.4, pitch: 1.0);

    _flutterTts.setStartHandler(() {
      setState(() {
        _isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _speakLetter(String letter) async {
    await _flutterTts.speak(letter);
  }

  void _checkAnswer(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (answer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _testGroup.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
      // تشغيل الحرف الجديد
      Future.delayed(const Duration(milliseconds: 300), () {
        _speakLetter(_questions[_currentQuestionIndex].correctAnswer);
      });
    } else {
      // بعد انتهاء الأسئلة
      if (widget.isStandalone) {
        // إذا كان الاختبار منفصل، عرض النتيجة فقط
        setState(() {
          _isTestComplete = true;
        });
        _checkAndUnlockNextLetters();
      } else {
        // إذا كان الاختبار متكامل، انتقل إلى تمرين الكتابة
        _startWritingPractice();
      }
    }
  }

  /// بدء تمرين الكتابة للحرف الأول من المجموعة
  void _startWritingPractice() {
    final letterToWrite = _testGroup.letters[0]; // الحرف الأول من المجموعة
    final letterIndex = _getLetterIndex(letterToWrite);

    Navigator.push(
      context,
      AnimatedRoute.slideScale(
        AutomatedLetterTraceScreen(
          svgAssetPath: 'assets/svg/$letterToWrite.svg',
          letterIndex: letterIndex,
          onComplete: () {
            setState(() {
              _isTestComplete = true;
            });
            // التحقق من النتيجة وفتح الحروف التالية
            _checkAndUnlockNextLetters();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// الحصول على فهرس الحرف في الأبجدية العربية
  int _getLetterIndex(String letter) {
    const arabicLetters = [
      'ا',
      'ب',
      'ت',
      'ث',
      'ج',
      'ح',
      'خ',
      'د',
      'ذ',
      'ر',
      'ز',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ع',
      'غ',
      'ف',
      'ق',
      'ك',
      'ل',
      'م',
      'ن',
      'ه',
      'و',
      'ي',
    ];
    return arabicLetters.indexOf(letter);
  }

  /// فتح الحرف التالي إذا كانت النتيجة 100%
  Future<void> _checkAndUnlockNextLetters() async {
    if (_progressService == null) return;

    // التحقق من أن الإجابات كلها صحيحة
    final isPerfectScore = _score == _testGroup.questions.length;

    // إذا كان الاختبار منفصل، حفظ النتيجة للاستماع فقط
    if (widget.isStandalone && isPerfectScore) {
      await _progressService!.completeRevisionListening(widget.groupNumber);
    }

    if (isPerfectScore) {
      // Mark this revision as completed
      await _progressService!.completeRevision(widget.groupNumber);

      // حساب فهرس الحرف التالي
      // كل مجموعة تحتوي على 4 حروف
      final nextLetterIndex = (widget.groupNumber + 1) * 4;

      // فتح الحرف التالي فقط (إذا كان موجوداً)
      if (nextLetterIndex < 28) {
        await _progressService!.unlockLetter(nextLetterIndex);

        // تحديث شريط التقدم
        final unlockedCount = _progressService!.getUnlockedLetters().length;
        final progress = (unlockedCount / 28) * 100;
        await _progressService!.setLevel1Progress(progress);

        // تعيين العلم للإشارة إلى أن حرفاً تم فتحه
        _letterWasUnlocked = true;

        // استدعاء callback إذا كان موجوداً
        widget.onLetterUnlocked?.call();
      }

      // فتح الدرس/المجموعة التالية
      if (widget.groupNumber < 6) {
        // 7 مجموعات (0-6)
        await _progressService!.unlockLevel1Lesson(widget.groupNumber + 1);
      }
    }
  }

  void _restartTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _isAnswered = false;
      _isTestComplete = false;
      _prepareQuestions();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _speakLetter(_questions[_currentQuestionIndex].correctAnswer);
    });
  }

  /// الحصول على نص الحرف المفتوح الجديد
  String _getUnlockedLettersText() {
    if (widget.groupNumber >= 6) return '';

    final nextLetterIndex = (widget.groupNumber + 1) * 4;
    if (nextLetterIndex < 28) {
      // الحصول على الحرف من المجموعة التالية (أول حرف)
      final nextGroupNumber = widget.groupNumber + 1;
      if (nextGroupNumber < revisionTestGroups.length) {
        return revisionTestGroups[nextGroupNumber].letters[0];
      }
    }
    return '';
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestComplete) {
      return _buildResultsScreen();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _testGroup.questions.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.exercise2[0].withOpacity(0.2),
              AppColors.exercise2[1].withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.exercise2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.exercise2[0].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${_testGroup.emoji} ${_testGroup.title}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'السؤال ${_currentQuestionIndex + 1} من ${_testGroup.questions.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              // Question Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Listen Button
                      GestureDetector(
                        onTap: () =>
                            _speakLetter(currentQuestion.correctAnswer),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppColors.primaryGradient,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying ? Icons.volume_up : Icons.headphones,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'استمع واختر الحرف الصحيح',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'اضغط على السماعة للاستماع مرة أخرى',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Options Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                        itemCount:
                            _shuffledOptions[_currentQuestionIndex].length,
                        itemBuilder: (context, index) {
                          final option =
                              _shuffledOptions[_currentQuestionIndex][index];
                          final isCorrect =
                              option == currentQuestion.correctAnswer;
                          final isSelected = option == _selectedAnswer;

                          Color getBackgroundColor() {
                            if (!_isAnswered) {
                              return Colors.white;
                            }
                            if (isSelected) {
                              return isCorrect
                                  ? AppColors.success
                                  : AppColors.error;
                            }
                            if (isCorrect) {
                              return AppColors.success.withOpacity(0.5);
                            }
                            return Colors.grey.shade200;
                          }

                          return GestureDetector(
                            onTap: () => _checkAnswer(option),
                            child: Container(
                              decoration: BoxDecoration(
                                color: getBackgroundColor(),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isAnswered && isSelected
                                      ? Colors.transparent
                                      : AppColors.primary.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _isAnswered &&
                                                (isSelected || isCorrect)
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (_isAnswered && isSelected) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        isCorrect
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Next Button
                      if (_isAnswered)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
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
                            children: [
                              Text(
                                _currentQuestionIndex <
                                        _testGroup.questions.length - 1
                                    ? 'السؤال التالي'
                                    : 'إنهاء الاختبار',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward),
                            ],
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
    );
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _testGroup.questions.length * 100).round();
    final isPassed = percentage >= 75;
    final isPerfectScore = _score == _testGroup.questions.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isPassed
                ? [
                    AppColors.success.withOpacity(0.3),
                    AppColors.success.withOpacity(0.1),
                  ]
                : [
                    AppColors.warning.withOpacity(0.3),
                    AppColors.warning.withOpacity(0.1),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  isPassed ? '🎉' : '💪',
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 16),
                Text(
                  isPerfectScore
                      ? 'مذهل! 🌟'
                      : isPassed
                      ? 'ممتاز!'
                      : 'حاول مرة أخرى',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPerfectScore
                      ? 'إجابات مثالية! تم فتح الحرف التالي 🎉'
                      : isPassed
                      ? 'أحسنت! لقد أتقنت هذه المجموعة'
                      : 'استمر في التدريب لتحسين نتيجتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Score Card
                Container(
                  padding: const EdgeInsets.all(24),
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
                      const Text(
                        'نتيجتك',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$_score',
                            style: TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: isPassed
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          Text(
                            ' / ${_testGroup.questions.length}',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isPassed
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Show unlocked letters if perfect score
                if (isPerfectScore && widget.groupNumber < 6)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.lock_open,
                              color: AppColors.success,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'حرف جديد مفتوح!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getUnlockedLettersText(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  height: isPerfectScore && widget.groupNumber < 6 ? 24 : 32,
                ),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _restartTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'إعادة الاختبار',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // In standalone mode, only pop once to return to revision selection
                          // In integrated mode, pop twice to return to level view
                          Navigator.pop(context, _letterWasUnlocked);
                          if (!widget.isStandalone) {
                            Navigator.pop(context, _letterWasUnlocked);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.home),
                        label: const Text(
                          'العودة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
