import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/word_spelling_view.dart';
import 'package:arabic_learning_app/features/level_two/presentation/views/word_match_view.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

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

class _LevelTwoViewState extends State<LevelTwoView> {
  UserProgressService? _progressService;
  double _progress = 0.0;
  int _currentActivity = 0;
  List<int> _unlockedLessons = [];

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
      title: 'كتابة الكلمات',
      description: 'اكتب الكلمات بشكل صحيح',
      icon: Icons.edit,
      colors: AppColors.exercise4,
    ),
    ActivityItem(
      title: 'تكوين الجمل',
      description: 'ابدأ في تكوين جمل بسيطة',
      icon: Icons.text_fields,
      colors: AppColors.exercise5,
    ),
    ActivityItem(
      title: 'قراءة الجمل',
      description: 'اقرأ الجمل بطلاقة وفهم',
      icon: Icons.record_voice_over,
      colors: AppColors.exercise2,
    ),
    ActivityItem(
      title: 'مراجعة شاملة',
      description: 'راجع كل ما تعلمته',
      icon: Icons.quiz,
      colors: AppColors.exercise6,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await UserProgressService.getInstance();
    setState(() {
      _progress = _progressService!.getLevel2Progress();
      _unlockedLessons = _progressService!.getLevel2UnlockedLessons();
      // Ensure first activity is always unlocked for testing
      if (!_unlockedLessons.contains(0)) {
        _unlockedLessons.add(0);
      }
      // Ensure second activity is unlocked for testing
      if (!_unlockedLessons.contains(1)) {
        _unlockedLessons.add(1);
      }
      _currentActivity = (_progress / (100 / _activities.length)).floor();
    });
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
                  gradient: const LinearGradient(
                    colors: AppColors.level2,
                  ),
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                                '${_currentActivity + 1} / ${_activities.length} نشاط',
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
                    final isUnlocked = _unlockedLessons.contains(index);
                    final isCompleted = index < _currentActivity;

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
      onTap: isUnlocked
          ? () async {
              // Navigate to activity
              if (index == 0) {
                // Word Spelling Activity
                await Navigator.push(
                  context,
                  AnimatedRoute.slideRight(const WordSpellingView()),
                );
                _loadProgress();
              } else if (index == 1) {
                // Word Match Activity
                await Navigator.push(
                  context,
                  AnimatedRoute.slideRight(const WordMatchView()),
                );
                _loadProgress();
              } else {
                // TODO: Implement other activities
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('هذا النشاط قيد التطوير 🚧'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          : null,
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
