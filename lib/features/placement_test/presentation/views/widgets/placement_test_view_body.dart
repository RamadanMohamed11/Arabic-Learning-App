import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:go_router/go_router.dart';
import 'package:arabic_learning_app/core/utils/app_router.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';

class PlacementTestQuestion {
  final String type; // 'writing', 'pronunciation', 'listening'
  final String question;
  final String? imagePath;
  final String correctAnswer;
  final List<String>? options; // للأسئلة متعددة الخيارات
  final String? audioText; // النص الذي سيتم نطقه

  const PlacementTestQuestion({
    required this.type,
    required this.question,
    this.imagePath,
    required this.correctAnswer,
    this.options,
    this.audioText,
  });
}

class PlacementTestViewBody extends StatefulWidget {
  const PlacementTestViewBody({super.key});

  @override
  State<PlacementTestViewBody> createState() => _PlacementTestViewBodyState();
}

class _PlacementTestViewBodyState extends State<PlacementTestViewBody> {
  final SpeechToText _speechToText = SpeechToText();
  final TextEditingController _answerController = TextEditingController();
  UserProgressService? _progressService;

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isListening = false;
  String _selectedOption = '';
  bool _testStarted = false;
  bool _showingResults = false;
  bool _isPlayingAudio = false;

  final List<PlacementTestQuestion> _questions = [
    // أسئلة الكتابة (3 أسئلة)
    PlacementTestQuestion(
      type: 'writing',
      question: 'اسمع الكلمة واكتبها',
      correctAnswer: 'كتاب',
      audioText: 'كتاب',
    ),
    PlacementTestQuestion(
      type: 'writing',
      question: 'اسمع الكلمة واكتبها',
      correctAnswer: 'مدرسة',
      audioText: 'مدرسة',
    ),
    PlacementTestQuestion(
      type: 'writing',
      question: 'اسمع الكلمة واكتبها',
      correctAnswer: 'طائر',
      audioText: 'طائر',
    ),

    // أسئلة النطق (4 أسئلة)
    PlacementTestQuestion(
      type: 'pronunciation',
      question: 'انطق الكلمة التي تراها',
      imagePath: 'قمر',
      correctAnswer: 'قمر',
    ),
    PlacementTestQuestion(
      type: 'pronunciation',
      question: 'انطق الكلمة التي تراها',
      imagePath: 'شمس',
      correctAnswer: 'شمس',
    ),
    PlacementTestQuestion(
      type: 'pronunciation',
      question: 'انطق الكلمة التي تراها',
      imagePath: 'بحر',
      correctAnswer: 'بحر',
    ),
    PlacementTestQuestion(
      type: 'pronunciation',
      question: 'انطق الكلمة التي تراها',
      imagePath: 'شجرة',
      correctAnswer: 'شجرة',
    ),

    // أسئلة التمييز السمعي (3 أسئلة) - اختر الصوت الصحيح للكلمة المكتوبة
    PlacementTestQuestion(
      type: 'listening',
      question: 'اختر الصوت الصحيح للكلمة: نجم',
      correctAnswer: 'نجم',
      options: ['قمر', 'نجم', 'شمس', 'بحر'],
      audioText: 'نجم',
      imagePath: '⭐ نجم',
    ),
    PlacementTestQuestion(
      type: 'listening',
      question: 'اختر الصوت الصحيح للكلمة: وردة',
      correctAnswer: 'وردة',
      options: ['شجرة', 'وردة', 'نجمة', 'سحابة'],
      audioText: 'وردة',
      imagePath: '🌹 وردة',
    ),
    PlacementTestQuestion(
      type: 'listening',
      question: 'اختر الصوت الصحيح للكلمة: جبل',
      correctAnswer: 'جبل',
      options: ['نهر', 'بحر', 'جبل', 'مطر'],
      audioText: 'جبل',
      imagePath: '⛰️ جبل',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initServices();
    _playWelcomeInstruction();
  }

  Future<void> _playWelcomeInstruction() async {
    if (_testStarted) return;
    await AppTtsService.instance.speakScreenIntro(
      'أهلاً بك في اختبار تحديد المستوى! سنُقَيِّمُ مستواك في اللغة العربية. اضغط على ابدأ الاختبار للبدء',
      isMounted: () => mounted,
    );
  }

  Future<void> _initServices() async {
    _progressService = await UserProgressService.getInstance();

    // تهيئة التعرف على الصوت
    try {
      await _speechToText.initialize();
    } catch (e) {
      debugPrint('Error initializing Speech to Text: $e');
    }
  }

  void _startTest() {
    AppTtsService.instance.stop(); // Stop welcome instruction
    setState(() {
      _testStarted = true;
    });
    _playQuestionInstruction();
  }

  Future<void> _playQuestionInstruction() async {
    final question = _questions[_currentQuestionIndex];
    String instruction = question.question;
    
    // If it's a listening question that includes the word, we don't want to spell the answer
    if (instruction.startsWith('اختر الصوت الصحيح للكلمة')) {
      instruction = 'اختر الصوت الصحيح للكلمة';
    }
    
    await AppTtsService.instance.speakScreenIntro(
      instruction,
      isMounted: () => mounted,
    );
  }

  Future<void> _playAudio(String text) async {
    if (_isPlayingAudio) return;
    
    setState(() {
      _isPlayingAudio = true;
    });

    try {
      await AppTtsService.instance.speak(text);
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _answerController.text = result.recognizedWords;
            });
          },
          localeId: 'ar-SA',
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  void _checkAnswer() {
    final currentQuestion = _questions[_currentQuestionIndex];
    String userAnswer = '';

    if (currentQuestion.type == 'writing') {
      userAnswer = _answerController.text.trim();
    } else if (currentQuestion.type == 'pronunciation') {
      userAnswer = _answerController.text.trim();
    } else if (currentQuestion.type == 'listening') {
      userAnswer = _selectedOption;
    }

    // تطبيع الإجابة
    String normalizedAnswer = _normalizeText(userAnswer);
    String normalizedCorrect = _normalizeText(currentQuestion.correctAnswer);

    if (normalizedAnswer == normalizedCorrect ||
        normalizedAnswer.contains(normalizedCorrect) ||
        normalizedCorrect.contains(normalizedAnswer)) {
      _score++;
    }

    _nextQuestion();
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\u064b-\u065f]'), '') // إزالة التشكيل
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[أإآ]'), 'ا');
  }

  bool _canProceed() {
    final question = _questions[_currentQuestionIndex];
    if (question.type == 'writing') {
      return _answerController.text.trim().isNotEmpty;
    } else if (question.type == 'listening') {
      return _selectedOption.isNotEmpty;
    } else if (question.type == 'pronunciation') {
      return _answerController.text.trim().isNotEmpty; // من التعرف على الصوت
    }
    return false;
  }

  void _nextQuestion() {
    // إيقاف أي صوت قيد التشغيل
    AppTtsService.instance.stop();

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answerController.clear();
        _selectedOption = '';
        _isListening = false;
        _isPlayingAudio = false;
      });
      _playQuestionInstruction();
    } else {
      _showResults();
    }
  }

  Future<void> _showResults() async {
    final percentage = (_score / _questions.length) * 100;
    final passed = percentage >= 50;

    // حفظ النتيجة
    await _progressService!.setPlacementTestScore(_score);
    await _progressService!.setFirstTime(false);

    // إعداد المستويات والدروس بناءً على النتيجة
    await _progressService!.setupLevelsAfterPlacementTest(passed: passed);

    setState(() {
      _showingResults = true;
    });
  }

  void _goToLevels() {
    // استخدام go_router بدلاً من Navigator
    context.go('/levels_selection');
  }

  @override
  void dispose() {
    _answerController.dispose();
    _speechToText.stop();
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  void deactivate() {
    // إيقاف الصوت عند مغادرة الصفحة
    AppTtsService.instance.stop();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (!_testStarted) {
      return _buildWelcomeScreen();
    }

    if (_showingResults) {
      return _buildResultsScreen();
    }

    return _buildQuestionScreen();
  }

  Widget _buildWelcomeScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - 48.0, // 48 = padding (24 * 2)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 24),
                    const Text(
                      'اختبار تحديد المستوى',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'سنقيم مستواك في اللغة العربية من خلال 10 أسئلة',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildSkillItem('✍️', 'الكتابة', 'اسمع واكتب'),
                          const SizedBox(height: 16),
                          _buildSkillItem('🗣️', 'النطق', 'اقرأ وانطق'),
                          const SizedBox(height: 16),
                          _buildSkillItem('👂', 'الاستماع', 'اسمع واختر'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _startTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ابدأ الاختبار',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            context.push(AppRouter.kAboutView);
                          },
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: 18,
                          ),
                          label: const Text(
                            'حول التطبيق',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkillItem(String emoji, String title, String description) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionScreen() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, AppColors.lightMint],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السؤال ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'النقاط: $_score',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Question Type Icon
                    Text(
                      currentQuestion.type == 'writing'
                          ? '✍️'
                          : currentQuestion.type == 'pronunciation'
                          ? '🗣️'
                          : '👂',
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 24),

                    // Question Text
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Question-specific content
                    if (currentQuestion.type == 'writing')
                      _buildWritingQuestion(currentQuestion),
                    if (currentQuestion.type == 'pronunciation')
                      _buildPronunciationQuestion(currentQuestion),
                    if (currentQuestion.type == 'listening')
                      _buildListeningQuestion(currentQuestion),

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _canProceed() ? _checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingQuestion(PlacementTestQuestion question) {
    return Column(
      children: [
        Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isPlayingAudio
                  ? null
                  : () => _playAudio(question.audioText!),
              icon: Icon(_isPlayingAudio ? Icons.volume_off : Icons.volume_up),
              label: Text(_isPlayingAudio ? 'جاري التشغيل...' : 'استمع للصوت'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _answerController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'اكتب هنا...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {}); // تحديث الزر عند الكتابة
          },
        ),
      ],
    );
  }

  Widget _buildPronunciationQuestion(PlacementTestQuestion question) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            question.imagePath!,
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        FloatingActionButton.extended(
          onPressed: _isListening ? _stopListening : _startListening,
          backgroundColor: _isListening ? AppColors.error : AppColors.success,
          icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
          label: Text(_isListening ? 'إيقاف' : 'ابدأ النطق'),
        ),
        if (_answerController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'سمعت: ${_answerController.text}',
            style: const TextStyle(fontSize: 18, color: AppColors.secondary),
          ),
        ],
      ],
    );
  }

  Widget _buildListeningQuestion(PlacementTestQuestion question) {
    return Column(
      children: [
        // عرض الكلمة مع الإيموجي
        if (question.imagePath != null)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              question.imagePath!,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          'اختر الصوت الصحيح لهذه الكلمة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        // الخيارات بدون عرض النص
        ...question.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = _selectedOption == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Opacity(
              opacity: _isPlayingAudio ? 0.5 : 1.0,
              child: InkWell(
                onTap: _isPlayingAudio
                    ? null
                    : () {
                        setState(() => _selectedOption = option);
                        _playAudio(option);
                      },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // رقم الخيار
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // أيقونة الصوت
                      Icon(
                        Icons.volume_up,
                        color: isSelected ? Colors.white : Colors.grey,
                        size: 32,
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _questions.length) * 100;
    final passed = percentage >= 50;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: passed
              ? AppColors.accentGradient
              : [AppColors.warning, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - 48.0, // 48 = padding (24 * 2)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      passed ? '🎉' : '💪',
                      style: const TextStyle(fontSize: 100),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      passed ? 'أحسنت!' : 'جيد!',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حصلت على $_score من ${_questions.length}',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'مستواك:',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            passed ? 'المستوى الثاني' : 'المستوى الأول',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            passed
                                ? 'يمكنك البدء من المستوى الثاني مباشرة!'
                                : 'سنبدأ معك من الأساسيات',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _goToLevels,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: passed
                            ? AppColors.success
                            : AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ابدأ التعلم',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
