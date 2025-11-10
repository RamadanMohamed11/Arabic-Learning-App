import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/level_one/data/models/final_test_model.dart';
import 'package:arabic_learning_app/features/level_one/presentation/widgets/image_to_character_question.dart';
import 'package:arabic_learning_app/features/level_one/presentation/widgets/pronunciation_question.dart';
import 'package:arabic_learning_app/features/level_one/presentation/widgets/listen_and_write_question.dart';

/// Main coordinator for the Final Level One Test
/// Manages 10 questions across 2 types (5 image-to-character + 5 pronunciation) and handles scoring/progression
class FinalLevelOneTestView extends StatefulWidget {
  const FinalLevelOneTestView({super.key});

  @override
  State<FinalLevelOneTestView> createState() => _FinalLevelOneTestViewState();
}

class _FinalLevelOneTestViewState extends State<FinalLevelOneTestView> {
  UserProgressService? _progressService;

  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isTestComplete = false;

  late List<FinalTestQuestion> _questions;
  late List<List<String>> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
    _loadProgressService();
  }

  void _prepareQuestions() {
    _questions = List.from(finalLevelOneQuestions);

    // Shuffle options for image-to-character questions
    _shuffledOptions = _questions.map((q) {
      if (q.options.isNotEmpty) {
        final opts = List<String>.of(q.options);
        opts.shuffle();
        return opts;
      }
      return <String>[];
    }).toList();
  }

  Future<void> _loadProgressService() async {
    _progressService = await UserProgressService.getInstance();
  }

  void _onAnswerSelected(String answer) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (answer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _onPronunciationCorrect() {
    setState(() {
      _score++;
    });
  }

  void _onListenAndWriteComplete() {
    setState(() {
      _score++;
    });
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    setState(() {
      _isTestComplete = true;
    });
    _evaluateAndSaveResults();
  }

  Future<void> _evaluateAndSaveResults() async {
    if (_progressService == null) return;

    final percentage = (_score / _questions.length * 100).round();
    final isPassed = percentage >= 80;

    if (isPassed) {
      // Mark level 1 as complete
      await _progressService!.setLevel1Completed(true);
      // Set level 1 progress to 100%
      await _progressService!.setLevel1Progress(100.0);
      // Unlock level 2
      await _progressService!.unlockLevel2();
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestComplete) {
      return _buildResultsScreen();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
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
              _buildHeader(progress),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildQuestionContent(currentQuestion),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.level1),
        boxShadow: [
          BoxShadow(
            color: AppColors.level1[0].withOpacity(0.3),
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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      '🧠 اختبار نهاية المستوى الأول',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'السؤال ${_currentQuestionIndex + 1} من ${_questions.length}',
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
                    const Icon(Icons.star, color: Colors.amber, size: 18),
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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(FinalTestQuestion question) {
    switch (question.type) {
      case QuestionType.imageToCharacter:
        return ImageToCharacterQuestion(
          question: question,
          shuffledOptions: _shuffledOptions[_currentQuestionIndex],
          selectedAnswer: _selectedAnswer,
          isAnswered: _isAnswered,
          onAnswerSelected: _onAnswerSelected,
          onNext: _nextQuestion,
        );

      case QuestionType.pronunciation:
        return PronunciationQuestion(
          question: question,
          onCorrect: _onPronunciationCorrect,
          onNext: _nextQuestion,
        );

      case QuestionType.listenAndWrite:
        return ListenAndWriteQuestion(
          letter: question.correctAnswer,
          onComplete: _onListenAndWriteComplete,
        );
    }
  }

  Widget _buildResultsScreen() {
    final percentage = (_score / _questions.length * 100).round();
    final isPassed = percentage >= 80;

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
                const SizedBox(height: 20),

                // Success/Retry Emoji
                Text(
                  isPassed ? '🎉' : '💪',
                  style: const TextStyle(fontSize: 100),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  isPassed ? 'مبروك! نجحت 🌟' : 'حاول مرة أخرى',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  isPassed
                      ? 'لقد أتممت المستوى الأول بنجاح!\nيمكنك الآن الانتقال إلى المستوى الثاني'
                      : 'استمر في التدريب لتحسين نتيجتك\nتحتاج إلى 80% للنجاح',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Score Card
                Container(
                  padding: const EdgeInsets.all(32),
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
                      const SizedBox(height: 24),

                      // Score Display
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
                            ' / ${_questions.length}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Percentage
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isPassed ? AppColors.success : AppColors.warning)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPassed
                                ? AppColors.success
                                : AppColors.warning,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isPassed
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Status Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPassed ? AppColors.success : AppColors.warning,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPassed ? Icons.check_circle : Icons.info_outline,
                        color: isPassed ? AppColors.success : AppColors.warning,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          isPassed
                              ? 'تم فتح المستوى الثاني'
                              : 'النتيجة المطلوبة: 12/15 (80%)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPassed
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Action Buttons
                if (isPassed) ...[
                  // Go to Level 2 Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigation to level 2 will be handled by the main app
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
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
                      children: const [
                        Text(
                          'الانتقال إلى المستوى الثاني',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Back Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'العودة إلى المستوى الأول',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ] else ...[
                  // Retry Button
                  ElevatedButton(
                    onPressed: _restartTest,
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
                      children: const [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text(
                          'إعادة الاختبار',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Back to Practice Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'العودة للتدريب',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
