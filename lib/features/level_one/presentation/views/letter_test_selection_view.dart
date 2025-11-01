import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/automated_letter_trace_screen.dart';
import 'package:arabic_learning_app/features/level_one/presentation/views/character_pronunciation_practice_view.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

/// Unified test selection view for all letter exercises
class LetterTestSelectionView extends StatefulWidget {
  final String letter;
  final int letterIndex;

  const LetterTestSelectionView({
    super.key,
    required this.letter,
    required this.letterIndex,
  });

  @override
  State<LetterTestSelectionView> createState() => _LetterTestSelectionViewState();
}

class _LetterTestSelectionViewState extends State<LetterTestSelectionView> {
  UserProgressService? _progressService;
  bool _isLoading = true;

  // Exercise completion status
  bool _tracingCompleted = false;
  bool _pronunciationCompleted = false;

  // Exercise indices
  static const int tracingExerciseIndex = 0;
  static const int pronunciationExerciseIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await UserProgressService.getInstance();
    setState(() {
      _tracingCompleted = _progressService!.isActivityCompleted(
        widget.letterIndex,
        tracingExerciseIndex,
      );
      _pronunciationCompleted = _progressService!.isActivityCompleted(
        widget.letterIndex,
        pronunciationExerciseIndex,
      );
      _isLoading = false;
    });
  }

  Future<void> _startTracingExercise() async {
    if (_progressService == null) return;

    await Navigator.push(
      context,
      AnimatedRoute.slideScale(
        AutomatedLetterTraceScreen(
          svgAssetPath: 'assets/svg/${widget.letter}.svg',
          letterIndex: widget.letterIndex,
          onComplete: () async {
            // Mark tracing activity as completed
            await _progressService!.completeActivity(
              widget.letterIndex,
              tracingExerciseIndex,
            );

            // Check if all exercises are completed
            await _checkAllExercisesCompleted();
          },
        ),
      ),
    );

    // Reload progress after returning
    await _loadProgress();
  }

  Future<void> _startPronunciationPractice() async {
    if (_progressService == null) return;

    await Navigator.push(
      context,
      AnimatedRoute.slideUp(
        CharacterPronunciationPracticeView(
          letter: widget.letter,
          letterIndex: widget.letterIndex,
          onComplete: () async {
            // Mark pronunciation activity as completed
            await _progressService!.completeActivity(
              widget.letterIndex,
              pronunciationExerciseIndex,
            );

            // Check if all exercises are completed
            await _checkAllExercisesCompleted();
          },
        ),
      ),
    );

    // Reload progress after returning
    await _loadProgress();
  }

  Future<void> _checkAllExercisesCompleted() async {
    if (_progressService == null) return;

    // Check if ALL exercises for this letter are completed
    final tracingDone = _progressService!.isActivityCompleted(
      widget.letterIndex,
      tracingExerciseIndex,
    );
    final pronunciationDone = _progressService!.isActivityCompleted(
      widget.letterIndex,
      pronunciationExerciseIndex,
    );

    final allCompleted = tracingDone && pronunciationDone;

    if (allCompleted) {
      // Complete the letter and unlock next one
      await _progressService!.completeLetter(widget.letterIndex);
      
      // Check if we should unlock the next lesson (revision test)
      // Unlock lesson only when all 4 letters in current lesson are completed
      final currentLessonIndex = widget.letterIndex ~/ 4;
      final firstLetterInLesson = currentLessonIndex * 4;
      final lastLetterInLesson = firstLetterInLesson + 3;
      
      // Check if all 4 letters in this lesson are completed
      bool allLettersInLessonCompleted = true;
      for (int i = firstLetterInLesson; i <= lastLetterInLesson && i < 28; i++) {
        final letterTracingDone = _progressService!.isActivityCompleted(i, tracingExerciseIndex);
        final letterPronunciationDone = _progressService!.isActivityCompleted(i, pronunciationExerciseIndex);
        if (!letterTracingDone || !letterPronunciationDone) {
          allLettersInLessonCompleted = false;
          break;
        }
      }
      
      // If all 4 letters completed, unlock the next lesson (for revision test)
      if (allLettersInLessonCompleted) {
        final nextLessonIndex = currentLessonIndex + 1;
        if (nextLessonIndex < 7) { // 28 letters / 4 = 7 lessons
          await _progressService!.unlockLevel1Lesson(nextLessonIndex);
        }
      }

      if (mounted) {
        // Show success dialog
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.warning, size: 32),
            SizedBox(width: 12),
            Text('أحسنت!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.letterIndex < 27
                  ? 'لقد أكملت جميع تمارين حرف ${widget.letter}!\nتم فتح الحرف التالي 🎉'
                  : 'مبروك! لقد أكملت جميع الحروف! 🎆',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Icon(Icons.check_circle, color: AppColors.success, size: 80),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to level view
            },
            child: const Text(
              'رائع!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final letterData = arabicLetters.firstWhere(
      (l) => l.letter == widget.letter,
      orElse: () => arabicLetters[0],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'اختر التمرين - حرف ${widget.letter}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.level1[0].withOpacity(0.2),
                    AppColors.level1[1].withOpacity(0.2),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Letter Header
                      _buildLetterHeader(letterData),

                      const SizedBox(height: 30),

                      // Instructions
                      _buildInstructions(),

                      const SizedBox(height: 30),

                      // Test Cards
                      _buildTestCard(
                        title: 'تدريب نطق الحرف',
                        description: 'تدرب على نطق اسم الحرف بشكل صحيح',
                        icon: Icons.mic,
                        color: AppColors.secondary,
                        isCompleted: _pronunciationCompleted,
                        onTap: _startPronunciationPractice,
                      ),

                      const SizedBox(height: 16),

                      _buildTestCard(
                        title: 'تمرين تتبع الحرف',
                        description: 'تتبع شكل الحرف بإصبعك',
                        icon: Icons.draw,
                        color: AppColors.accent,
                        isCompleted: _tracingCompleted,
                        onTap: _startTracingExercise,
                      ),

                      const SizedBox(height: 30),

                      // Progress Summary
                      _buildProgressSummary(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLetterHeader(letterData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.letter,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Text(letterData.emoji, style: const TextStyle(fontSize: 60)),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSlateBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'اختر التمرين الذي تريد التدرب عليه',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    bool isCompleted = false,
    required VoidCallback onTap,
  }) {
    final bool showCheck = isCompleted;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: showCheck ? AppColors.success : color,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: showCheck
                    ? AppColors.success.withOpacity(0.1)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                showCheck ? Icons.check_circle : icon,
                color: showCheck ? AppColors.success : color,
                size: 40,
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: showCheck ? AppColors.success : color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // Arrow or Check
            Icon(
              showCheck ? Icons.verified : Icons.arrow_forward_ios,
              color: showCheck ? AppColors.success : color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final totalExercises = 2; // Required exercises (tracing + pronunciation)
    int completedExercises = 0;
    if (_tracingCompleted) completedExercises++;
    if (_pronunciationCompleted) completedExercises++;
    final progress = completedExercises / totalExercises;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.warmGradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التقدم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '$completedExercises / $totalExercises',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? AppColors.success : AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progress == 1.0
                ? 'ممتاز! أكملت جميع التمارين! 🎉'
                : 'أكمل جميع التمارين لفتح الحرف التالي',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
