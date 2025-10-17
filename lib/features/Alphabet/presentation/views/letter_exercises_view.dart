import 'package:flutter/material.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/automated_letter_trace_screen.dart';

class LetterExercisesView extends StatefulWidget {
  final String letter;
  final int letterIndex;

  const LetterExercisesView({
    super.key,
    required this.letter,
    required this.letterIndex,
  });

  @override
  State<LetterExercisesView> createState() => _LetterExercisesViewState();
}

class _LetterExercisesViewState extends State<LetterExercisesView> {
  UserProgressService? _progressService;
  bool _isLoading = true;

  // Exercise completion status
  bool _tracingCompleted = false;

  // Exercise indices
  static const int tracingExerciseIndex = 0;
  // Add more exercise indices here in the future
  // static const int recognitionExerciseIndex = 1;
  // static const int writingExerciseIndex = 2;

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
      _isLoading = false;
    });
  }

  Future<void> _startTracingExercise() async {
    if (_progressService == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutomatedLetterTraceScreen(
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

  Future<void> _checkAllExercisesCompleted() async {
    if (_progressService == null) return;

    // Check if all exercises for this letter are completed
    // For now, we only have tracing exercise
    final allCompleted = _progressService!.isActivityCompleted(
      widget.letterIndex,
      tracingExerciseIndex,
    );
    // Add more checks here when you add more exercises
    // && _progressService!.isActivityCompleted(widget.letterIndex, recognitionExerciseIndex)
    // && _progressService!.isActivityCompleted(widget.letterIndex, writingExerciseIndex)

    if (allCompleted) {
      // Complete the letter and unlock next one
      await _progressService!.completeLetter(widget.letterIndex);

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
            Icon(Icons.celebration, color: Colors.amber, size: 32),
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
            Icon(Icons.check_circle, color: Colors.green, size: 80),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to alphabet view
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'تمارين حرف ${widget.letter}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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

                    // Exercise Cards
                    _buildExerciseCard(
                      title: 'تمرين تتبع الحرف',
                      description: 'تتبع شكل الحرف بإصبعك',
                      icon: Icons.draw,
                      color: Colors.deepPurple,
                      isCompleted: _tracingCompleted,
                      onTap: _startTracingExercise,
                    ),

                    const SizedBox(height: 16),

                    // Add more exercise cards here in the future
                    // _buildExerciseCard(
                    //   title: 'تمرين التعرف على الحرف',
                    //   description: 'اختر الحرف الصحيح',
                    //   icon: Icons.quiz,
                    //   color: Colors.blue,
                    //   isCompleted: false,
                    //   onTap: () {},
                    // ),
                    const SizedBox(height: 30),

                    // Progress Summary
                    _buildProgressSummary(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLetterHeader(letterData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A237E), Colors.indigo.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'أكمل جميع التمارين لفتح الحرف التالي',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isCompleted ? Colors.green : color,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.shade100
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : icon,
                color: isCompleted ? Colors.green : color,
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
                      color: isCompleted ? Colors.green : color,
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
              isCompleted ? Icons.verified : Icons.arrow_forward_ios,
              color: isCompleted ? Colors.green : color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final totalExercises = 1; // Update this when you add more exercises
    final completedExercises = _tracingCompleted ? 1 : 0;
    final progress = completedExercises / totalExercises;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade100],
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
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                '$completedExercises / $totalExercises',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
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
                progress == 1.0 ? Colors.green : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            progress == 1.0
                ? 'ممتاز! أكملت جميع التمارين! 🎉'
                : 'استمر! أنت في الطريق الصحيح 💪',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
