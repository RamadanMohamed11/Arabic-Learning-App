import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_level4_data.dart';

class MathLevel4FinalTestView extends StatefulWidget {
  const MathLevel4FinalTestView({super.key});

  @override
  State<MathLevel4FinalTestView> createState() =>
      _MathLevel4FinalTestViewState();
}

class _MathLevel4FinalTestViewState extends State<MathLevel4FinalTestView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isTestComplete = false;
  bool? _passed;

  int _correctCount = 0;
  final List<Map<String, dynamic>> _results = [];

  // For write / findMissing input
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  // Animation
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();

    // Speak intro, then auto-speak first question
    AppTtsService.instance.setCompletionHandler(() {
      if (mounted) {
        AppTtsService.instance.setCompletionHandler(() {});
        _speakQuestion();
      }
    });

    AppTtsService.instance.speakScreenIntro(
      'اختبار الجمع والطرح. أجب عن الأسئلة التالية بعناية',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _slideController.dispose();
    AppTtsService.instance.stop();
    super.dispose();
  }

  FinalTestQuestion get _currentQuestion =>
      kLevel4FinalTestQuestions[_currentIndex];

  void _submitMultipleChoice(int selected) {
    if (_isTestComplete) return;

    final isCorrect = selected == _currentQuestion.correctAnswer;
    if (isCorrect) _correctCount++;

    _results.add({
      'question': _currentQuestion,
      'userAnswer': selected,
      'isCorrect': isCorrect,
    });

    _goToNext();
  }

  void _submitWrittenAnswer() {
    if (_isTestComplete) return;

    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    // Parse Arabic or English digits
    final parsed = _parseArabicNumber(text);
    if (parsed == null) return;

    final isCorrect = parsed == _currentQuestion.correctAnswer;
    if (isCorrect) _correctCount++;

    _results.add({
      'question': _currentQuestion,
      'userAnswer': parsed,
      'isCorrect': isCorrect,
    });

    _inputController.clear();
    _goToNext();
  }

  int? _parseArabicNumber(String text) {
    // Replace Arabic/Eastern digits with Western
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String normalized = text;
    for (int i = 0; i < arabicDigits.length; i++) {
      normalized = normalized.replaceAll(arabicDigits[i], '$i');
    }
    return int.tryParse(normalized);
  }

  void _goToNext() {
    if (_currentIndex < kLevel4FinalTestQuestions.length - 1) {
      _slideController.reset();
      setState(() {
        _currentIndex++;
        _inputController.clear();
      });
      _slideController.forward().whenComplete(() {
        if (mounted) _speakQuestion();
      });
    } else {
      _finishTest();
    }
  }

  void _speakQuestion() {
    if (!mounted) return;
    final q = _currentQuestion;
    
    String actionPrompt = _getQuestionTypeLabel(q.type);
    String speechText = actionPrompt;

    if (q.type != FinalTestQuestionType.findMissing) {
      // Check if it has actual Arabic words/letters
      bool hasText = RegExp(r'[أ-ي]').hasMatch(q.questionText);
      if (hasText) {
        speechText = '$actionPrompt. ${q.questionText}';
      }
    }

    AppTtsService.instance.speak(speechText);
  }

  Future<void> _finishTest() async {
    final threshold =
        (kLevel4FinalTestQuestions.length * kFinalTestPassThreshold).ceil();
    final isPassed = _correctCount >= threshold;

    setState(() {
      _isTestComplete = true;
      _passed = isPassed;
    });

    if (isPassed) {
      final service = await MathProgressService.getInstance();
      await service.completeLevelActivity(4, 'final_test');
    }

    if (!mounted) return;

    _showResultsDialog(isPassed, threshold);
  }

  void _showResultsDialog(bool passed, int threshold) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.refresh,
              size: 60,
              color: passed ? const Color(0xFFFFD700) : AppColors.error,
            ),
            const SizedBox(height: 10),
            Text(
              passed ? 'أحسنت! 🎉' : 'حاول مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: passed ? AppColors.success : AppColors.error,
                fontSize: 28,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'النتيجة: ${_correctCount.toArabicDigits()} من ${kLevel4FinalTestQuestions.length.toArabicDigits()}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              passed
                  ? 'لقد اجتزت الاختبار بنجاح!'
                  : 'عليك الإجابة عن ${threshold.toArabicDigits()} أسئلة على الأقل للنجاح.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (passed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.level4.last,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx); // close dialog – show correction screen
              },
              child: const Text('عرض الإجابات',
                  style: TextStyle(color: AppColors.surface, fontSize: 18)),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.level4.last,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // back to hub
              },
              child: const Text('إنهاء',
                  style: TextStyle(color: AppColors.surface, fontSize: 18)),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.level4,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0x00000000),
        appBar: AppBar(
          title: const Text(
            'اختبار الجمع والطرح',
            style: TextStyle(
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0x00000000),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.surface),
        ),
        body: SafeArea(
          child: _isTestComplete
              ? (_passed == true
                  ? _buildCorrectionScreen()
                  : const SizedBox.shrink())
              : _buildQuestionUI(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  QUESTION UI
  // ─────────────────────────────────────────────

  Widget _buildQuestionUI() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // ── Progress ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'السؤال ${(_currentIndex + 1).toArabicDigits()} / ${kLevel4FinalTestQuestions.length.toArabicDigits()}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Progress bar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) /
                            kLevel4FinalTestQuestions.length,
                        minHeight: 10,
                        backgroundColor: AppColors.surface.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Question Card ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildQuestionCard(),
                  const SizedBox(height: 30),
                  _buildAnswerArea(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final q = _currentQuestion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question number badge & Speaker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.level4.last.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getQuestionTypeLabel(q.type),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.level4.last,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _speakQuestion,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.level4.last.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.volume_up, color: AppColors.level4.last, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // If findMissing, show the equation display
          if (q.type == FinalTestQuestionType.findMissing &&
              q.equationDisplay != null) ...[
            Text(
              q.equationDisplay!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.level4.last,
                height: 1.5,
              ),
            ),
          ] else ...[
            Text(
              q.questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getQuestionTypeLabel(FinalTestQuestionType type) {
    switch (type) {
      case FinalTestQuestionType.multipleChoice:
        return 'اختر الإجابة الصحيحة';
      case FinalTestQuestionType.writeAnswer:
        return 'اكتب الناتج';
      case FinalTestQuestionType.findMissing:
        return 'أكمل المعادلة';
    }
  }

  Widget _buildAnswerArea() {
    final q = _currentQuestion;
    switch (q.type) {
      case FinalTestQuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(q);
      case FinalTestQuestionType.writeAnswer:
      case FinalTestQuestionType.findMissing:
        return _buildWriteAnswerField();
    }
  }

  Widget _buildMultipleChoiceOptions(FinalTestQuestion q) {
    final choices = q.choices!;
    return Column(
      children: choices.map((choice) {
        // Get letter label (أ، ب، ج)
        final idx = choices.indexOf(choice);
        final labels = ['أ', 'ب', 'ج', 'د'];
        final label = idx < labels.length ? labels[idx] : '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () => _submitMultipleChoice(choice),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.level4.last.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.level4.last.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.level4.last,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      choice.toString().toArabicDigits(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.level4.last.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWriteAnswerField() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _inputController,
            focusNode: _inputFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
            ],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.level4.last,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب الإجابة هنا',
              hintStyle: TextStyle(
                fontSize: 22,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _submitWrittenAnswer(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _submitWrittenAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level4.last,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
            ),
            child: const Text(
              'تأكيد الإجابة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  CORRECTION SCREEN (shown only when passed)
  // ─────────────────────────────────────────────

  Widget _buildCorrectionScreen() {
    return Column(
      children: [
        // Score header
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events,
                  color: Color(0xFFFFD700), size: 32),
              const SizedBox(width: 12),
              Text(
                'النتيجة: ${_correctCount.toArabicDigits()} / ${kLevel4FinalTestQuestions.length.toArabicDigits()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final r = _results[index];
              final q = r['question'] as FinalTestQuestion;
              final isCorrect = r['isCorrect'] as bool;
              final userAnswer = r['userAnswer'];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCorrect ? AppColors.success : AppColors.error,
                    width: 3,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color:
                              isCorrect ? AppColors.success : AppColors.error,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'السؤال ${(index + 1).toArabicDigits()}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Question text
                    Text(
                      q.type == FinalTestQuestionType.findMissing
                          ? q.equationDisplay ?? q.questionText
                          : q.questionText,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Correct answer
                    Text(
                      'الإجابة الصحيحة: ${q.correctAnswer.toString().toArabicDigits()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 4),
                      Text(
                        'إجابتك: ${userAnswer.toString().toArabicDigits()}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Back button
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.surface),
              label: const Text(
                'العودة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.surface,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.level4.last,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
