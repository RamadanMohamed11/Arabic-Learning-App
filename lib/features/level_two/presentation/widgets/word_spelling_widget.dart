import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_two/data/models/word_spelling_model.dart';

/// Widget for word spelling activity - drag and drop letters to form words
class WordSpellingWidget extends StatefulWidget {
  final WordSpellingQuestion question;
  final VoidCallback onCorrect;
  final VoidCallback onNext;

  const WordSpellingWidget({
    super.key,
    required this.question,
    required this.onCorrect,
    required this.onNext,
  });

  @override
  State<WordSpellingWidget> createState() => _WordSpellingWidgetState();
}

class _WordSpellingWidgetState extends State<WordSpellingWidget> {
  late FlutterTts _flutterTts;
  late List<String> _shuffledLetters;
  late List<String?> _arrangedLetters;
  bool _isCorrect = false;
  bool _showFeedback = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _configureTts();
    _initializeLetters();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _speakLetters();
    });
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _initializeLetters() {
    _shuffledLetters = List.from(widget.question.letters)..shuffle();
    _arrangedLetters = List.filled(widget.question.letters.length, null);
  }

  Future<void> _speakLetters() async {
    setState(() => _isSpeaking = true);
    for (final letter in widget.question.letters) {
      await _flutterTts.speak(letter);
      await Future.delayed(const Duration(milliseconds: 600));
    }
    setState(() => _isSpeaking = false);
  }

  Future<void> _speakWord() async {
    await _flutterTts.speak(widget.question.word);
  }

  void _checkAnswer() {
    final userWord = _arrangedLetters.join('');
    if (userWord == widget.question.word) {
      setState(() {
        _isCorrect = true;
        _showFeedback = true;
      });
      _speakWord();
      widget.onCorrect();
    } else {
      setState(() {
        _isCorrect = false;
        _showFeedback = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showFeedback = false);
      });
    }
  }

  void _resetArrangedLetters() {
    setState(() {
      _arrangedLetters = List.filled(widget.question.letters.length, null);
      _showFeedback = false;
      _isCorrect = false;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            '🧩 نشاط: تهجئة الكلمة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildEmojiCard(),
          const SizedBox(height: 24),
          _buildSpeakerButton(),
          const SizedBox(height: 32),
          _buildDropZones(),
          const SizedBox(height: 32),
          _buildDraggableLetters(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmojiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(widget.question.emoji, style: const TextStyle(fontSize: 64)),
        ],
      ),
    );
  }

  Widget _buildSpeakerButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _speakLetters,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isSpeaking ? Icons.volume_up : Icons.headphones,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isSpeaking ? '🎧 استمع...' : 'اضغط للاستماع مرة أخرى',
          style: TextStyle(
            fontSize: 14,
            color: _isSpeaking ? AppColors.primary : AppColors.textSecondary,
            fontWeight: _isSpeaking ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDropZones() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(_arrangedLetters.length, (index) {
          return DragTarget<String>(
            onAcceptWithDetails: (details) {
              setState(() {
                final existingIndex = _arrangedLetters.indexOf(details.data);
                if (existingIndex != -1) {
                  _arrangedLetters[existingIndex] = null;
                }
                _arrangedLetters[index] = details.data;
              });
            },
            builder: (context, candidateData, rejectedData) {
              final letter = _arrangedLetters[index];
              return Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  color: letter != null ? Colors.white : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: candidateData.isNotEmpty
                        ? AppColors.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: letter != null
                    ? Draggable<String>(
                        data: letter,
                        feedback: _buildDraggingLetter(
                          letter,
                          AppColors.primary,
                        ),
                        childWhenDragging: Container(),
                        onDragCompleted: () {
                          setState(() => _arrangedLetters[index] = null);
                        },
                        child: Center(
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildDraggableLetters() {
    if (_isCorrect) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.celebration, color: AppColors.success, size: 40),
            SizedBox(height: 12),
            Text(
              'ممتاز! الإجابة صحيحة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    if (_showFeedback && !_isCorrect) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error_outline, color: AppColors.error, size: 40),
            SizedBox(height: 12),
            Text(
              '❌ حاول مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _shuffledLetters.map((letter) {
          final isUsed = _arrangedLetters.contains(letter);
          return Draggable<String>(
            data: letter,
            feedback: _buildDraggingLetter(letter, AppColors.success),
            childWhenDragging: Container(
              width: 60,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Container(
              width: 60,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUsed
                      ? [Colors.grey.shade300, Colors.grey.shade400]
                      : [AppColors.success, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isUsed
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isUsed ? Colors.grey.shade500 : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    final allSlotsFilled = _arrangedLetters.every((l) => l != null);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _resetArrangedLetters,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text(
            'إعادة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _isCorrect
              ? widget.onNext
              : (allSlotsFilled ? _checkAnswer : null),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isCorrect ? AppColors.success : AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(_isCorrect ? Icons.arrow_forward : Icons.check),
          label: Text(
            _isCorrect ? 'التالي' : 'تحقق',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggingLetter(String letter, Color backgroundColor) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
