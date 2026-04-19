import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_gateway_test_data.dart';

class MathGatewayTestView extends StatefulWidget {
  const MathGatewayTestView({super.key});

  @override
  State<MathGatewayTestView> createState() => _MathGatewayTestViewState();
}

class _MathGatewayTestViewState extends State<MathGatewayTestView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isTestComplete = false;
  bool? _passed;

  int _correctCount = 0;
  final List<Map<String, dynamic>> _results = [];

  // For text input (write / pattern / count)
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  // For count-groups (multiple inputs)
  late List<TextEditingController> _groupControllers;

  // For ordering (drag arrangement)
  List<int> _currentOrderItems = [];

  // For audio choice (listen-then-select)
  int? _selectedAudioChoiceIndex;

  // Animation
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Gradient for this test
  static const List<Color> _testGradient = [
    AppColors.slateBlue,
    AppColors.softTeal,
  ];

  @override
  void initState() {
    super.initState();
    _groupControllers = [];

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

    _prepareCurrentQuestion();

    // Speak intro, then auto-speak the first question after it finishes
    AppTtsService.instance.setCompletionHandler(() {
      if (mounted) {
        // Remove the handler so it doesn't fire on every subsequent speech
        AppTtsService.instance.setCompletionHandler(() {});
        _speakQuestion();
      }
    });
    AppTtsService.instance.speakScreenIntro(
      'اختبار شامل! أجب عن الأسئلة التالية',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _slideController.dispose();
    for (final c in _groupControllers) {
      c.dispose();
    }
    AppTtsService.instance.stop();
    super.dispose();
  }

  GatewayQuestion get _q => kGatewayTestQuestions[_currentIndex];

  void _prepareCurrentQuestion() {
    final q = _q;
    _inputController.clear();

    // Dispose old group controllers
    for (final c in _groupControllers) {
      c.dispose();
    }
    _groupControllers = [];

    if (q.type == GatewayQuestionType.countGroups) {
      _groupControllers = List.generate(
        q.emojiGroups!.length,
        (_) => TextEditingController(),
      );
    }

    if (q.type == GatewayQuestionType.ordering) {
      _currentOrderItems = List.from(q.orderNumbers!);
    }

    // Reset audio choice selection
    _selectedAudioChoiceIndex = null;
  }

  // ──────────────── SPEAK QUESTION ────────────────

  /// Convert number to Arabic word for TTS
  String _numberToArabicWord(int n) {
    const words = {
      0: 'صفر', 1: 'واحد', 2: 'اثنان', 3: 'ثلاثة', 4: 'أربعة',
      5: 'خمسة', 6: 'ستة', 7: 'سبعة', 8: 'ثمانية', 9: 'تسعة',
      10: 'عشرة', 11: 'أحد عشر', 12: 'اثنا عشر', 13: 'ثلاثة عشر',
      14: 'أربعة عشر', 15: 'خمسة عشر', 16: 'ستة عشر', 17: 'سبعة عشر',
      18: 'ثمانية عشر', 19: 'تسعة عشر', 20: 'عشرون',
      22: 'اثنان وعشرون', 27: 'سبعة وعشرون',
      30: 'ثلاثون', 31: 'واحد وثلاثون', 33: 'ثلاثة وثلاثون', 35: 'خمسة وثلاثون',
      40: 'أربعون', 45: 'خمسة وأربعون', 50: 'خمسون', 53: 'ثلاثة وخمسون',
      60: 'ستون', 63: 'ثلاثة وستون', 70: 'سبعون', 72: 'اثنان وسبعون',
      80: 'ثمانون',
    };
    return words[n] ?? n.toString();
  }

  /// Speak the current question text via TTS for accessibility
  void _speakQuestion() {
    if (!mounted) return;
    final q = _q;
    String speechText;
    switch (q.type) {
      case GatewayQuestionType.countAndWrite:
        speechText = 'عُد الأشكال واكتب الرقم';
        break;
      case GatewayQuestionType.audioChoice:
        // Don't speak audioText (it may reveal the answer)
        // Use a neutral prompt based on what the question is about
        if (q.emojiDisplay != null) {
          speechText = 'عُد الأشكال واختر الرقم الصحيح. اضغط على كل خيار للاستماع';
        } else {
          speechText = '${q.questionText}. اضغط على كل خيار للاستماع';
        }
        break;
      case GatewayQuestionType.countGroups:
        speechText = 'عُد كل مجموعة واكتب الرقم';
        break;
      case GatewayQuestionType.ordering:
        speechText = q.questionText;
        break;
      case GatewayQuestionType.multipleChoice:
        speechText = q.questionText;
        break;
      case GatewayQuestionType.numberPattern:
        speechText = 'أكمل النمط. اكتب الرقم الناقص';
        break;
    }
    AppTtsService.instance.speak(speechText);
  }

  // ──────────────── SUBMISSION HANDLERS ────────────────

  void _submitMultipleChoice(int index) {
    if (_isTestComplete) return;
    final q = _q;
    final isCorrect = index == q.correctChoiceIndex;
    if (isCorrect) _correctCount++;

    _results.add({
      'question': q,
      'userAnswer': q.choices![index],
      'correctAnswer': q.choices![q.correctChoiceIndex!],
      'isCorrect': isCorrect,
    });
    _goToNext();
  }

  void _submitAudioChoice(int selected) {
    if (_isTestComplete) return;
    final q = _q;
    final isCorrect = selected == q.audioCorrectAnswer;
    if (isCorrect) _correctCount++;

    _results.add({
      'question': q,
      'userAnswer': selected.toString().toArabicDigits(),
      'correctAnswer': q.audioCorrectAnswer.toString().toArabicDigits(),
      'isCorrect': isCorrect,
    });
    _goToNext();
  }

  void _submitCountAndWrite() {
    if (_isTestComplete) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final parsed = _parseArabicNumber(text);
    if (parsed == null) return;

    final q = _q;
    final isCorrect = parsed == q.correctCount;
    if (isCorrect) _correctCount++;

    _results.add({
      'question': q,
      'userAnswer': parsed.toString().toArabicDigits(),
      'correctAnswer': q.correctCount.toString().toArabicDigits(),
      'isCorrect': isCorrect,
    });
    _goToNext();
  }

  void _submitCountGroups() {
    if (_isTestComplete) return;
    final q = _q;

    // Verify all fields are filled
    for (final c in _groupControllers) {
      if (c.text.trim().isEmpty) return;
    }

    List<int> userAnswers = [];
    for (final c in _groupControllers) {
      final parsed = _parseArabicNumber(c.text.trim());
      if (parsed == null) return;
      userAnswers.add(parsed);
    }

    bool isCorrect = true;
    for (int i = 0; i < q.groupCounts!.length; i++) {
      if (userAnswers[i] != q.groupCounts![i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) _correctCount++;

    _results.add({
      'question': q,
      'userAnswer': userAnswers.map((n) => n.toString().toArabicDigits()).join(' ، '),
      'correctAnswer': q.groupCounts!.map((n) => n.toString().toArabicDigits()).join(' ، '),
      'isCorrect': isCorrect,
    });
    _goToNext();
  }

  void _submitOrdering() {
    if (_isTestComplete) return;
    final q = _q;

    bool isCorrect = true;
    for (int i = 0; i < q.correctOrder!.length; i++) {
      if (_currentOrderItems[i] != q.correctOrder![i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) _correctCount++;

    _results.add({
      'question': q,
      'userAnswer': _currentOrderItems.map((n) => n.toString().toArabicDigits()).join(' ، '),
      'correctAnswer': q.correctOrder!.map((n) => n.toString().toArabicDigits()).join(' ، '),
      'isCorrect': isCorrect,
    });
    _goToNext();
  }

  void _submitNumberPattern() {
    if (_isTestComplete) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final parsed = _parseArabicNumber(text);
    if (parsed == null) return;

    final q = _q;
    final isCorrect = parsed == q.patternAnswer;
    if (isCorrect) _correctCount++;

    _results.add({
      'question': q,
      'userAnswer': parsed.toString().toArabicDigits(),
      'correctAnswer': q.patternAnswer.toString().toArabicDigits(),
      'isCorrect': isCorrect,
    });
    _goToNext();
  }

  // ──────────────── NAVIGATION ────────────────

  void _goToNext() {
    if (_currentIndex < kGatewayTestQuestions.length - 1) {
      _slideController.reset();
      setState(() {
        _currentIndex++;
        _prepareCurrentQuestion();
      });
      _slideController.forward();
      // Auto-speak question after slide animation starts
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _speakQuestion();
      });
    } else {
      _finishTest();
    }
  }

  Future<void> _finishTest() async {
    final threshold =
        (kGatewayTestQuestions.length * kGatewayTestPassThreshold).ceil();
    final isPassed = _correctCount >= threshold;

    setState(() {
      _isTestComplete = true;
      _passed = isPassed;
    });

    if (isPassed) {
      final service = await MathProgressService.getInstance();
      await service.completeLevelActivity(0, 'gateway_test');
    }

    if (!mounted) return;
    _showResultsDialog(isPassed, threshold);
  }

  int? _parseArabicNumber(String text) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String normalized = text;
    for (int i = 0; i < arabicDigits.length; i++) {
      normalized = normalized.replaceAll(arabicDigits[i], '$i');
    }
    return int.tryParse(normalized);
  }

  // ──────────────── RESULTS DIALOG ────────────────

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
              'النتيجة: ${_correctCount.toArabicDigits()} من ${kGatewayTestQuestions.length.toArabicDigits()}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              passed
                  ? 'لقد اجتزت الاختبار بنجاح!\nيمكنك الآن الانتقال للمستويات المتقدمة!'
                  : 'عليك الإجابة عن ${threshold.toArabicDigits()} أسئلة على الأقل للنجاح.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, color: AppColors.textSecondary),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (passed)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _testGradient.last,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('عرض الإجابات',
                  style: TextStyle(color: AppColors.surface, fontSize: 18)),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _testGradient.last,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('إنهاء',
                  style: TextStyle(color: AppColors.surface, fontSize: 18)),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _testGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0x00000000),
        appBar: AppBar(
          title: const Text(
            'الاختبار الشامل',
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

  // ═══════════════════════════════════════════════════
  //  QUESTION UI
  // ═══════════════════════════════════════════════════

  Widget _buildQuestionUI() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Progress bar + counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(_currentIndex + 1).toArabicDigits()} / ${kGatewayTestQuestions.length.toArabicDigits()}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) /
                          kGatewayTestQuestions.length,
                      minHeight: 10,
                      backgroundColor:
                          AppColors.surface.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildQuestionContent(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final q = _q;
    switch (q.type) {
      case GatewayQuestionType.countAndWrite:
        return _buildCountAndWrite(q);
      case GatewayQuestionType.audioChoice:
        return _buildAudioChoice(q);
      case GatewayQuestionType.countGroups:
        return _buildCountGroups(q);
      case GatewayQuestionType.ordering:
        return _buildOrdering(q);
      case GatewayQuestionType.multipleChoice:
        return _buildMultipleChoice(q);
      case GatewayQuestionType.numberPattern:
        return _buildNumberPattern(q);
    }
  }

  // ─────────── 1. COUNT AND WRITE ───────────

  Widget _buildCountAndWrite(GatewayQuestion q) {
    return Column(
      children: [
        _questionCard(
          child: Column(
            children: [
              _typeBadge('عُد واكتب'),
              const SizedBox(height: 20),
              Text(
                q.emojiDisplay!,
                style: const TextStyle(fontSize: 50, letterSpacing: 8),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildNumberInput(onSubmit: _submitCountAndWrite),
      ],
    );
  }

  // ─────────── 2. AUDIO CHOICE ───────────

  Widget _buildAudioChoice(GatewayQuestion q) {
    final labels = ['أ', 'ب', 'ج'];
    return Column(
      children: [
        _questionCard(
          child: Column(
            children: [
              _typeBadge('استمع واختر'),
              const SizedBox(height: 16),
              if (q.emojiDisplay != null) ...[
                Text(
                  q.emojiDisplay!,
                  style: const TextStyle(fontSize: 40, letterSpacing: 6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                q.questionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Sound choice buttons — tap to listen & highlight
        ...q.audioChoices!.asMap().entries.map((entry) {
          final idx = entry.key;
          final choice = entry.value;
          final word = _numberToArabicWord(choice);
          final isSelected = _selectedAudioChoiceIndex == idx;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _audioChoiceButton(
              label: idx < labels.length ? labels[idx] : '',
              speakText: word,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedAudioChoiceIndex = idx);
                AppTtsService.instance.speak(word);
              },
            ),
          );
        }),
        // Confirm button — only enabled when a choice is selected
        const SizedBox(height: 10),
        _submitButton(
          onPressed: _selectedAudioChoiceIndex != null
              ? () {
                  final choice =
                      q.audioChoices![_selectedAudioChoiceIndex!];
                  _submitAudioChoice(choice);
                }
              : () {},
          enabled: _selectedAudioChoiceIndex != null,
        ),
      ],
    );
  }

  /// A choice button that speaks the number via TTS and highlights it.
  Widget _audioChoiceButton({
    required String label,
    required String speakText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? _testGradient.last.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _testGradient.last
                : _testGradient.last.withValues(alpha: 0.3),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _testGradient.last.withValues(alpha: 0.2)
                  : AppColors.cardShadow,
              blurRadius: isSelected ? 10 : 6,
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
                color: isSelected
                    ? _testGradient.last
                    : _testGradient.last.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : _testGradient.last,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Icon(
              Icons.volume_up,
              size: 36,
              color: _testGradient.last,
            ),
            const SizedBox(width: 12),
            Text(
              'اضغط للاستماع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _testGradient.last,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: _testGradient.last,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  // ─────────── 3. COUNT GROUPS ───────────

  Widget _buildCountGroups(GatewayQuestion q) {
    return Column(
      children: [
        _questionCard(
          child: Column(
            children: [
              _typeBadge('عُد كل مجموعة'),
              const SizedBox(height: 20),
              for (int i = 0; i < q.emojiGroups!.length; i++) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.emojiGroups![i],
                        style:
                            const TextStyle(fontSize: 32, letterSpacing: 4),
                      ),
                    ),
                    const Text('→  ',
                        style: TextStyle(fontSize: 28, color: AppColors.textSecondary)),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _groupControllers[i],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9٠-٩]')),
                        ],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _testGradient.last,
                        ),
                        decoration: InputDecoration(
                          hintText: '__',
                          hintStyle:
                              TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.4)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: _testGradient.last, width: 2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: _testGradient.last, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (i < q.emojiGroups!.length - 1)
                  const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _submitButton(onPressed: _submitCountGroups),
      ],
    );
  }

  // ─────────── 4. ORDERING ───────────

  Widget _buildOrdering(GatewayQuestion q) {
    return Column(
      children: [
        _questionCard(
          child: Column(
            children: [
              _typeBadge(q.orderLabel ?? 'رتب الأرقام'),
              const SizedBox(height: 16),
              Text(
                q.questionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Reorderable list
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            proxyDecorator: (child, index, animation) {
              return Material(
                color: Colors.transparent,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.08)
                      .animate(animation),
                  child: child,
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _currentOrderItems.removeAt(oldIndex);
                _currentOrderItems.insert(newIndex, item);
              });
            },
            children: [
              for (int i = 0; i < _currentOrderItems.length; i++)
                Container(
                  key: ValueKey('order_${_currentOrderItems[i]}'),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: _testGradient.last.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _testGradient.last.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.drag_handle,
                          color: _testGradient.last.withValues(alpha: 0.5)),
                      Text(
                        _currentOrderItems[i].toString().toArabicDigits(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _testGradient.last,
                        ),
                      ),
                      Text(
                        (i + 1).toArabicDigits(),
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _submitButton(onPressed: _submitOrdering),
      ],
    );
  }

  // ─────────── 5. MULTIPLE CHOICE ───────────

  Widget _buildMultipleChoice(GatewayQuestion q) {
    final labels = ['أ', 'ب', 'ج', 'د'];
    return Column(
      children: [
        _questionCard(
          child: Column(
            children: [
              _typeBadge('اختر الإجابة الصحيحة'),
              const SizedBox(height: 20),
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
          ),
        ),
        const SizedBox(height: 24),
        ...q.choices!.asMap().entries.map((entry) {
          final idx = entry.key;
          final text = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _choiceButton(
              label: idx < labels.length ? labels[idx] : '',
              text: text,
              onTap: () => _submitMultipleChoice(idx),
            ),
          );
        }),
      ],
    );
  }

  // ─────────── 6. NUMBER PATTERN ───────────

  Widget _buildNumberPattern(GatewayQuestion q) {
    return Column(
      children: [
        _questionCard(
          child: Column(
            children: [
              _typeBadge('أكمل النمط'),
              const SizedBox(height: 20),
              Text(
                q.patternDisplay!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _testGradient.last,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildNumberInput(onSubmit: _submitNumberPattern),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════

  Widget _questionCard({required Widget child}) {
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
      child: child,
    );
  }

  Widget _typeBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: _testGradient.last.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _testGradient.last,
        ),
      ),
    );
  }

  Widget _choiceButton({
    required String label,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _testGradient.last.withValues(alpha: 0.3),
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
                color: _testGradient.last.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _testGradient.last,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: _testGradient.last.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({required VoidCallback onSubmit}) {
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
              color: _testGradient.last,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب الإجابة هنا',
              hintStyle: TextStyle(
                fontSize: 22,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        const SizedBox(height: 24),
        _submitButton(onPressed: onSubmit),
      ],
    );
  }

  Widget _submitButton({required VoidCallback onPressed, bool enabled = true}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? _testGradient.last
              : _testGradient.last.withValues(alpha: 0.3),
          disabledBackgroundColor: _testGradient.last.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: enabled ? 5 : 0,
        ),
        child: Text(
          'تأكيد الإجابة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: enabled
                ? AppColors.surface
                : AppColors.surface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  CORRECTION SCREEN
  // ═══════════════════════════════════════════════════

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
                'النتيجة: ${_correctCount.toArabicDigits()} / ${kGatewayTestQuestions.length.toArabicDigits()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final r = _results[index];
              final q = r['question'] as GatewayQuestion;
              final isCorrect = r['isCorrect'] as bool;

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
                    Text(
                      q.questionText,
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الإجابة الصحيحة: ${r['correctAnswer']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 4),
                      Text(
                        'إجابتك: ${r['userAnswer']}',
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
                backgroundColor: _testGradient.last,
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
