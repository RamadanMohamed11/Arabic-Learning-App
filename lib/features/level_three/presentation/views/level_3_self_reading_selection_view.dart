import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_self_reading_1_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_self_reading_2_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_self_reading_3_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_self_reading_4_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_self_reading_5_view.dart';

/// شاشة اختيار القصة — تحت النشاط الثاني في المستوى الثالث
class Level3SelfReadingSelectionView extends StatefulWidget {
  const Level3SelfReadingSelectionView({super.key});

  @override
  State<Level3SelfReadingSelectionView> createState() => _Level3SelfReadingSelectionViewState();
}

class _Level3SelfReadingSelectionViewState extends State<Level3SelfReadingSelectionView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'اقرأ بنفسك',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.softTeal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.softTeal.withValues(alpha: 0.15),
              AppColors.slateBlue.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── القصة الأولى ──
              _StoryCard(
                storyNumber: 1,
                title: 'قرار أحمد',
                subtitle: 'اقرأ القصة وأجب عن الأسئلة',
                emoji: '📖',
                color: AppColors.softTeal,
                imagePath: 'assets/images/Arabic/Level3/Activity2/1.jpeg',
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3SelfReading1View()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── القصة الثانية ──
              _StoryCard(
                storyNumber: 2,
                title: 'الكلمة الطيبة',
                subtitle: 'اقرأ القصة وأجب عن الأسئلة',
                emoji: '🗣️',
                color: AppColors.slateBlue,
                imagePath: 'assets/images/Arabic/Level3/Activity2/2.jpeg', 
                // TODO: Gate behind story 1 completion
                // isLocked: !story1Completed,
                isLocked: false, // مفتوحة للاختبار للمستخدم
                onTap: () {
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3SelfReading2View()),
                  );
                },
              ),
              // ── القصة الثالثة ──
              _StoryCard(
                storyNumber: 3,
                title: 'الغريب اللطيف',
                subtitle: 'اقرأ القصة وأجب عن الأسئلة',
                emoji: '🍬',
                color: AppColors.softTeal,
                imagePath: 'assets/images/Arabic/Level3/Activity2/3.jpeg',
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3SelfReading3View()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── القصة الرابعة ──
              _StoryCard(
                storyNumber: 4,
                title: 'نورٌ لا يُهدر',
                subtitle: 'اقرأ القصة وأجب عن الأسئلة',
                emoji: '💡',
                color: AppColors.slateBlue,
                imagePath: 'assets/images/Arabic/Level3/Activity2/4.jpeg',
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3SelfReading4View()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── القصة الخامسة ──
              _StoryCard(
                storyNumber: 5,
                title: 'بستان الحروف',
                subtitle: 'اقرأ القصة وأجب عن الأسئلة',
                emoji: '📚',
                color: AppColors.softTeal,
                imagePath: 'assets/images/Arabic/Level3/Activity2/5.jpeg',
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3SelfReading5View()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  بطاقة القصة
// ═══════════════════════════════════════════════════════════════════════

class _StoryCard extends StatelessWidget {
  final int storyNumber;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final String imagePath;
  final bool isLocked;
  final VoidCallback? onTap;

  const _StoryCard({
    required this.storyNumber,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.imagePath,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isLocked
                  ? Colors.grey.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة القصة
            if (imagePath.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Image.asset(
                        imagePath,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // طبقة رقم القصة
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLocked ? Colors.grey : color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'القصة $storyNumber $emoji',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    // طبقة القفل
                    if (isLocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                          ),
                          child: const Center(
                            child: Icon(Icons.lock,
                                color: Colors.white, size: 48),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              // Fallback if no image is provided
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade300 : color.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(
                  child: Text(
                    'القصة $storyNumber $emoji',
                    style: TextStyle(
                      color: isLocked ? Colors.grey : color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // معلومات القصة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isLocked
                                ? Colors.grey.shade500
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: color,
                        size: 28,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
