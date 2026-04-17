import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/app_router.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/math_data.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'math_level_numbers_view.dart';
import 'math_level4_hub_view.dart';

class MathView extends StatefulWidget {
  const MathView({super.key});

  @override
  State<MathView> createState() => _MathViewState();
}

class _MathViewState extends State<MathView> {
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
      'أهلاً بك في الرياضيات! اختر المستوى الذي تريد تعلمه',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  bool get _testMode => true; // Toggle to false when testing is over

  bool _isLevelUnlocked(int level) {
    if (_testMode) return true;
    if (_progressService == null) return false;
    if (level == 1) return _progressService!.isLevel1Unlocked();
    if (level == 2) return _progressService!.isLevel2Unlocked();
    if (level == 3) return _progressService!.isLevel3Unlocked();
    
    if (level == 4) {
      return _progressService!.isLevel3Completed();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFE0F7FA), // Light cyan
              Color(0xFFB2EBF2),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var item in mathLevels) ...[
                                    _buildLevelCard(
                                      context,
                                      title: item.title,
                                      description: item.description,
                                      colors: item.level == 1
                                          ? AppColors.level1
                                          : item.level == 2
                                          ? AppColors.level2
                                          : item.level == 3
                                          ? AppColors.level3
                                          : AppColors.level4,
                                      isUnlocked: _isLevelUnlocked(item.level),
                                      icon: item.level == 1
                                          ? Icons.looks_one
                                          : item.level == 2
                                          ? Icons.looks_two
                                          : item.level == 3
                                          ? Icons.looks_3
                                          : Icons.looks_4,
                                      onTap: () async {
                                        AppTtsService.instance.stop();
                                        if (item.level == 4) {
                                          await Navigator.push(
                                            context,
                                            AnimatedRoute.fadeScale(
                                              const MathLevel4HubView(),
                                            ),
                                          );
                                        } else {
                                          await Navigator.push(
                                            context,
                                            AnimatedRoute.fadeScale(
                                              MathLevelNumbersView(level: item),
                                            ),
                                          );
                                        }
                                        _loadProgress();
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              context.go(AppRouter.kHomeSubjectSelectionView);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          const Text(
            'اختر المستوى',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 48), // Balance for centering
        ],
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<Color> colors,
    required bool isUnlocked,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(minHeight: 160),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? colors
                : [Colors.grey.shade400, Colors.grey.shade600],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? colors[0].withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Floating background icon
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 150,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUnlocked ? icon : Icons.lock,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
