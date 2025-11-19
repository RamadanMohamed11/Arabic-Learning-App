import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_two/data/models/sentence_order_model.dart';

class SentenceOrderWidget extends StatefulWidget {
  final SentenceOrderQuestion question;
  final VoidCallback onCorrect;
  final VoidCallback onNext;

  const SentenceOrderWidget({
    super.key,
    required this.question,
    required this.onCorrect,
    required this.onNext,
  });

  @override
  State<SentenceOrderWidget> createState() => _SentenceOrderWidgetState();
}

class _SentenceOrderWidgetState extends State<SentenceOrderWidget> {
  late List<int> _shuffled;
  late List<int?> _arranged;
  bool _isCorrect = false;
  bool _showFeedback = false;
  late FlutterTts _flutterTts;
  final ScrollController _arrangedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initState();
    _initTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _arrangedScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SentenceOrderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.sentence != widget.question.sentence) {
      _initState();
    }
  }

  void _initState() {
    final n = widget.question.words.length;
    _shuffled = List.generate(n, (i) => i)..shuffle();
    _arranged = List<int?>.filled(n, null);
    _isCorrect = false;
    _showFeedback = false;
    setState(() {});
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await TtsConfig.configure(
      _flutterTts,
      speechRate: 0.5,
    );
  }

  Future<void> _speakSentence() async {
    await _flutterTts.stop();
    await _flutterTts.speak(widget.question.sentence);
  }

  Future<void> _scrollArrangedBy(double delta) async {
    final current = _arrangedScrollController.offset;
    final max = _arrangedScrollController.position.maxScrollExtent;
    final target = (current + delta).clamp(0.0, max);
    await _arrangedScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _reset() {
    setState(() {
      final n = widget.question.words.length;
      _shuffled = List.generate(n, (i) => i)..shuffle();
      _arranged = List<int?>.filled(n, null);
      _isCorrect = false;
      _showFeedback = false;
    });
  }

  void _check() {
    final filled = _arranged.every((e) => e != null);
    if (!filled) {
      setState(() {
        _isCorrect = false;
        _showFeedback = true;
      });
      return;
    }
    final correct = List.generate(_arranged.length, (i) => i);
    final current = _arranged.cast<int>();
    final ok = _listsEqual(correct, current);
    setState(() {
      _isCorrect = ok;
      _showFeedback = true;
    });
    if (ok) {
      widget.onCorrect();
      _speakSentence();
    }
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.question.words;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200, width: 2),
          ),
          child: Scrollbar(
            controller: _arrangedScrollController,
            thumbVisibility: true,
            interactive: true,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: _arrangedScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_arranged.length, (index) {
                  final idx = _arranged[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: DragTarget<int>(
                      onWillAcceptWithDetails: (_) => true,
                      onAcceptWithDetails: (details) {
                        final data = details.data;
                        setState(() {
                          final fromSlot = _arranged.indexOf(data);
                          if (fromSlot != -1) {
                            _arranged[fromSlot] = null;
                          }
                          _arranged[index] = data;
                        });
                      },
                      builder: (context, candidate, rejected) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          height: 56,
                          constraints: const BoxConstraints(minWidth: 80),
                          decoration: BoxDecoration(
                            color: idx != null
                                ? Colors.white
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: candidate.isNotEmpty
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: idx != null
                              ? Draggable<int>(
                                  data: idx,
                                  feedback: _buildWordChip(
                                    words[idx],
                                    dragging: true,
                                  ),
                                  childWhenDragging: const SizedBox(
                                    width: 64,
                                    height: 36,
                                  ),
                                  onDragCompleted: () {
                                    setState(() => _arranged[index] = null);
                                  },
                                  child: Center(
                                    child: _buildWordChip(words[idx]),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'تمرير لليسار',
              onPressed: () => _scrollArrangedBy(-150),
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'تمرير لليمين',
              onPressed: () => _scrollArrangedBy(150),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200, width: 2),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _shuffled.map((originalIndex) {
              final used = _arranged.contains(originalIndex);
              if (used) {
                return const SizedBox.shrink();
              }
              return Draggable<int>(
                data: originalIndex,
                feedback: _buildWordChip(words[originalIndex], dragging: true),
                childWhenDragging: const SizedBox(width: 64, height: 36),
                child: _buildWordChip(words[originalIndex], enabled: true),
              );
            }).toList(),
          ),
        ),
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
                  horizontal: 20,
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
              onPressed: _check,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check),
              label: const Text('تحقق'),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCorrect
                          ? 'أحسنت! الجملة صحيحة.'
                          : 'حاول ترتيب كل الكلمات أولاً أو راجع الترتيب.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                if (_isCorrect) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWordChip(
    String word, {
    bool dragging = false,
    bool enabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dragging
            ? AppColors.primary.withOpacity(0.9)
            : (enabled ? Colors.white : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dragging ? AppColors.primary : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: dragging
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: dragging ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
