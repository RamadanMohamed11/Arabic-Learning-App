import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_activity_1_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_activity_2_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_activity_3_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_activity_4_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_activity_5_view.dart';

/// شاشة اختيار القصة — تحت النشاط الأول في المستوى الثالث
class Level3StoriesView extends StatefulWidget {
  const Level3StoriesView({super.key});

  @override
  State<Level3StoriesView> createState() => _Level3StoriesViewState();
}

class _Level3StoriesViewState extends State<Level3StoriesView> {
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _playIntroOnce();
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'النشاط الأول: استمع واقرأ. اختر قصة للبدء.',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'القصص',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.slateBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.slateBlue.withValues(alpha: 0.15),
              AppColors.softTeal.withValues(alpha: 0.08),
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
                title: 'الاستخدام الخاطئ',
                subtitle: 'قصة عن تنظيم الوقت والنوم المبكر',
                emoji: '📱',
                color: AppColors.slateBlue,
                imagePath: 'assets/images/Arabic/Level3/Activity1/story4/1.jpeg',
                isLocked: false,
                onTap: () {
                  AppTtsService.instance.stop();
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3Activity4View()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── القصة الثانية ──
              _StoryCard(
                storyNumber: 2,
                title: 'أمنية والنظافة',
                subtitle: 'اقرأ القصة وأجب عن الأسئلة',
                emoji: '🧹',
                color: AppColors.mintGreen,
                imagePath: 'assets/images/Arabic/Level3/Activity1/story3/1.jpeg',
                isLocked: false,
                onTap: () {
                  AppTtsService.instance.stop();
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3Activity3View()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── القصة الثالثة ──
              _StoryCard(
                storyNumber: 3,
                title: 'الصدق',
                subtitle: 'قصة حوارية عن الأمانة وإرجاع الأمانات',
                emoji: '💎',
                color: AppColors.softTeal,
                imagePath: 'assets/images/Arabic/Level3/Activity1/story5/1.jpeg',
                isLocked: false,
                onTap: () {
                  AppTtsService.instance.stop();
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3Activity5View()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── القصة الرابعة ──
              _StoryCard(
                storyNumber: 4,
                title: 'كوب ماء يغيّر يومك',
                subtitle: 'اقرأ القصة وأجب عن الأسئلة',
                emoji: '💧',
                color: AppColors.softTeal,
                imagePath: 'assets/images/Arabic/Level3/Activity1/story2/1.jpeg',
                isLocked: false,
                onTap: () {
                  AppTtsService.instance.stop();
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3Activity2View()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── القصة الخامسة ──
              _StoryCard(
                storyNumber: 5,
                title: 'ابني والواجب',
                subtitle: 'استمع واقرأ قصة ابني والواجب',
                emoji: '📖',
                color: AppColors.slateBlue,
                imagePath: 'assets/images/Arabic/Level3/Activity1/story1.jpeg',
                isLocked: false,
                onTap: () {
                  AppTtsService.instance.stop();
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3Activity1View()),
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
