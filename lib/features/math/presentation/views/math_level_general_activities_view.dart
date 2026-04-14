import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
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

import 'math_level3_decompose_view.dart';
import 'math_level3_listen_choose_view.dart';
import 'math_level3_listen_write_view.dart';
import 'math_level3_complete_number_view.dart';
import 'math_level3_true_false_view.dart';
import 'math_level3_ordering_view.dart';
import 'math_level3_greater_view.dart';

class MathLevelGeneralActivitiesView extends StatefulWidget {
  final MathLevelModel level;

  const MathLevelGeneralActivitiesView({super.key, required this.level});

  @override
  State<MathLevelGeneralActivitiesView> createState() =>
      _MathLevelGeneralActivitiesViewState();
}

class _MathLevelGeneralActivitiesViewState
    extends State<MathLevelGeneralActivitiesView> {
  MathProgressService? _progressService;
  late final ConfettiController _confettiController;
  bool _isLoading = true;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _initService();
  }

  Future<void> _initService() async {
    _progressService = await MathProgressService.getInstance();
    _loadProgress();
  }

  void _loadProgress() {
    if (_progressService != null && mounted) {
      setState(() {
        _isLoading = false;
      });
      _playIntro();
    }
  }

  Future<void> _playIntro() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'أنشطة عامة. اختر النشاط لنبدأ',
      isMounted: () => mounted,
    );
  }

  Future<void> _handleActivityCompletion(String activityId) async {
    if (_progressService == null) return;

    if (!_progressService!.isLevelActivityCompleted(
      widget.level.level,
      activityId,
    )) {
      await _progressService!.completeLevelActivity(
        widget.level.level,
        activityId,
      );
      _confettiController.play();
      _loadProgress();
    }
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isLevel1 = widget.level.level == 1;
    final bool isLevel2 = widget.level.level == 2;
    final bool isLevel3 = widget.level.level == 3;

    final colors = isLevel1
        ? [AppColors.level1[0], AppColors.level1[1]]
        : isLevel2
            ? [AppColors.level2[0], AppColors.level2[1]]
            : [AppColors.level3[0], AppColors.level3[1]];

    bool allActivitiesDone = false;
    List<Widget> bodyChildren = [];

    if (isLevel3) {
      final act1Done = _progressService!.isLevelActivityCompleted(3, 'decompose');
      final act2Done = _progressService!.isLevelActivityCompleted(3, 'listen_choose');
      final act3Done = _progressService!.isLevelActivityCompleted(3, 'listen_write');
      final act4Done = _progressService!.isLevelActivityCompleted(3, 'complete_number');
      final act5Done = _progressService!.isLevelActivityCompleted(3, 'true_false');
      final act6Done = _progressService!.isLevelActivityCompleted(3, 'ordering');
      final act7Done = _progressService!.isLevelActivityCompleted(3, 'greater');

      allActivitiesDone = act1Done && act2Done && act3Done && act4Done && act5Done && act6Done && act7Done;

      bodyChildren = [
        _buildActivityButton(
          title: 'النشاط ١: فك الأعداد',
          icon: Icons.call_split,
          colors: [AppColors.slateBlue, AppColors.darkSlateBlue],
          isCompleted: act1Done,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MathLevel3DecomposeView()),
            );
            if (result == true) {
              _handleActivityCompletion('decompose');
            }
          },
        ),
        const SizedBox(height: 16),
        _buildActivityButton(
          title: 'النشاط ٢: اسمع واختار',
          icon: Icons.hearing,
          colors: [AppColors.softTeal, AppColors.darkTeal],
          isCompleted: act2Done,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MathLevel3ListenChooseView()),
            );
            if (result == true) {
              _handleActivityCompletion('listen_choose');
            }
          },
        ),
        const SizedBox(height: 16),
        _buildActivityButton(
          title: 'النشاط ٣: ده كام؟ (اسمع واكتب)',
          icon: Icons.edit,
          colors: [AppColors.mintGreen, AppColors.softTeal],
          isCompleted: act3Done,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MathLevel3ListenWriteView()),
            );
            if (result == true) {
              _handleActivityCompletion('listen_write');
            }
          },
        ),
        const SizedBox(height: 16),
        _buildActivityButton(
          title: 'النشاط ٤: كمل الرقم',
          icon: Icons.add_box,
          colors: [AppColors.darkSlateBlue, const Color(0xFF5A7A8A)],
          isCompleted: act4Done,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MathLevel3CompleteNumberView()),
            );
            if (result == true) {
              _handleActivityCompletion('complete_number');
            }
          },
        ),
        const SizedBox(height: 16),
        _buildActivityButton(
          title: 'النشاط ٥: صح ولا غلط',
          icon: Icons.check_circle_outline,
          colors: [AppColors.darkTeal, const Color(0xFF6BA0A0)],
          isCompleted: act5Done,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MathLevel3TrueFalseView()),
            );
            if (result == true) {
              _handleActivityCompletion('true_false');
            }
          },
        ),
        const SizedBox(height: 16),
        _buildActivityButton(
          title: 'النشاط ٦: ترتيب الأرقام',
          icon: Icons.sort_by_alpha,
          colors: [AppColors.lightSlateBlue, AppColors.slateBlue],
          isCompleted: act6Done,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MathLevel3OrderingView()),
            );
            if (result == true) {
              _handleActivityCompletion('ordering');
            }
          },
        ),
        const SizedBox(height: 16),
        _buildActivityButton(
          title: 'النشاط ٧: اختار الأكبر',
          icon: Icons.compare,
          colors: [const Color(0xFF8AB5C7), AppColors.darkSlateBlue],
          isCompleted: act7Done,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MathLevel3GreaterView()),
            );
            if (result == true) {
              _handleActivityCompletion('greater');
            }
          },
        ),
      ];
    } else if (isLevel1) {
      final quizDone = _progressService!.isLevelActivityCompleted(1, 'quiz');
      final listenWriteDone = _progressService!.isLevelActivityCompleted(
        1,
        'listen_write',
      );
      final orderingDone = _progressService!.isLevelActivityCompleted(
        1,
        'number_ordering',
      );
      final pronunciationDone = _progressService!.isLevelActivityCompleted(
        1,
        'pronunciation',
      );

      allActivitiesDone =
          quizDone && listenWriteDone && orderingDone && pronunciationDone;

      if (allActivitiesDone) {
        final wasUnlocked = _progressService!.isLevel2Unlocked();
        if (!wasUnlocked) {
          _progressService!.unlockLevel2();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              AppTtsService.instance.speakScreenIntro(
                'أحسنت! تم فتح المستوى الثاني بنجاح',
                isMounted: () => mounted,
              );
            }
          });
        }
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
              AnimatedRoute.fadeScale(const MathLevel1QuizView()),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(1, 'quiz');
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 2: Listen & Write
        _buildActivityButton(
          title: 'النشاط ٢: اسمع واكتب',
          icon: Icons.hearing,
          colors: [Colors.orange.shade500, Colors.deepOrange.shade500],
          isCompleted: listenWriteDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(const ListenAndWriteView()),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(1, 'listen_write');
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 3: Number Ordering
        _buildActivityButton(
          title: 'النشاط ٣: ترتيب الأرقام',
          icon: Icons.sort,
          colors: [Colors.teal.shade500, Colors.green.shade600],
          isCompleted: orderingDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(const NumberOrderingView()),
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
          colors: [Colors.red.shade400, Colors.red.shade600],
          isCompleted: pronunciationDone,
          onTap: () async {
            AppTtsService.instance.stop();

            // Target numbers 7, 8, 6, 2, 9 as requested by user
            final targetNumbers = [7, 8, 6, 2, 9];
            final modelsToTest = widget.level.numbers
                .where((n) => targetNumbers.contains(n.number))
                .toList();

            bool userFinishedAll = true;
            final isOverallActivityDone = _progressService!
                .isLevelActivityCompleted(1, 'pronunciation');

            for (var model in modelsToTest) {
              if (!context.mounted) return;
              await AppTtsService.instance.stop();

              // If overall activity is done, ignore individual completions here so they can replay
              final alreadyDone =
                  !isOverallActivityDone &&
                  _progressService!.isActivityCompleted(1, model.number, 4);

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
                _loadProgress();
                final doneNow = _progressService!.isActivityCompleted(
                  1,
                  model.number,
                  4,
                );
                if (!doneNow) {
                  // User probably pressed back button, so exit sequence
                  userFinishedAll = false;
                  break;
                }
              }
            }

            if (userFinishedAll) {
              await _progressService!.completeLevelActivity(1, 'pronunciation');
            }
            _loadProgress();
          },
        ),
      ];
    } else if (isLevel2) {
      final greaterDone = _progressService!.isLevelActivityCompleted(
        2,
        'greater_number',
      );
      final numberLineDone = _progressService!.isLevelActivityCompleted(
        2,
        'number_line',
      );

      final listenWriteDone = _progressService!.isLevelActivityCompleted(
        2,
        'listen_write_tens',
      );
      final countByTenDone = _progressService!.isLevelActivityCompleted(
        2,
        'count_by_ten',
      );

      allActivitiesDone =
          greaterDone && numberLineDone && listenWriteDone && countByTenDone;

      if (allActivitiesDone) {
        final wasUnlocked = _progressService!.isLevel3Unlocked();
        if (!wasUnlocked) {
          _progressService!.unlockLevel3();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              AppTtsService.instance.speakScreenIntro(
                'أحسنت! تم فتح المستوى الثالث بنجاح',
                isMounted: () => mounted,
              );
            }
          });
        }
      }

      bodyChildren = [
        // Activity 1: Which is greater?
        _buildActivityButton(
          title: 'النشاط ١: أي أكبر؟',
          icon: Icons.compare_arrows,
          colors: [AppColors.level2[0], AppColors.level2[1]],
          isCompleted: greaterDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(const MathLevel2GreaterView()),
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
          colors: [Colors.teal.shade500, Colors.teal.shade700],
          isCompleted: numberLineDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(const MathLevel2NumberLineView()),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(2, 'number_line');
            }
            _loadProgress();
          },
        ),
        const SizedBox(height: 16),

        // Activity 3: Listen and write
        _buildActivityButton(
          title: 'النشاط ٣: اسمع الرقم واكتبه',
          icon: Icons.hearing,
          colors: [Colors.purple.shade400, Colors.purple.shade700],
          isCompleted: listenWriteDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(const MathLevel2ListenWriteView()),
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
          colors: [Colors.orange.shade400, Colors.orange.shade700],
          isCompleted: countByTenDone,
          onTap: () async {
            AppTtsService.instance.stop();
            final result = await Navigator.push(
              context,
              AnimatedRoute.fadeScale(const MathLevel2CountByTenView()),
            );
            if (result == true) {
              await _progressService!.completeLevelActivity(2, 'count_by_ten');
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
              colors: [Colors.amber.shade400, Colors.orange.shade500],
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
              const Icon(Icons.lock_open, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                isLevel1
                    ? 'تم فتح المستوى الثاني! 🎉'
                    : (widget.level.level == 2 ? 'تم فتح المستوى الثالث! 🎉' : 'تهانينا! أكملت كل الأنشطة! 🎉'),
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
            colors: [
              colors[0].withValues(alpha: 0.3),
              colors[1].withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: bodyChildren),
        ),
      ),
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
              isCompleted ? Icons.check_circle : icon,
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
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
