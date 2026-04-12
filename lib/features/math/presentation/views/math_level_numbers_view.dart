import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'svg_number_tracing_view.dart';
import 'math_level_general_activities_view.dart';
import 'math_level1_match_images_view.dart';
import 'math_level1_match_images_part2_view.dart';
class MathLevelNumbersView extends StatefulWidget {
  final MathLevelModel level;

  const MathLevelNumbersView({super.key, required this.level});

  @override
  State<MathLevelNumbersView> createState() => _MathLevelNumbersViewState();
}

class _MathLevelNumbersViewState extends State<MathLevelNumbersView> {
  MathProgressService? _progressService;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await MathProgressService.getInstance();
    if (!mounted) return;
    setState(() {});
    
    if (!_hasPlayedIntro) {
      _playIntroOnce();
    }
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    
    if (widget.level.level == 3 && _progressService != null && !_progressService!.isLevel3IntroPlayed()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLevel3Intro();
      });
    } else {
      await AppTtsService.instance.speakScreenIntro(
        '${widget.level.title}. اختر الرقم الذي تريد تعلمه',
        isMounted: () => mounted,
      );
    }
  }

  void _showLevel3Intro() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _Level3IntroDialog(
        onComplete: () {
          Navigator.pop(context);
          _progressService?.setLevel3IntroPlayed(true);
          AppTtsService.instance.speakScreenIntro(
            '${widget.level.title}. اختر الرقم الذي تريد تعلمه',
            isMounted: () => mounted,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  bool get _testMode => true; // Toggle to false when testing is over

  @override
  Widget build(BuildContext context) {
    final colors = widget.level.level == 1
        ? AppColors.level1
        : widget.level.level == 2
        ? AppColors.level2
        : AppColors.primaryGradient;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[0].withValues(alpha: 0.3), colors[1].withValues(alpha: 0.3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, colors),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: widget.level.numbers.length + (widget.level.level == 1 ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (widget.level.level == 1) {
                      if (index == 5) {
                        // Insert the matching activity card after number 5
                        final isUnlocked = _testMode ? true : (_progressService?.isNumberCompleted(1, 5) ?? false);
                        return _buildMatchActivityCard(isUnlocked, colors, 1);
                      } else if (index == 11) {
                        // Insert the matching activity card after number 10
                        final isUnlocked = _testMode ? true : (_progressService?.isNumberCompleted(1, 10) ?? false);
                        return _buildMatchActivityCard(isUnlocked, colors, 2);
                      }
                      
                      int actualIndex = index;
                      if (index > 11) {
                        actualIndex = index - 2;
                      } else if (index > 5) {
                        actualIndex = index - 1;
                      }
                      final numberModel = widget.level.numbers[actualIndex];
                      final isUnlocked = _testMode ? true : (_progressService?.isNumberUnlocked(
                            widget.level.level,
                            numberModel.number,
                          ) ??
                          false);
                      return _buildNumberCard(numberModel, isUnlocked, colors);
                    } else {
                      final numberModel = widget.level.numbers[index];
                      final isUnlocked = _testMode ? true : (_progressService?.isNumberUnlocked(
                            widget.level.level,
                            numberModel.number,
                          ) ??
                          false);
                      return _buildNumberCard(numberModel, isUnlocked, colors);
                    }
                  },
                ),
              ),
              if ((widget.level.level == 1 || widget.level.level == 2) && _progressService != null)
                Builder(
                  builder: (context) {
                    int completedCount = widget.level.numbers
                        .where(
                          (n) =>
                              _progressService?.isNumberCompleted(
                                widget.level.level,
                                n.number,
                              ) ==
                              true,
                        )
                        .length;

                    final allTracingDone =
                        _testMode ? true : (completedCount == widget.level.numbers.length);

                    bool allActivitiesDone = false;

                    if (widget.level.level == 1) {
                      final quizDone = _progressService!.isLevelActivityCompleted(
                        1,
                        'quiz',
                      );
                      final listenWriteDone = _progressService!
                          .isLevelActivityCompleted(1, 'listen_write');
                      final orderingDone = _progressService!
                          .isLevelActivityCompleted(1, 'number_ordering');
                      final pronunciationDone = _progressService!
                          .isLevelActivityCompleted(1, 'pronunciation');

                      allActivitiesDone =
                          allTracingDone &&
                          quizDone &&
                          listenWriteDone &&
                          orderingDone &&
                          pronunciationDone;

                      // Auto-unlock Level 2 when everything on Level 1 is done
                      if (allActivitiesDone) {
                        _progressService!.unlockLevel2();
                      }
                    } else if (widget.level.level == 2) {
                      final greaterDone = _progressService!.isLevelActivityCompleted(
                        2,
                        'greater_number',
                      );
                      final numberLineDone = _progressService!.isLevelActivityCompleted(
                        2,
                        'number_line',
                      );
                      final listenWriteTensDone = _progressService!.isLevelActivityCompleted(
                        2,
                        'listen_write_tens',
                      );
                      final countByTenDone = _progressService!.isLevelActivityCompleted(
                        2,
                        'count_by_ten',
                      );
                      
                      allActivitiesDone = allTracingDone && greaterDone && numberLineDone && listenWriteTensDone && countByTenDone;
                      
                      if (allActivitiesDone) {
                        _progressService!.unlockLevel3();
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          GestureDetector(
                             onTap: allTracingDone ? () async {
                                AppTtsService.instance.stop();
                                await Navigator.push(
                                  context, 
                                  AnimatedRoute.slideRight(MathLevelGeneralActivitiesView(level: widget.level))
                                );
                                _loadProgress();
                             } : null,
                             child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: allTracingDone 
                                      ? [colors[0], colors[1]]
                                      : [Colors.grey.shade400, Colors.grey.shade500],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: allTracingDone
                                        ? colors[0].withValues(alpha: 0.4)
                                      : Colors.grey.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                  ]
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                     Icon(
                                        allTracingDone ? Icons.play_circle_fill : Icons.lock,
                                        color: Colors.white,
                                        size: 32,
                                     ),
                                     const SizedBox(width: 12),
                                     const Text(
                                       'الدخول إلى الأنشطة',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                     )
                                  ],
                                ),
                             )
                          ),
                          
                          // Level unlock banner
                          if (allActivitiesDone) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
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
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    widget.level.level == 1 ? 'تم فتح المستوى الثاني! 🎉' : 'تم فتح المستوى الثالث! 🎉',
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

                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Color> colors) {
    // Calculate progress for this level
    int completedCount = 0;
    for (var n in widget.level.numbers) {
      if (_progressService?.isNumberCompleted(widget.level.level, n.number) ==
          true) {
        completedCount++;
      }
    }
    final total = widget.level.numbers.length;
    final progressVal = total > 0 ? (completedCount / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 48), // Spacer for balance
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.level.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.level.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
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
                      '${completedCount.toArabicDigits()} / ${total.toArabicDigits()} أرقام',
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
                  value: progressVal,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.greenAccent,
                  ),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(
    dynamic numberModel,
    bool isUnlocked,
    List<Color> colors,
  ) {
    final isCompleted =
        _progressService?.isNumberCompleted(
          widget.level.level,
          numberModel.number,
        ) ??
        false;

    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              var currentIdx = widget.level.numbers.indexWhere(
                (n) => n.number == numberModel.number,
              );
              while (currentIdx >= 0 &&
                  currentIdx < widget.level.numbers.length) {
                AppTtsService.instance.stop();
                if (!mounted) break;
                var result = await Navigator.push(
                  context,
                  AnimatedRoute.slideRight(
                    SvgNumberTracingView(
                      numberModel: widget.level.numbers[currentIdx],
                      levelModel: widget.level,
                    ),
                  ),
                );

                // Update background UI with latest progress before pushing next or exiting
                await _loadProgress();

                if (result == 'next' &&
                    currentIdx + 1 < widget.level.numbers.length) {
                  
                  if (widget.level.level == 1 && currentIdx == 4) {
                    // Start MathLevel1MatchImagesView after number 5
                    if (!mounted) break;
                    result = await Navigator.push(
                      context,
                      AnimatedRoute.slideRight(const MathLevel1MatchImagesView()),
                    );
                    if (result != 'next') {
                      break;
                    }
                  } else if (widget.level.level == 1 && currentIdx == 9) {
                    // Start MathLevel1MatchImagesPart2View after number 10
                    if (!mounted) break;
                    result = await Navigator.push(
                      context,
                      AnimatedRoute.slideRight(const MathLevel1MatchImagesPart2View()),
                    );
                    if (result != 'next') {
                      break;
                    }
                  }

                  currentIdx++;
                } else {
                  break;
                }
              }
            }
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isUnlocked
                    ? (isCompleted
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : colors)
                    : [Colors.grey.shade300, Colors.grey.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked
                      ? colors[0].withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUnlocked) ...[
                  Text(
                    numberModel.label,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.lock, size: 30, color: Colors.white70),
                  const SizedBox(height: 4),
                  Text(
                    numberModel.label,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isCompleted)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchActivityCard(bool isUnlocked, List<Color> colors, [int part = 1]) {
    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              AppTtsService.instance.stop();
              if (part == 1) {
                await Navigator.push(
                  context,
                  AnimatedRoute.slideRight(const MathLevel1MatchImagesView()),
                );
              } else {
                await Navigator.push(
                  context,
                  AnimatedRoute.slideRight(const MathLevel1MatchImagesPart2View()),
                );
              }
              await _loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [Colors.orange.shade400, Colors.orange.shade600]
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? Colors.orange.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              const Icon(Icons.extension, color: Colors.white, size: 36),
              const SizedBox(height: 4),
              const Text(
                'توصيل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              const Icon(Icons.lock, size: 30, color: Colors.white70),
              const SizedBox(height: 4),
              Text(
                'توصيل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Level3IntroDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _Level3IntroDialog({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<_Level3IntroDialog> createState() => _Level3IntroDialogState();
}

class _Level3IntroDialogState extends State<_Level3IntroDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const ElasticOutCurve(0.9)),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    
    _playAudioIntro();
  }

  Future<void> _playAudioIntro() async {
    await AppTtsService.instance.speak(
      "العدد المركب هو أي رقم من رقمين يتكوّن من جزئين : عشرات، وآحاد. كمثال: ثلاثة وعشرون تساوي عشرون زائد ثلاثة. وخمسة وأربعون تساوي أربعون زائد خمسة."
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.slateBlue, AppColors.darkSlateBlue],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.slateBlue.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_outline, size: 52, color: Colors.orangeAccent),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'العدد المركب',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'هو أي رقم من رقمين يتكوّن من جزئين:\nعشرات وآحاد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '💡 مثال:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.mintGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              _MathEquation(result: '23', val1: '20', val2: '3'),
                              _MathEquation(result: '45', val1: '40', val2: '5'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AppTtsService.instance.stop();
                          widget.onComplete();
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 28),
                        label: const Text(
                          'هيا نبدأ',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mintGreen,
                          foregroundColor: AppColors.darkSlateBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MathEquation extends StatelessWidget {
  final String result;
  final String val1;
  final String val2;

  const _MathEquation({
    required this.result,
    required this.val1,
    required this.val2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.darkSlateBlue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                val1,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.mintGreen)),
              ),
              Text(
                val2,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

