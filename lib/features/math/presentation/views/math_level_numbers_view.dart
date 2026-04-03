import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'svg_number_tracing_view.dart';
import 'math_level1_quiz_view.dart';
import 'listen_and_write_view.dart';
import 'number_ordering_view.dart';

class MathLevelNumbersView extends StatefulWidget {
  final MathLevelModel level;

  const MathLevelNumbersView({super.key, required this.level});

  @override
  State<MathLevelNumbersView> createState() => _MathLevelNumbersViewState();
}

class _MathLevelNumbersViewState extends State<MathLevelNumbersView> {
  MathProgressService? _progressService;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await MathProgressService.getInstance();
    _initTts();
    setState(() {});
  }

  Future<void> _initTts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      await AppTtsService.instance.speak(
        '${widget.level.title}. اختر الرقم الذي تريد تعلمه',
      );
    }
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

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
            colors: [colors[0].withOpacity(0.3), colors[1].withOpacity(0.3)],
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
                  itemCount: widget.level.numbers.length,
                  itemBuilder: (context, index) {
                    final numberModel = widget.level.numbers[index];
                    final isUnlocked =
                        _progressService?.isNumberUnlocked(
                          widget.level.level,
                          numberModel.number,
                        ) ??
                        false;
                    return _buildNumberCard(numberModel, isUnlocked, colors);
                  },
                ),
              ),
              if (widget.level.level == 1 && _progressService != null)
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
                        completedCount == widget.level.numbers.length;

                    final quizDone = _progressService!.isLevelActivityCompleted(
                      1,
                      'quiz',
                    );
                    final listenWriteDone = _progressService!
                        .isLevelActivityCompleted(1, 'listen_write');
                    final orderingDone = _progressService!
                        .isLevelActivityCompleted(1, 'number_ordering');

                    final allActivitiesDone =
                        allTracingDone &&
                        quizDone &&
                        listenWriteDone &&
                        orderingDone;

                    // Auto-unlock Level 2 when everything on Level 1 is done
                    if (allActivitiesDone) {
                      _progressService!.unlockLevel2();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Activity 1: Quiz — اختر الصورة الصحيحة
                          _buildActivityButton(
                            title: 'النشاط ١: اختر الصورة الصحيحة',
                            icon: Icons.image_search,
                            colors: [AppColors.level1[0], AppColors.level1[1]],
                            isUnlocked: allTracingDone,
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
                          const SizedBox(height: 12),

                          // Activity 2: Listen & Write
                          _buildActivityButton(
                            title: 'النشاط ٢: اسمع واكتب',
                            icon: Icons.hearing,
                            colors: [
                              Colors.orange.shade500,
                              Colors.deepOrange.shade500,
                            ],
                            isUnlocked: allTracingDone,
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
                          const SizedBox(height: 12),

                          // Activity 3: Number Ordering
                          _buildActivityButton(
                            title: 'النشاط ٣: ترتيب الأرقام',
                            icon: Icons.sort,
                            colors: [
                              Colors.teal.shade500,
                              Colors.green.shade600,
                            ],
                            isUnlocked: allTracingDone,
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

                          // Level 2 unlock banner
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
                                    color: Colors.amber.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_open,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'تم فتح المستوى الثاني! 🎉',
                                    style: TextStyle(
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
            color: colors[0].withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.9),
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
                  backgroundColor: Colors.white.withOpacity(0.3),
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
                final result = await Navigator.push(
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
                      ? colors[0].withOpacity(0.3)
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
                      color: Colors.white.withOpacity(0.5),
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

  Widget _buildActivityButton({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUnlocked && !isCompleted
          ? onTap
          : isCompleted
          ? onTap
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUnlocked
                ? (isCompleted
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : colors)
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isUnlocked ? colors[0] : Colors.grey).withOpacity(0.3),
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
                  : isUnlocked
                  ? icon
                  : Icons.lock,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (isCompleted)
              const Text(
                'مكتمل ✓',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (isUnlocked)
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20)
            else
              const Text(
                'أكمل التتبع أولاً',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
