import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/level_one/presentation/views/level_one_view.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/level_two_view.dart';

class LevelsSelectionView extends StatefulWidget {
  const LevelsSelectionView({super.key});

  @override
  State<LevelsSelectionView> createState() => _LevelsSelectionViewState();
}

class _LevelsSelectionViewState extends State<LevelsSelectionView> {
  UserProgressService? _progressService;
  bool _level2Unlocked = false;
  double _level1Progress = 0.0;
  double _level2Progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await UserProgressService.getInstance();
    setState(() {
      _level2Unlocked = _progressService!.isLevel2Unlocked();
      _level1Progress = _progressService!.getLevel1Progress();
      _level2Progress = _progressService!.getLevel2Progress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      '🎓',
                      style: TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'اختر المستوى',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ابدأ رحلتك في تعلم اللغة العربية',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Levels
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Level 1
                      _buildLevelCard(
                        context: context,
                        level: 1,
                        title: 'المستوى الأول',
                        subtitle: 'تعلم الحروف الأبجدية',
                        icon: '📚',
                        progress: _level1Progress,
                        isLocked: false,
                        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LevelOneView(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Level 2
                      _buildLevelCard(
                        context: context,
                        level: 2,
                        title: 'المستوى الثاني',
                        subtitle: 'تكوين الكلمات والجمل',
                        icon: '🌟',
                        progress: _level2Progress,
                        isLocked: !_level2Unlocked,
                        colors: [Color(0xFFfa709a), Color(0xFFfee140)],
                        onTap: _level2Unlocked
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LevelTwoView(),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required int level,
    required String title,
    required String subtitle,
    required String icon,
    required double progress,
    required bool isLocked,
    required List<Color> colors,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : colors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isLocked
                  ? Colors.grey.withOpacity(0.3)
                  : colors[0].withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isLocked ? '🔒' : icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                const SizedBox(width: 20),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLocked ? 'أكمل المستوى السابق' : subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                if (!isLocked)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 24,
                  ),
              ],
            ),
            if (!isLocked && progress > 0) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'التقدم',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
