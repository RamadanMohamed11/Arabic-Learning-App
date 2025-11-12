import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_two/data/models/word_match_model.dart';

class WordMatchWidget extends StatefulWidget {
  final List<WordMatchItem> items;
  final VoidCallback onComplete;
  final ValueChanged<int>? onProgress; // returns matched count

  const WordMatchWidget({
    super.key,
    required this.items,
    required this.onComplete,
    this.onProgress,
  });

  @override
  State<WordMatchWidget> createState() => _WordMatchWidgetState();
}

class _WordMatchWidgetState extends State<WordMatchWidget> {
  // We keep original indices (0..n-1) and shuffle orders for words/images
  late List<int> _wordOrder;
  late List<int> _imageOrder;
  final Set<int> _matched = {};
  int? _selectedWordOriginalIndex;
  int? _selectedImageOriginalIndex;

  @override
  void initState() {
    super.initState();
    _initOrders();
  }

  void _initOrders() {
    _wordOrder = List.generate(widget.items.length, (i) => i)..shuffle();
    _imageOrder = List.generate(widget.items.length, (i) => i)..shuffle();
    _matched.clear();
    _selectedWordOriginalIndex = null;
    _selectedImageOriginalIndex = null;
    // Defer notifying parent to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onProgress?.call(0);
    });
  }

  void _onSelectWord(int originalIndex) {
    if (_matched.contains(originalIndex)) return;
    setState(() => _selectedWordOriginalIndex = originalIndex);
  }

  void _onSelectImage(int originalIndex) {
    if (_matched.contains(originalIndex)) return;
    setState(() => _selectedImageOriginalIndex = originalIndex);
    _tryMatch();
  }

  void _tryMatch() {
    final w = _selectedWordOriginalIndex;
    final i = _selectedImageOriginalIndex;
    if (w == null || i == null) return;

    if (w == i) {
      // correct
      setState(() {
        _matched.add(w);
        _selectedWordOriginalIndex = null;
        _selectedImageOriginalIndex = null;
      });
      widget.onProgress?.call(_matched.length);
      if (_matched.length == widget.items.length) {
        Future.delayed(const Duration(milliseconds: 300), widget.onComplete);
      }
    } else {
      // wrong -> brief visual feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('غير صحيح، حاول مرة أخرى'),
          duration: Duration(milliseconds: 700),
        ),
      );
      setState(() {
        _selectedImageOriginalIndex = null;
      });
    }
  }

  void _reset() => setState(_initOrders);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 720;
                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildWordColumn()),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: _buildImageGrid()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildWordColumn(),
                          const SizedBox(height: 16),
                          _buildImageGrid(),
                        ],
                      );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordColumn() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const crossAxisCount = 3;
          const crossAxisSpacing = 8.0;
          const mainAxisSpacing = 8.0;
          const tileHeight = 60.0; // fixed height for stability
          final tileWidth =
              (constraints.maxWidth - crossAxisSpacing * (crossAxisCount - 1)) /
                  crossAxisCount;
          final aspectRatio = tileWidth / tileHeight;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: aspectRatio,
            ),
            itemCount: _wordOrder.length,
            itemBuilder: (context, gridIndex) {
              final originalIndex = _wordOrder[gridIndex];
              final item = widget.items[originalIndex];
              final matched = _matched.contains(originalIndex);
              final selected = _selectedWordOriginalIndex == originalIndex;

              return GestureDetector(
                onTap: () => _onSelectWord(originalIndex),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: matched
                            ? AppColors.success.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: matched
                              ? AppColors.success
                              : (selected
                                  ? AppColors.primary
                                  : Colors.grey.shade300),
                          width: 2, // fixed border width to avoid size change
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.word,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: matched
                                ? AppColors.success
                                : (selected
                                    ? AppColors.primary
                                    : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                    if (matched)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: _imageOrder.map((originalIndex) {
          final item = widget.items[originalIndex];
          final matched = _matched.contains(originalIndex);
          final selected = _selectedImageOriginalIndex == originalIndex;
          return GestureDetector(
            onTap: () => _onSelectImage(originalIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: matched
                      ? AppColors.success
                      : selected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (matched
                            ? AppColors.success
                            : selected
                                ? AppColors.primary
                                : Colors.black)
                        .withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(item.imagePath, fit: BoxFit.cover),
                  if (matched)
                    Container(
                      color: Colors.black.withOpacity(0.25),
                      child: const Center(
                        child: Icon(Icons.check_circle, color: Colors.white, size: 42),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
