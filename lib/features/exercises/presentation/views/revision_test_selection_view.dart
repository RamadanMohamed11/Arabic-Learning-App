import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/exercises/data/models/revision_test_model.dart';
import 'package:arabic_learning_app/features/exercises/presentation/views/revision_test_view.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/features/exercises/presentation/views/widgets/revision_writing_practice.dart';

class RevisionTestSelectionView extends StatefulWidget {
  final int groupNumber; // رقم المجموعة (0-6)

  const RevisionTestSelectionView({
    super.key,
    required this.groupNumber,
  });

  @override
  State<RevisionTestSelectionView> createState() => _RevisionTestSelectionViewState();
}

class _RevisionTestSelectionViewState extends State<RevisionTestSelectionView> {
  UserProgressService? _progressService;
  bool _listeningCompleted = false;
  bool _writingCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await UserProgressService.getInstance();
    setState(() {
      _listeningCompleted = _progressService!.isRevisionListeningCompleted(widget.groupNumber);
      _writingCompleted = _progressService!.isRevisionWritingCompleted(widget.groupNumber);
      _isLoading = false;
    });
  }

  int _getLetterIndex(String letter) {
    const arabicLetters = [
      'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر',
      'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف',
      'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي'
    ];
    return arabicLetters.indexOf(letter);
  }

  /// Check if both tests are completed and unlock next letter
  Future<void> _checkAndUnlockNextLetter() async {
    if (_progressService == null) return;

    final listeningDone = _progressService!.isRevisionListeningCompleted(widget.groupNumber);
    final writingDone = _progressService!.isRevisionWritingCompleted(widget.groupNumber);

    // Only unlock if BOTH tests are completed
    if (listeningDone && writingDone) {
      // Mark this revision as completed
      await _progressService!.completeRevision(widget.groupNumber);

      // حساب فهرس الحرف التالي
      final nextLetterIndex = (widget.groupNumber + 1) * 4;

      // فتح الحرف التالي فقط (إذا كان موجوداً)
      if (nextLetterIndex < 28) {
        await _progressService!.unlockLetter(nextLetterIndex);

        // تحديث شريط التقدم
        final unlockedCount = _progressService!.getUnlockedLetters().length;
        final progress = (unlockedCount / 28) * 100;
        await _progressService!.setLevel1Progress(progress);
      }

      // فتح الدرس/المجموعة التالية
      if (widget.groupNumber < 6) {
        await _progressService!.unlockLevel1Lesson(widget.groupNumber + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final testGroup = revisionTestGroups[widget.groupNumber];

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.exercise2[0].withOpacity(0.3),
              AppColors.exercise2[1].withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.exercise2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.exercise2[0].withOpacity(0.3),
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
                              Text(
                                '${testGroup.emoji} ${testGroup.title}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                testGroup.letters.join(' - '),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.headphones,
                        size: 100,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'اختبار الاستماع',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'استمع إلى الحرف واختر الإجابة الصحيحة من بين الخيارات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Test Options
                      _buildTestOption(
                        context,
                        title: 'اختبار الاستماع',
                        description: 'استمع واختر الحرف الصحيح',
                        icon: Icons.hearing,
                        color: AppColors.exercise2[0],
                        testType: 'listening',
                        isCompleted: _listeningCompleted,
                      ),

                      const SizedBox(height: 16),

                      _buildTestOption(
                        context,
                        title: 'اختبار الكتابة',
                        description: 'ارسم الحروف: ${testGroup.letters.join(' - ')}',
                        icon: Icons.edit,
                        color: AppColors.exercise1[0],
                        testType: 'writing',
                        isCompleted: _writingCompleted,
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

  Widget _buildTestOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String? testType,
    bool isComingSoon = false,
    bool isCompleted = false,
  }) {
    return GestureDetector(
      onTap: isComingSoon
          ? null
          : () async {
              if (testType == 'listening') {
                await Navigator.push(
                  context,
                  AnimatedRoute.slideUp(
                    RevisionTestView(
                      groupNumber: widget.groupNumber,
                      isStandalone: true,
                    ),
                  ),
                );
                // Reload progress after returning
                await _loadProgress();
              } else if (testType == 'writing') {
                final letters = revisionTestGroups[widget.groupNumber].letters;
                final letterIndices = letters.map((letter) => _getLetterIndex(letter)).toList();
                
                await Navigator.push(
                  context,
                  AnimatedRoute.slideScale(
                    RevisionWritingPractice(
                      letters: letters,
                      letterIndices: letterIndices,
                      onComplete: () async {
                        // Mark writing test as completed
                        await _progressService!.completeRevisionWriting(widget.groupNumber);
                        // Check if both tests are completed to unlock next letter
                        await _checkAndUnlockNextLetter();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
                // Reload progress after returning
                await _loadProgress();
              }
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isComingSoon
                ? [Colors.grey.shade300, Colors.grey.shade400]
                : [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 32,
                ),
              )
            else if (!isComingSoon)
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
