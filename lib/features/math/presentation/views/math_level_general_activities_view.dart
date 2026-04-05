import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'math_level1_quiz_view.dart';
import 'listen_and_write_view.dart';
import 'number_ordering_view.dart';
import 'math_pronunciation_view.dart';
import 'math_level2_greater_view.dart';
import 'math_level2_number_line_view.dart';
import 'math_level2_listen_write_view.dart';
import 'math_level2_count_by_ten_view.dart';

class MathLevelGeneralActivitiesView extends StatefulWidget {
  final MathLevelModel level;

  const MathLevelGeneralActivitiesView({super.key, required this.level});

  @override
  State<MathLevelGeneralActivitiesView> createState() => _MathLevelGeneralActivitiesViewState();
}

class _MathLevelGeneralActivitiesViewState extends State<MathLevelGeneralActivitiesView> {
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
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'الأنشطة العامة. اختر النشاط الذي تريد البدء به',
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
    if (_isLoading) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colors = widget.level.level == 1
        ? AppColors.level1
        : widget.level.level == 2
        ? AppColors.level2
        : AppColors.primaryGradient;

    final bool isLevel1 = widget.level.level == 1;
    final bool isLevel2 = widget.level.level == 2;

    bool allActivitiesDone = false;
    List<Widget> bodyChildren = [];

    if (isLevel1) {
      final quizDone = _progressService!.isLevelActivityCompleted(1, 'quiz');
      final listenWriteDone = _progressService!.isLevelActivityCompleted(1, 'listen_write');
      final orderingDone = _progressService!.isLevelActivityCompleted(1, 'number_ordering');
      final pronunciationDone = _progressService!.isLevelActivityCompleted(1, 'pronunciation');

      allActivitiesDone = quizDone && listenWriteDone && orderingDone && pronunciationDone;

      if (allActivitiesDone) {
        _progressService!.unlockLevel2();
      }

      bodyChildren = [
        // Activity 1: Quiz
        _buildActivityButton(
          title: 'النشاط ١: اختر الصورة الصحيحة',
          icon: Icons.image_search,
          colors: [AppColors.level1[0], AppColors.level1[1]],
          isCompleted: quizDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(
                const MathLevel1QuizView(),
              ),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(
                1,
                'quiz',
              );
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 2: Listen & Write
        _buildActivityButton(
          title: 'النشاط ٢: اسمع واكتب',
          icon: Icons.hearing,
          colors: [
            Colors.orange.shade500,
            Colors.deepOrange.shade500,
          ],
          isCompleted: listenWriteDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(
                const ListenAndWriteView(),
              ),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(
                1,
                'listen_write',
              );
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 3: Number Ordering
        _buildActivityButton(
          title: 'النشاط ٣: ترتيب الأرقام',
          icon: Icons.sort,
          colors: [
            Colors.teal.shade500,
            Colors.green.shade600,
          ],
          isCompleted: orderingDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(
                const NumberOrderingView(),
              ),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(
                1,
                'number_ordering',
              );
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 4: Pronunciation
        _buildActivityButton(
          title: 'النشاط ٤: انطق الأرقام',
          icon: Icons.mic,
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
          isCompleted: pronunciationDone, 
          onTap: () async {
            AppTtsService.instance.stop();

            // Target numbers 7, 8, 6, 2, 9 as requested by user
            final targetNumbers = [7, 8, 6, 2, 9];
            final modelsToTest = widget.level.numbers.where((n) => targetNumbers.contains(n.number)).toList();

            bool userFinishedAll = true;
            final isOverallActivityDone = _progressService!.isLevelActivityCompleted(1, 'pronunciation');
            
            for (var model in modelsToTest) {
              if (!context.mounted) return;
              await AppTtsService.instance.stop();
              
              // If overall activity is done, ignore individual completions here so they can replay
              final alreadyDone = !isOverallActivityDone && _progressService!.isActivityCompleted(1, model.number, 4);
              
              if (!alreadyDone) {
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  AnimatedRoute.slideRight(
                    MathPronunciationView(
                      numberModel: model,
                      levelModel: widget.level,
                    ),
                  ),
                );
                await _loadProgress();
                final doneNow = _progressService!.isActivityCompleted(1, model.number, 4);
                if (!doneNow) {
                  // User probably pressed back button, so exit sequence
                  userFinishedAll = false;
                  break;
                }
              }
            }

            if (userFinishedAll) {
              await _progressService!.completeLevelActivity(
                1,
                'pronunciation',
              );
            }
            _loadProgress();
          },
        ),
      ];
    } else if (isLevel2) {
      final greaterDone = _progressService!.isLevelActivityCompleted(2, 'greater_number');
      final numberLineDone = _progressService!.isLevelActivityCompleted(2, 'number_line');
      
      final listenWriteDone = _progressService!.isLevelActivityCompleted(2, 'listen_write_tens');
      final countByTenDone = _progressService!.isLevelActivityCompleted(2, 'count_by_ten');
      
      allActivitiesDone = greaterDone && numberLineDone && listenWriteDone && countByTenDone;
      
      if (allActivitiesDone) {
        _progressService!.unlockLevel3();
      }

      bodyChildren = [
        // Activity 1: Which is greater?
        _buildActivityButton(
          title: 'النشاط ١: أي أكبر؟',
          icon: Icons.compare_arrows,
          colors: [
            AppColors.level2[0],
            AppColors.level2[1],
          ],
          isCompleted: greaterDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(
                const MathLevel2GreaterView(),
              ),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(
                2,
                'greater_number',
              );
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 2: Number line ordering
        _buildActivityButton(
          title: 'النشاط ٢: خط الأعداد',
          icon: Icons.timeline,
          colors: [
            Colors.teal.shade500,
            Colors.teal.shade700,
          ],
          isCompleted: numberLineDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(
                const MathLevel2NumberLineView(),
              ),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(
                2,
                'number_line',
              );
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 3: Listen and write
        _buildActivityButton(
          title: 'النشاط ٣: اسمع الرقم واكتبه',
          icon: Icons.hearing,
          colors: [
            Colors.purple.shade400,
            Colors.purple.shade700,
          ],
          isCompleted: listenWriteDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(
                const MathLevel2ListenWriteView(),
              ),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(
                2,
                'listen_write_tens',
              );
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 5: Count by ten
        _buildActivityButton(
          title: 'النشاط ٥: العد بالعشرات',
          icon: Icons.bubble_chart,
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade700,
          ],
          isCompleted: countByTenDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(
                const MathLevel2CountByTenView(),
              ),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(
                2,
                'count_by_ten',
              );
            }
            _loadProgress();
          },
        ),
      ];
    }

    if (allActivitiesDone) {
      bodyChildren.addAll([
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade400,
                Colors.orange.shade500,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_open,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                isLevel1 ? 'تم فتح المستوى الثاني! 🎉' : 'تم فتح المستوى الثالث! 🎉',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأنشطة العامة'),
        backgroundColor: colors[0],
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[0].withValues(alpha: 0.3), colors[1].withValues(alpha: 0.3)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: bodyChildren,
          ),
        )
      )
    );
  }

  Widget _buildActivityButton({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle
                  : icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 16),
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
            if (isCompleted)
              const Text(
                'مكتمل ✓',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24)
          ],
        ),
      ),
    );
  }
}
