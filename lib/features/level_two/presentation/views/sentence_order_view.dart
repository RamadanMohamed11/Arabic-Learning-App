import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_two/data/models/sentence_order_model.dart';
import 'package:arabic_learning_app/features/level_two/presentation/widgets/sentence_order_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SentenceOrderView extends StatefulWidget {
  const SentenceOrderView({super.key});

  @override
  State<SentenceOrderView> createState() => _SentenceOrderViewState();
}

class _SentenceOrderViewState extends State<SentenceOrderView> {
  int _current = 0;
  int _score = 0;
  bool _complete = false;
  late final FlutterTts _instructionTts;
  bool _instructionPlayed = false;

  @override
  void initState() {
    super.initState();
    _instructionTts = FlutterTts();
    _initInstruction();
  }

  Future<void> _initInstruction() async {
    await TtsConfig.configure(_instructionTts, speechRate: 0.45);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playInstruction());
  }

  Future<void> _playInstruction() async {
    if (_instructionPlayed) return;
    _instructionPlayed = true;
    await _instructionTts.stop();
    await _instructionTts.speak('رتب الكلمات لتكوين جملة صحيحة.');
  }

  void _onCorrect() {
    setState(() => _score++);
  }

  void _next() {
    if (_current < sentenceOrderQuestions.length - 1) {
      setState(() => _current++);
    } else {
      setState(() => _complete = true);
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _complete = false;
    });
  }

  @override
  void dispose() {
    _instructionTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_complete) return _buildResults();

    final q = sentenceOrderQuestions[_current];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧱 رتّب الكلمات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الجملة ${_current + 1} من ${sentenceOrderQuestions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (_current + 1) / sentenceOrderQuestions.length,
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
              Expanded(
                child: SentenceOrderWidget(
                  key: ValueKey(_current),
                  question: q,
                  onCorrect: _onCorrect,
                  onNext: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final total = sentenceOrderQuestions.length;
    final percentage = (_score / total * 100).round();
    final isPassed = percentage >= 70;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isPassed
                  ? [AppColors.success, AppColors.success.withOpacity(0.7)]
                  : [AppColors.warning, AppColors.warning.withOpacity(0.7)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    isPassed ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPassed ? 'رائع جداً!' : 'حاول مرة أخرى!',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed
                        ? 'أحسنت! رتّبت الجمل بشكل صحيح.'
                        : 'تابع التدريب، سترتب الجمل بشكل أفضل قريبًا.',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: isPassed
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isPassed
                                        ? AppColors.success
                                        : AppColors.warning)
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
                            '$_score / $total',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.home, size: 24),
                        label: const Text(
                          'الرئيسية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _restart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: isPassed
                              ? AppColors.success
                              : AppColors.warning,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.refresh, size: 24),
                        label: const Text(
                          'إعادة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
