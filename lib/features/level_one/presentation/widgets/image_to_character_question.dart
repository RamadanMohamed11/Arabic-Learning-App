import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_one/data/models/final_test_model.dart';

/// Widget for displaying Image to Character recognition questions
/// Shows an emoji and multiple letter choices
class ImageToCharacterQuestion extends StatelessWidget {
  final FinalTestQuestion question;
  final List<String> shuffledOptions;
  final String? selectedAnswer;
  final bool isAnswered;
  final Function(String) onAnswerSelected;
  final VoidCallback onNext;

  const ImageToCharacterQuestion({
    super.key,
    required this.question,
    required this.shuffledOptions,
    required this.selectedAnswer,
    required this.isAnswered,
    required this.onAnswerSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Section Title
        const Text(
          '🅰 أولًا: التعرف على الحروف',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),

        // Question Text
        const Text(
          'اختر الحرف الصحيح للصورة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 32),

        // Emoji Display
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            question.emoji ?? '',
            style: const TextStyle(fontSize: 80),
          ),
        ),

        const SizedBox(height: 48),

        // Options Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: shuffledOptions.length,
          itemBuilder: (context, index) {
            final option = shuffledOptions[index];
            return _buildOptionCard(option);
          },
        ),

        const SizedBox(height: 32),

        // Next Button
        if (isAnswered) _buildNextButton(),
      ],
    );
  }

  Widget _buildOptionCard(String option) {
    final isCorrect = option == question.correctAnswer;
    final isSelected = option == selectedAnswer;

    Color getBackgroundColor() {
      if (!isAnswered) {
        return Colors.white;
      }
      if (isSelected) {
        return isCorrect ? AppColors.success : AppColors.error;
      }
      if (isCorrect) {
        return AppColors.success.withOpacity(0.5);
      }
      return Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: isAnswered ? null : () => onAnswerSelected(option),
      child: Container(
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAnswered && isSelected
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                option,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isAnswered && (isSelected || isCorrect)
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
              if (isAnswered && isSelected) ...[
                const SizedBox(width: 8),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'السؤال التالي',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }
}
