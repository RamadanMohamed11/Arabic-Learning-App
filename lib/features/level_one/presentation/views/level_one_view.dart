import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/features/Alphabet/data/models/arabic_letter_model.dart';
import 'package:arabic_learning_app/features/Alphabet/presentation/views/letter_shapes_view.dart';
import 'package:arabic_learning_app/features/exercises/presentation/views/revision_test_selection_view.dart';
import 'package:go_router/go_router.dart';
import 'package:arabic_learning_app/core/utils/app_router.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/features/level_one/presentation/views/final_level_one_test_view.dart';

class LevelOneView extends StatefulWidget {
  const LevelOneView({super.key});

  @override
  State<LevelOneView> createState() => _LevelOneViewState();
}

class _LevelOneViewState extends State<LevelOneView> {
  UserProgressService? _progressService;
  List<int> _unlockedLetters = [];
  List<int> _unlockedLessons = [];
  List<int> _completedRevisions = [];
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await UserProgressService.getInstance();

    // Auto-correct any stale unlock data from before the fix was applied
    // This ensures letters only stay unlocked if all 3 revision tests are completed
    await _progressService!.validateAndCorrectUnlocks();

    setState(() {
      _unlockedLetters = _progressService!.getUnlockedLetters();
      _unlockedLessons = _progressService!.getLevel1UnlockedLessons();
      _completedRevisions = _progressService!.getCompletedRevisions();
      _progress = _progressService!.getLevel1Progress();
    });
  }

  String _getProgressEmoji() {
    if (_progress < 25) return '🌱';
    if (_progress < 50) return '🌿';
    if (_progress < 75) return '🌳';
    return '🌟';
  }

  Color _getProgressColor() {
    if (_progress < 25) return AppColors.error;
    if (_progress < 50) return AppColors.warning;
    if (_progress < 75) return AppColors.secondary;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final completedLetters =
        _unlockedLetters.length - 1; // -1 لأن أول حرف مفتوح افتراضياً
    final totalLetters = arabicLetters.length;

    return Scaffold(
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.level1[0].withOpacity(0.3),
              AppColors.level1[1].withOpacity(0.3),
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
                  gradient: const LinearGradient(colors: AppColors.level1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.level1[0].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'المستوى الأول',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الحروف الأبجدية',
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
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
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
                                '$completedLetters / $totalLetters حرف',
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

              // Letters Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount:
                      arabicLetters.length +
                      (arabicLetters.length ~/ 4) +
                      1, // +1 for final test card
                  itemBuilder: (context, index) {
                    // Final test card at the end
                    if (index ==
                        arabicLetters.length + (arabicLetters.length ~/ 4)) {
                      return _buildFinalTestCard();
                    }

                    // كل 4 حروف نضيف نشاط مراجعة
                    if ((index + 1) % 5 == 0) {
                      final reviewIndex = index ~/ 5;
                      return _buildReviewCard(reviewIndex);
                    }

                    final letterIndex = index - (index ~/ 5);
                    if (letterIndex >= arabicLetters.length) {
                      return const SizedBox.shrink();
                    }

                    final letter = arabicLetters[letterIndex];
                    // تحديد الدرس الذي ينتمي إليه هذا الحرف (كل 4 حروف = درس واحد)
                    final lessonIndex = letterIndex ~/ 4;
                    final isLessonUnlocked = _unlockedLessons.contains(
                      lessonIndex,
                    );

                    // Check if previous revision is completed (if letter is after first revision)
                    // Letters 0-3 (lesson 0): no previous revision
                    // Letters 4-7 (lesson 1): need revision 0 completed
                    // Letters 8-11 (lesson 2): need revision 1 completed, etc.
                    bool isPreviousRevisionCompleted = true;
                    if (lessonIndex > 0) {
                      final previousRevisionIndex = lessonIndex - 1;
                      isPreviousRevisionCompleted = _completedRevisions
                          .contains(previousRevisionIndex);
                    }

                    final isUnlocked =
                        _unlockedLetters.contains(letterIndex) &&
                        isLessonUnlocked &&
                        isPreviousRevisionCompleted;

                    return _buildLetterCard(letter, letterIndex, isUnlocked);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterCard(
    ArabicLetterModel letter,
    int index,
    bool isUnlocked,
  ) {
    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              // Navigate to letter shapes view
              await Navigator.push(
                context,
                AnimatedRoute.slideRight(
                  LetterShapesView(letter: letter.letter),
                ),
              );
              // إعادة تحميل التقدم عند العودة
              _loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? AppColors.primaryGradient
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? AppColors.shadowMedium
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Text(letter.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                letter.letter,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              const Icon(Icons.lock, size: 40, color: Colors.white70),
              const SizedBox(height: 8),
              Text(
                letter.letter,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(int reviewIndex) {
    // Revision test unlocks AFTER completing the 4 letters it reviews
    // Review 0 tests letters 0-3, so it unlocks when lesson 1 is unlocked
    // Review 1 tests letters 4-7, so it unlocks when lesson 2 is unlocked
    // Review 6 (last one) tests letters 24-27, unlocks when all 4 letters are completed
    bool isUnlocked;

    if (reviewIndex < 6) {
      // For revisions 0-5, unlock when next lesson is unlocked
      final requiredLessonIndex = reviewIndex + 1;
      isUnlocked = _unlockedLessons.contains(requiredLessonIndex);
    } else {
      // For last revision (6), unlock when all 4 letters (24-27) are completed
      // Check if all letters in this group have completed exercises
      isUnlocked = true;
      for (int i = 24; i <= 27; i++) {
        final tracingDone =
            _progressService?.isActivityCompleted(i, 0) ?? false;
        final pronunciationDone =
            _progressService?.isActivityCompleted(i, 1) ?? false;
        if (!tracingDone || !pronunciationDone) {
          isUnlocked = false;
          break;
        }
      }
    }

    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              await Navigator.push(
                context,
                AnimatedRoute.elegantZoom(
                  RevisionTestSelectionView(groupNumber: reviewIndex),
                ),
              );
              // إعادة تحميل التقدم بعد العودة من الاختبار
              _loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? AppColors.exercise2
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? AppColors.exercise2[0].withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnlocked ? Icons.quiz : Icons.lock,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            const Text(
              'مراجعة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${reviewIndex * 4 + 1}-${(reviewIndex + 1) * 4}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.level1[0], AppColors.level1[1]],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('📚', style: TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'المستوى الأول',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                title: const Text(
                  'معلومات عن التطبيق',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRouter.kAppInfoView);
                },
              ),
              const Divider(
                color: Colors.white24,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              ListTile(
                leading: const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 24,
                ),
                title: const Text(
                  'فريق العمل وأصحاب الفكرة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRouter.kAboutView);
                },
              ),
              const Divider(
                color: Colors.white24,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              ListTile(
                leading: const Icon(
                  Icons.contact_mail,
                  color: Colors.white,
                  size: 24,
                ),
                title: const Text(
                  'تواصل معنا',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRouter.kContactUsView);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalTestCard() {
    // Final test unlocks when ALL revisions are completed
    // There are 7 revision groups (0-6)
    final allRevisionsCompleted = _completedRevisions.length >= 7;

    return GestureDetector(
      onTap: allRevisionsCompleted
          ? () async {
              await Navigator.push(
                context,
                AnimatedRoute.elegantZoom(const FinalLevelOneTestView()),
              );
              // إعادة تحميل التقدم بعد العودة من الاختبار
              _loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: allRevisionsCompleted
                ? [
                    const Color(0xFFFFD700), // Gold
                    const Color(0xFFFF8C00), // Dark orange
                  ]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: allRevisionsCompleted
                  ? const Color(0xFFFFD700).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              allRevisionsCompleted ? Icons.emoji_events : Icons.lock,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            const Text(
              'الاختبار',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'النهائي',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
