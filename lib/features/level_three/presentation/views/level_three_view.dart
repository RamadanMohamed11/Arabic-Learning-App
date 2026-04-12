import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_stories_view.dart';
import 'package:arabic_learning_app/features/level_three/presentation/views/level_3_self_reading_selection_view.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
class LevelThreeView extends StatefulWidget {
  const LevelThreeView({super.key});

  @override
  State<LevelThreeView> createState() => _LevelThreeViewState();
}

class _LevelThreeViewState extends State<LevelThreeView> {
  bool _hasPlayedIntro = false;
  
  // TODO: Add progression tracking for Level 3

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _playIntroOnce();
  }

  Future<void> _loadProgress() async {
    await UserProgressService.getInstance();
    if (!mounted) return;
    setState(() {
      // Refresh state
    });
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'المستوى الثالث: قصص ومحادثات متقدمة',
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
        title: const Text('المستوى الثالث', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.slateBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.slateBlue.withValues(alpha: 0.2),
              AppColors.softTeal.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildActivityCard(
                title: 'النشاط الأول: استمع واقرأ',
                subtitle: 'التطبيق يقرأ القصة أولاً، ثم تقرأها أنت جملة جملة وتجيب عن الأسئلة',
                icon: Icons.auto_stories,
                color: AppColors.slateBlue,
                isLocked: false,
                onTap: () {
                  AppTtsService.instance.stop();
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3StoriesView()),
                  ).then((_) => _loadProgress());
                },
              ),
              const SizedBox(height: 20),
              // النشاط الثاني: القراءة الذاتية
              _buildActivityCard(
                title: 'النشاط الثاني: اقرأ بنفسك',
                subtitle: 'اقرأ القصص والنصوص التوعوية بنفسك وأجب عن أسئلة الفهم',
                icon: Icons.menu_book,
                color: AppColors.softTeal,
                isLocked: false,
                onTap: () {
                  AppTtsService.instance.stop();
                  Navigator.push(
                    context,
                    AnimatedRoute.slideScale(const Level3SelfReadingSelectionView()),
                  ).then((_) => _loadProgress());
                },
              ),
              const SizedBox(height: 20),
              // النشاط الثالث: التعبير عن الصور
              _buildActivityCard(
                title: 'النشاط الثالث: عبّر عن الصورة',
                subtitle: 'شاهد الصور واكتب فقرة تعبر عنها بكلماتك (قريباً)',
                icon: Icons.image_search,
                color: AppColors.mintGreen,
                isLocked: true, // TODO: Unlock when activity 2 is done
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isLocked,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade300 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isLocked ? Colors.grey.withValues(alpha: 0.2) : color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey.shade400 : color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? Icons.lock : icon,
                color: isLocked ? Colors.white : color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isLocked ? Colors.grey.shade500 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLocked)
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
