import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_two/data/models/missing_word_model.dart';

class MissingWordWidget extends StatefulWidget {
  final MissingWordQuestion question;
  final VoidCallback onCorrect;
  final VoidCallback onNext;

  const MissingWordWidget({
    super.key,
    required this.question,
    required this.onCorrect,
    required this.onNext,
  });

  @override
  State<MissingWordWidget> createState() => _MissingWordWidgetState();
}

class _MissingWordWidgetState extends State<MissingWordWidget> {
  String? _selected;
  bool _isCorrect = false;
  bool _showFeedback = false;
  List<String> _shuffledOptions = [];
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initOptions();
    _initTts();
  }

  Widget _buildSpeakerButton() {
    return Center(
      child: GestureDetector(
        onTap: _isSpeaking ? null : _speakAnswer,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _isSpeaking ? Icons.volume_up : Icons.play_arrow,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _initOptions() {
    _shuffledOptions = List<String>.from(widget.question.options);
    _shuffledOptions.shuffle();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await TtsConfig.configure(
      _flutterTts,
      speechRate: 0.5,
    );
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _speakAnswer();
      }
    });
  }

  Future<void> _speakAnswer() async {
    setState(() => _isSpeaking = true);
    await _flutterTts.stop();
    await _flutterTts.speak(widget.question.answer);
  }

  @override
  void didUpdateWidget(covariant MissingWordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _selected = null;
      _isCorrect = false;
      _showFeedback = false;
      _initOptions();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _speakAnswer();
        }
      });
    }
  }

  void _selectOption(String letter) {
    if (_isCorrect) return;
    setState(() {
      _selected = letter;
      _isCorrect = letter == widget.question.missingLetter;
      _showFeedback = true;
    });
    if (_isCorrect) {
      widget.onCorrect();
    }
  }

  void _reset() {
    setState(() {
      _selected = null;
      _isCorrect = false;
      _showFeedback = false;
      _initOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.question.imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSpeakerButton(),
                const SizedBox(height: 12),
                _buildPuzzleRow(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildOptionsGrid(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isCorrect ? widget.onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالي'),
              ),
            ],
          ),
          if (_showFeedback) ...[
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect ? AppColors.success : AppColors.error,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCorrect ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCorrect ? 'أحسنت! الإجابة صحيحة' : 'خطأ، حاول مرة أخرى',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPuzzleRow() {
    final parts = widget.question.puzzle.split('_');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPuzzleText(parts.first),
        const SizedBox(width: 8),
        _buildBlankBox(),
        const SizedBox(width: 8),
        _buildPuzzleText(parts.length > 1 ? parts.last : ''),
      ],
    );
  }

  Widget _buildPuzzleText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBlankBox() {
    final show = _selected ?? '_';
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect
              ? AppColors.success
              : (_selected != null ? AppColors.primary : Colors.grey.shade300),
          width: 2,
        ),
      ),
      child: Text(
        show,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _isCorrect
              ? AppColors.success
              : (_selected != null
                    ? AppColors.primary
                    : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid() {
    final options = _shuffledOptions;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final letter = options[index];
          final isSelected = _selected == letter;
          final isCorrect = letter == widget.question.missingLetter;
          return InkWell(
            onTap: () => _selectOption(letter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isCorrect
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.error.withOpacity(0.15))
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isCorrect ? AppColors.success : AppColors.error)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? (isCorrect ? AppColors.success : AppColors.error)
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
