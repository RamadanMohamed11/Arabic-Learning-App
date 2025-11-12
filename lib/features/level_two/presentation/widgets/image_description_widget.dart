import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_two/data/models/image_description_model.dart';

class ImageDescriptionWidget extends StatefulWidget {
  final ImageDescriptionItem item;
  final VoidCallback onCorrect;
  final VoidCallback onNext;
  final int minKeywords; // threshold to consider correct

  const ImageDescriptionWidget({
    super.key,
    required this.item,
    required this.onCorrect,
    required this.onNext,
    this.minKeywords = 2,
  });

  @override
  State<ImageDescriptionWidget> createState() => _ImageDescriptionWidgetState();
}

class _ImageDescriptionWidgetState extends State<ImageDescriptionWidget> {
  late final TextEditingController _controller;
  bool _isCorrect = false;
  bool _showFeedback = false;
  bool _showSample = false;
  int _matched = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ImageDescriptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.imagePath != widget.item.imagePath) {
      _controller.clear();
      _isCorrect = false;
      _showFeedback = false;
      _showSample = false;
      _matched = 0;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _arabicDiacritics =
      r"[\u064B-\u0652\u0670\u0640]"; // tanween, fatha, damma, kasra, sukun, dagger alif, tatweel

  String _normalize(String s) {
    final withoutDiacritics = s.replaceAll(RegExp(_arabicDiacritics), '');
    return withoutDiacritics.replaceAll('\u200f', '').replaceAll('\u200e', '').trim();
  }

  void _check() {
    final text = _normalize(_controller.text);
    final keywords = widget.item.keywords.map(_normalize).toList();
    int hits = 0;
    for (final k in keywords) {
      if (k.isEmpty) continue;
      if (text.contains(k)) hits++;
    }
    final threshold = widget.minKeywords.clamp(1, keywords.length);
    setState(() {
      _matched = hits;
      _isCorrect = hits >= threshold;
      _showFeedback = true;
    });
    if (_isCorrect) {
      widget.onCorrect();
    }
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _isCorrect = false;
      _showFeedback = false;
      _showSample = false;
      _matched = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Instruction
          const Text(
            '✏️ اكتب جملة أو جملتين تصف الصورة (فاعل + فعل + مكمل + مكان)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Image card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              widget.item.imagePath,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          // Text input
          TextField(
            controller: _controller,
            textAlign: TextAlign.right,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'اكتب وصفك هنا...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Helper chips: show keywords (optional)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: widget.item.keywords.map((k) {
              return Chip(
                label: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide(color: Colors.blue.shade200, width: 1.5),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check),
                label: const Text('تحقق'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isCorrect ? widget.onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            ? 'أحسنت! وصفك جيد.'
                            : 'حاول إدراج كلمتين أو أكثر من الكلمات المفتاحية.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$_matched / ${widget.item.keywords.length} كلمات مفتاحية',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            )),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () => setState(() => _showSample = !_showSample),
                        icon: const Icon(Icons.lightbulb, color: AppColors.primary),
                        label: Text(
                          _showSample ? 'إخفاء المثال' : 'عرض مثال',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showSample) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: Text(
                        widget.item.sample,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
