import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/exercises/data/models/revision_test_model.dart';
import 'package:arabic_learning_app/features/exercises/presentation/views/revision_test_view.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

class RevisionTestSelectionView extends StatelessWidget {
  final int groupNumber; // رقم المجموعة (0-6)

  const RevisionTestSelectionView({
    super.key,
    required this.groupNumber,
  });

  @override
  Widget build(BuildContext context) {
    final testGroup = revisionTestGroups[groupNumber];

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
                      ),

                      const SizedBox(height: 16),

                      // Future test types can be added here
                      _buildTestOption(
                        context,
                        title: 'اختبارات أخرى',
                        description: 'قريباً...',
                        icon: Icons.more_horiz,
                        color: Colors.grey,
                        testType: null,
                        isComingSoon: true,
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
  }) {
    return GestureDetector(
      onTap: isComingSoon
          ? null
          : () {
              if (testType == 'listening') {
                Navigator.push(
                  context,
                  AnimatedRoute.slideUp(
                    RevisionTestView(
                      groupNumber: groupNumber,
                    ),
                  ),
                );
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
            if (!isComingSoon)
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
