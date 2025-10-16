import 'package:flutter/material.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/views/simple_svg_letter_view.dart';
import 'package:arabic_learning_app/features/word_training/presentation/views/widgets/word_training_view_body.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/writing_practice_view_body.dart';
import 'package:arabic_learning_app/features/memory_game/presentation/views/widgets/memory_game_view_body.dart';
import 'package:arabic_learning_app/features/word_search/presentation/views/widgets/word_search_view_body.dart';
import 'package:arabic_learning_app/features/pronunciation_practice/presentation/views/widgets/pronunciation_practice_view_body.dart';

class ExerciseItem {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Widget page;

  const ExerciseItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.page,
  });
}

class ExercisesViewBody extends StatelessWidget {
  const ExercisesViewBody({super.key});

  static final List<ExerciseItem> exercises = [
    ExerciseItem(
      title: 'تتبع الحروف',
      description: 'تعلم كتابة الحروف بالتتبع',
      icon: Icons.gesture,
      gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
      page: SimpleSvgLetterView(letter: 'ا'),
    ),
    ExerciseItem(
      title: 'تدريب الكلمات',
      description: 'تعلم نطق الكلمات بشكل صحيح',
      icon: Icons.record_voice_over,
      gradientColors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      page: WordTrainingViewBody(),
    ),
    ExerciseItem(
      title: 'تدريب الكتابة',
      description: 'تدرب على كتابة الحروف بحرية',
      icon: Icons.edit,
      gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      page: WritingPracticeViewBody(),
    ),
    ExerciseItem(
      title: 'لعبة الذاكرة',
      description: 'اختبر ذاكرتك مع الحروف',
      icon: Icons.psychology,
      gradientColors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      page: MemoryGameViewBody(),
    ),
    ExerciseItem(
      title: 'البحث عن الكلمات',
      description: 'ابحث عن الكلمات المخفية',
      icon: Icons.search,
      gradientColors: [Color(0xFFfa709a), Color(0xFFfee140)],
      page: WordSearchViewBody(),
    ),
    ExerciseItem(
      title: 'تمرين النطق',
      description: 'تدرب على نطق الكلمات',
      icon: Icons.mic,
      gradientColors: [Color(0xFF30cfd0), Color(0xFF330867)],
      page: PronunciationPracticeViewBody(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💪', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 12),
                      Text(
                        'التمارين',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('💪', style: TextStyle(fontSize: 32)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر التمرين الذي تريد',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Exercises Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.6,
                ),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(context, exercises[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ExerciseItem exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(body: exercise.page),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: exercise.gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: exercise.gradientColors[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(body: exercise.page),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(exercise.icon, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    exercise.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
