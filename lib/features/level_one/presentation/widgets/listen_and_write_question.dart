import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/automated_letter_trace_screen.dart';

/// Listen to a letter, then trace it using the same board used elsewhere.
class ListenAndWriteQuestion extends StatefulWidget {
  final String letter;
  final VoidCallback onComplete;

  const ListenAndWriteQuestion({
    super.key,
    required this.letter,
    required this.onComplete,
  });

  @override
  State<ListenAndWriteQuestion> createState() => _ListenAndWriteQuestionState();
}

class _ListenAndWriteQuestionState extends State<ListenAndWriteQuestion> {
  late FlutterTts _flutterTts;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _configureTts();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _speakLetter();
    });
  }

  Future<void> _configureTts() async {
    await TtsConfig.configure(_flutterTts, speechRate: 0.4, pitch: 1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isPlaying = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });

    _flutterTts.setErrorHandler((message) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _speakLetter() async {
    if (_isPlaying) await _flutterTts.stop();
    await _flutterTts.speak(widget.letter);
  }

  void _openTracingBoard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AutomatedLetterTraceScreen(
          svgAssetPath: 'assets/svg/${widget.letter}.svg',
          letterIndex: _letterIndex(widget.letter),
          onComplete: () {
            Navigator.of(context).pop();
            widget.onComplete();
          },
        ),
      ),
    );
  }

  int _letterIndex(String letter) {
    const letters = [
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
    return letters.indexOf(letter);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '🗣 ثالثًا: الاستماع والكتابة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'استمع إلى الحرف، ثم اكتبه',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: _speakLetter,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
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
        Text(
          _isPlaying ? '🎧 استمع...' : 'اضغط على السماعة للاستماع مرة أخرى',
          style: TextStyle(
            fontSize: 16,
            color: _isPlaying ? AppColors.primary : AppColors.textSecondary,
            fontWeight: _isPlaying ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: _openTracingBoard,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
          ),
          icon: const Icon(Icons.edit, size: 28),
          label: const Text(
            'اكتب الحرف',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
