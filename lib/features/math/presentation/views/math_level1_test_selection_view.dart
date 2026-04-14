import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'math_level1_match_images_view.dart';
import 'math_level1_match_images_part2_view.dart';
import 'math_level1_test_write_numbers_view.dart';
import 'math_level1_test_pronounce_view.dart';

class MathLevel1TestSelectionView extends StatefulWidget {
  final int part; // 1 for numbers 1-5, 2 for numbers 6-10

  const MathLevel1TestSelectionView({super.key, required this.part});

  @override
  State<MathLevel1TestSelectionView> createState() => _MathLevel1TestSelectionViewState();
}

class _MathLevel1TestSelectionViewState extends State<MathLevel1TestSelectionView> {
  // Activity unlock logic. For testing, all are unlocked.
  // In the future, unlocking logic (act 1 done unlocks act 2, etc.) can be placed here.
  bool get _testMode => false;

  bool _isActivity1Done = false;
  bool _isActivity2Done = false;
  bool _isActivity3Done = false;

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'مرحباً بك في اختبار هذا القسم.. اختر النشاط',
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
    final title = widget.part == 1 ? "اختبار الأرقام ١ إلى ٥" : "اختبار الأرقام ٦ إلى ١٠";
    
    // Unlock logic based on user request (make them choose one by one)
    // Act 1 is always open.
    // Act 2 requires Act 1.
    // Act 3 requires Act 2.
    // But since _testMode is true, they are all unlocked.
    final act1Unlocked = true;
    final act2Unlocked = _testMode ? true : _isActivity1Done;
    final act3Unlocked = _testMode ? true : _isActivity2Done;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.level1[0].withValues(alpha: 0.3),
              AppColors.level1[1].withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, title),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildActivityCard(
                      title: "النشاط الأول: توصيل الصور",
                      icon: Icons.extension,
                      isUnlocked: act1Unlocked,
                      isDone: _isActivity1Done,
                      onTap: () async {
                        AppTtsService.instance.stop();
                        await Navigator.push(
                          context,
                          AnimatedRoute.slideRight(
                            widget.part == 1
                                ? const MathLevel1MatchImagesView()
                                : const MathLevel1MatchImagesPart2View(),
                          ),
                        );
                        // Assume if result is 'next' or similar, activity is done.
                        // For testing, just mark it done.
                        setState(() {
                          _isActivity1Done = true;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildActivityCard(
                      title: "النشاط الثاني: عد واكتب",
                      icon: Icons.edit_document,
                      isUnlocked: act2Unlocked,
                      isDone: _isActivity2Done,
                      onTap: () async {
                        AppTtsService.instance.stop();
                        await Navigator.push(
                          context,
                          AnimatedRoute.slideRight(
                            MathLevel1TestWriteNumbersView(part: widget.part),
                          ),
                        );
                        setState(() { _isActivity2Done = true; });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildActivityCard(
                      title: "النشاط الثالث: انطق الرقم",
                      icon: Icons.mic,
                      isUnlocked: act3Unlocked,
                      isDone: _isActivity3Done,
                      onTap: () async {
                        AppTtsService.instance.stop();
                        await Navigator.push(
                          context,
                          AnimatedRoute.slideRight(
                            MathLevel1TestPronounceView(part: widget.part),
                          ),
                        );
                        setState(() { _isActivity3Done = true; });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.level1),
        boxShadow: [
          BoxShadow(
            color: AppColors.level1[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 48), // Spacer
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required IconData icon,
    required bool isUnlocked,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUnlocked
                ? (isDone
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.orange.shade400, Colors.orange.shade600])
                : [Colors.grey.shade400, Colors.grey.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? Colors.orange.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? icon : Icons.lock,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (isDone)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.check_circle, color: Colors.white, size: 36),
              ),
          ],
        ),
      ),
    );
  }
}
