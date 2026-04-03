import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/word_spelling_view.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/word_match_view.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/missing_word_view.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/sentence_order_view.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/final_test_view.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/image_name_view.dart';

class ActivityItem {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;

  const ActivityItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
  });
}

class LevelTwoView extends StatefulWidget {
  const LevelTwoView({super.key});

  @override
  State<LevelTwoView> createState() => _LevelTwoViewState();
}

const int _finalTestActivityIndex = 5;
const bool kForceLevelTwoFinalTestUnlocked = false;

class _LevelTwoViewState extends State<LevelTwoView> {
  UserProgressService? _progressService;
  double _progress = 0.0;
  List<int> _unlockedLessons = [];
  Set<int> _completedActivities = {};

  final List<ActivityItem> _activities = const [
    ActivityItem(
      title: 'تهجئة الكلمة',
      description: 'رتب الحروف لتكوين الكلمات الصحيحة',
      icon: Icons.extension,
      colors: AppColors.exercise1,
    ),
    ActivityItem(
      title: 'وصل الكلمة',
      description: 'أوصل كل كلمة بالصورة المناسبة',
      icon: Icons.link,
      colors: AppColors.exercise3,
    ),
    ActivityItem(
      title: 'إكمال الكلمة الناقصة',
      description: 'أكمل الحرف/الحروف الناقصة لِتكوين الكلمة الصحيحة',
      icon: Icons.edit_note,
      colors: AppColors.exercise4,
    ),
    ActivityItem(
      title: 'اكتب اسم الصورة',
      description: 'يُعرض للمتعلم صورة ويكتب الكلمة المناسبة',
      icon: Icons.image,
      colors: AppColors.exercise5,
    ),
    ActivityItem(
      title: 'رتّب الكلمات',
      description: 'رتّب الكلمات لتكوين جملة صحيحة',
      icon: Icons.format_list_numbered,
      colors: AppColors.exercise2,
    ),
    ActivityItem(
      title: 'اختبار نهاية المستوى',
      description: 'اختبر مهاراتك في الكلمات والجمل',
      icon: Icons.emoji_events,
      colors: AppColors.exercise1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final service = await UserProgressService.getInstance();
    final progress = service.getLevel2Progress();
    List<int> unlocked = service.getLevel2UnlockedLessons();
    if (unlocked.isEmpty || !unlocked.contains(0)) {
      await service.unlockLevel2Lesson(0);
      unlocked = service.getLevel2UnlockedLessons();
    }
    unlocked.sort();

    _initTts();
    setState(() {
      _progressService = service;
      _progress = progress;
      _unlockedLessons = unlocked;
      _completedActivities = service.getLevel2CompletedActivities().toSet();
    });
  }

  Future<void> _initTts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await AppTtsService.instance.speak(
        'المستوى الثاني: تعلم الكلمات والجمل! اختر النشاط الذي تريد',
      );
    }
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  Future<void> _openActivity(int index) async {
    if (_progressService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل التقدم، حاول مرة أخرى.')),
      );
      return;
    }

    final view = _getActivityView(index);
    if (view == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا النشاط قيد التطوير 🚧'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    AppTtsService.instance.stop();
    final result = await Navigator.push(
      context,
      AnimatedRoute.slideRight(view),
    );

    if (result == true) {
      await _progressService!.completeLevel2Activity(
        activityIndex: index,
        totalActivities: _activities.length,
      );
    }

    await _loadProgress();
  }

  Widget? _getActivityView(int index) {
    switch (index) {
      case 0:
        return const WordSpellingView();
      case 1:
        return const WordMatchView();
      case 2:
        return const MissingWordView();
      case 3:
        return const ImageNameView();
      case 4:
        return const SentenceOrderView();
      case 5:
        return const FinalTestView();
      default:
        return null;
    }
  }

  String _getProgressEmoji() {
    if (_progress < 20) return '🌱';
    if (_progress < 40) return '🌿';
    if (_progress < 60) return '🌳';
    if (_progress < 80) return '⭐';
    return '🏆';
  }

  Color _getProgressColor() {
    if (_progress < 20) return AppColors.error;
    if (_progress < 40) return AppColors.warning;
    if (_progress < 60) return AppColors.secondary;
    if (_progress < 80) return AppColors.primary;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.level2[0].withOpacity(0.3),
              AppColors.level2[1].withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.level2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.level2[0].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'المستوى الثاني',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الكلمات والجمل',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _getProgressEmoji(),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'التقدم',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${_completedActivities.length} / ${_activities.length} نشاط مكتمل',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _progress / 100,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(),
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_progress.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Activities List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    // Final test requires all 5 previous activities (0-4) to be completed
                    final isFinalTest = index == _finalTestActivityIndex;
                    final allPreviousCompleted = isFinalTest
                        ? _completedActivities.containsAll([0, 1, 2, 3, 4])
                        : true;
                    final forceUnlocked =
                        kForceLevelTwoFinalTestUnlocked &&
                        index == _finalTestActivityIndex;
                    final isUnlocked =
                        forceUnlocked ||
                        (_unlockedLessons.contains(index) &&
                            allPreviousCompleted);
                    final isCompleted = _completedActivities.contains(index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildActivityCard(
                        activity: activity,
                        index: index,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
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

  Widget _buildActivityCard({
    required ActivityItem activity,
    required int index,
    required bool isUnlocked,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? () => _openActivity(index) : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? activity.colors
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? activity.colors[0].withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Number Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Activity Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked ? activity.description : 'أكمل النشاط السابق',
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnlocked
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            // Status Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle
                    : isUnlocked
                    ? activity.icon
                    : Icons.lock,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
