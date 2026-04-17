import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import '../../../../core/services/math_progress_service.dart';
import '../../../../core/utils/app_colors.dart';
import 'math_level4_intro_view.dart';
import 'math_level4_half2_view.dart'; // We will create this as sub-hub or direct activity

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
    return _progressService!.isLevel4Half1Completed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'الجمع (Level 4)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: AppColors.level4,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 30),
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
                ],
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
          color: isUnlocked ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? icon : Icons.lock,
                size: 40,
                color: isUnlocked ? AppColors.level4.last : Colors.grey.shade600,
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
                      color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isUnlocked ? Colors.black54 : Colors.grey.shade500,
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
}

