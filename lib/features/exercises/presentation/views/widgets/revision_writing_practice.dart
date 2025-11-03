import 'package:flutter/material.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/automated_letter_trace_screen.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

/// Widget for practicing writing all 4 letters in a revision group
class RevisionWritingPractice extends StatefulWidget {
  final List<String> letters;
  final List<int> letterIndices;
  final VoidCallback onComplete;

  const RevisionWritingPractice({
    super.key,
    required this.letters,
    required this.letterIndices,
    required this.onComplete,
  });

  @override
  State<RevisionWritingPractice> createState() =>
      _RevisionWritingPracticeState();
}

class _RevisionWritingPracticeState extends State<RevisionWritingPractice> {
  int _currentLetterIndex = 0;
  bool _currentLetterCompleted = false;

  void _onLetterComplete() {
    setState(() {
      _currentLetterCompleted = true;
    });
  }

  void _handleNextButton() {
    if (_currentLetterIndex < widget.letters.length - 1) {
      // Move to next letter
      setState(() {
        _currentLetterIndex++;
        _currentLetterCompleted = false;
      });
    } else {
      // All letters completed
      Navigator.pop(context);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'تدريب الكتابة (${_currentLetterIndex + 1}/${widget.letters.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.exercise1[0],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.exercise1[0].withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.letters.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: index < _currentLetterIndex
                              ? Colors.green
                              : index == _currentLetterIndex
                                  ? AppColors.exercise1[0]
                                  : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: index < _currentLetterIndex
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  widget.letters[index],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: index == _currentLetterIndex
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.letters[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: index <= _currentLetterIndex
                              ? AppColors.textPrimary
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Letter tracing screen
          Expanded(
            child: AutomatedLetterTraceScreen(
              key: ValueKey(_currentLetterIndex),
              svgAssetPath:
                  'assets/svg/${widget.letters[_currentLetterIndex]}.svg',
              letterIndex: widget.letterIndices[_currentLetterIndex],
              onComplete: _onLetterComplete,
            ),
          ),
          // Next/Finish button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentLetterCompleted ? _handleNextButton : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentLetterCompleted
                        ? AppColors.exercise1[0]
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: _currentLetterCompleted ? 5 : 0,
                  ),
                  child: Text(
                    _currentLetterIndex < widget.letters.length - 1
                        ? 'التالي'
                        : 'إنهاء',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
