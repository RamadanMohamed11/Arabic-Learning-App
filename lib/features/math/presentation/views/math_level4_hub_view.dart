import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import '../../../../core/services/math_progress_service.dart';
import 'math_level4_intro_view.dart';
import 'math_level4_half2_view.dart';
import 'math_level4_final_test_view.dart';

class MathLevel4HubView extends StatefulWidget {
  const MathLevel4HubView({super.key});

  @override
  State<MathLevel4HubView> createState() => _MathLevel4HubViewState();
}

class _MathLevel4HubViewState extends State<MathLevel4HubView> {
  MathProgressService? _progressService;
  bool _isLoading = true;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _playIntroOnce();
  }

  Future<void> _loadProgress() async {
    _progressService = await MathProgressService.getInstance();
    if (_isLoading) {
      _isLoading = false;
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'مرحباً بك في المستوى الرابع: الجمع. هيا نبدأ المغامرة!',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  bool _isHalf2Unlocked() {
    if (_progressService == null) return false;
    return true; // Temporarily return true to unlock half 2 for testing
  }

  bool _isFinalTestUnlocked() {
    if (_progressService == null) return false;
    return true; // Temporarily open for testing
  }

  bool _isFinalTestCompleted() {
    if (_progressService == null) return false;
    return _progressService!.isLevelActivityCompleted(4, 'final_test');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.level4,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0x00000000),
        appBar: AppBar(
          title: const Text(
            'الجمع (المستوى الرابع)',
            style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0x00000000),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.surface),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      _buildHalfCard(
                        context,
                        title: 'أساسيات الجمع',
                        description: 'تعرف على الجمع بأرقام بسيطة',
                        icon: Icons.exposure_plus_1,
                        onTap: () async {
                          AppTtsService.instance.stop();
                          await Navigator.push(
                            context,
                            AnimatedRoute.fadeScale(const MathLevel4IntroView()),
                          );
                          _loadProgress();
                        },
                        isUnlocked: true,
                      ),
                      const SizedBox(height: 24),
                      _buildHalfCard(
                        context,
                        title: 'جمع الأعداد الكبيرة',
                        description: 'تعرف على الآحاد والعشرات وتحدي السرعة',
                        icon: Icons.calculate,
                        onTap: () async {
                          AppTtsService.instance.stop();
                          await Navigator.push(
                            context,
                            AnimatedRoute.fadeScale(const MathLevel4Half2View()),
                          );
                          _loadProgress();
                        },
                        isUnlocked: _isHalf2Unlocked(),
                      ),
                      const SizedBox(height: 24),
                      // ── الاختبار النهائي ──
                      _buildFinalTestCard(context),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHalfCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required bool isUnlocked,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.surface : AppColors.divider,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.level4.first.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? icon : Icons.lock,
                size: 40,
                color: isUnlocked ? AppColors.level4.last : AppColors.surface,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isUnlocked ? AppColors.textSecondary : AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.level4.last,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalTestCard(BuildContext context) {
    final isUnlocked = _isFinalTestUnlocked();
    final isCompleted = _isFinalTestCompleted();

    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              AppTtsService.instance.stop();
              await Navigator.push(
                context,
                AnimatedRoute.fadeScale(const MathLevel4FinalTestView()),
              );
              _loadProgress();
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? const LinearGradient(
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          color: isUnlocked ? null : AppColors.divider,
          borderRadius: BorderRadius.circular(24),
          border: isCompleted
              ? Border.all(color: AppColors.success, width: 3)
              : isUnlocked
                  ? Border.all(color: const Color(0xFFFFD700), width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                  : AppColors.cardShadow,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle
                    : isUnlocked
                        ? Icons.quiz
                        : Icons.lock,
                size: 40,
                color: isCompleted
                    ? AppColors.success
                    : isUnlocked
                        ? const Color(0xFFE65100)
                        : AppColors.surface,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الاختبار النهائي',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? const Color(0xFFE65100)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUnlocked
                        ? 'اختبار الجمع والطرح - ١٥ سؤال'
                        : 'أكمل جميع الأنشطة أولاً',
                    style: TextStyle(
                      fontSize: 16,
                      color: isUnlocked
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle, color: AppColors.success, size: 30)
            else if (isUnlocked)
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFE65100),
              ),
          ],
        ),
      ),
    );
  }
}
