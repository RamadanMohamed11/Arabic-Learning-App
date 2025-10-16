import 'package:arabic_learning_app/features/Alphabet/data/models/arabic_letter_model.dart';
import 'package:flutter/material.dart';

class LetterCard extends StatefulWidget {
  final ArabicLetterModel letter;
  final VoidCallback onTap; // للنطق
  final VoidCallback onCardTap; // للانتقال لصفحة الأشكال

  const LetterCard({
    super.key,
    required this.letter,
    required this.onTap,
    required this.onCardTap,
  });

  @override
  State<LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<LetterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onCardTap(); // انتقل لصفحة الأشكال
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // محتوى البطاقة
              Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // Letter
                  Center(
                    child: Text(
                      widget.letter.letter,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Emoji
                  Text(
                    widget.letter.emoji,
                    style: const TextStyle(fontSize: 70),
                  ),
                  const SizedBox(height: 4),

                  // Word
                  Text(
                    widget.letter.word,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // أيقونة السماعة في الزاوية
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    widget.onTap(); // نطق الحرف
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
