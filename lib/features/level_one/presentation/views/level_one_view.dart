import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/features/Alphabet/data/models/arabic_letter_model.dart';
import 'package:arabic_learning_app/features/Alphabet/presentation/views/letter_shapes_view.dart';

class LevelOneView extends StatefulWidget {
  const LevelOneView({super.key});

  @override
  State<LevelOneView> createState() => _LevelOneViewState();
}

class _LevelOneViewState extends State<LevelOneView> {
  UserProgressService? _progressService;
  List<int> _unlockedLetters = [];
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await UserProgressService.getInstance();
    setState(() {
      _unlockedLetters = _progressService!.getUnlockedLetters();
      _progress = _progressService!.getLevel1Progress();
    });
  }

  String _getProgressEmoji() {
    if (_progress < 25) return '🌱';
    if (_progress < 50) return '🌿';
    if (_progress < 75) return '🌳';
    return '🌟';
  }

  Color _getProgressColor() {
    if (_progress < 25) return Colors.red;
    if (_progress < 50) return Colors.orange;
    if (_progress < 75) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final completedLetters = _unlockedLetters.length - 1; // -1 لأن أول حرف مفتوح افتراضياً
    final totalLetters = arabicLetters.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF43e97b).withOpacity(0.3),
              Color(0xFF38f9d7).withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF43e97b).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'المستوى الأول',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الحروف الأبجدية',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _getProgressEmoji(),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'التقدم',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$completedLetters / $totalLetters حرف',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _progress / 100,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(),
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_progress.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Letters Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: arabicLetters.length + (arabicLetters.length ~/ 4),
                  itemBuilder: (context, index) {
                    // كل 4 حروف نضيف نشاط مراجعة
                    if ((index + 1) % 5 == 0) {
                      final reviewIndex = index ~/ 5;
                      return _buildReviewCard(reviewIndex);
                    }

                    final letterIndex = index - (index ~/ 5);
                    if (letterIndex >= arabicLetters.length) {
                      return const SizedBox.shrink();
                    }

                    final letter = arabicLetters[letterIndex];
                    final isUnlocked = _unlockedLetters.contains(letterIndex);

                    return _buildLetterCard(letter, letterIndex, isUnlocked);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterCard(ArabicLetterModel letter, int index, bool isUnlocked) {
    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              // Navigate to letter shapes view
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LetterShapesView(letter: letter.letter),
                ),
              );
              // إعادة تحميل التقدم عند العودة
              _loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [Color(0xFF667eea), Color(0xFF764ba2)]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? Color(0xFF667eea).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Text(
                letter.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                letter.letter,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.lock,
                size: 40,
                color: Colors.white70,
              ),
              const SizedBox(height: 8),
              Text(
                letter.letter,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(int reviewIndex) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFf093fb).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.quiz,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          const Text(
            'مراجعة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${reviewIndex * 4 + 1}-${(reviewIndex + 1) * 4}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
