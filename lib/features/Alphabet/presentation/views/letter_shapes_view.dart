import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/models/letter_shapes.dart';
import 'package:arabic_learning_app/core/data/letter_names.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/features/level_one/presentation/views/letter_test_selection_view.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

class LetterShapesView extends StatefulWidget {
  final String letter;

  const LetterShapesView({super.key, required this.letter});

  @override
  State<LetterShapesView> createState() => _LetterShapesViewState();
}

class _LetterShapesViewState extends State<LetterShapesView> {
  LetterShapes? letterShapes;
  LetterName? _letterName;
  String exampleWord = '';
  int _letterIndex = 0;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    letterShapes = ArabicLetterShapes.getShapes(widget.letter);
    _letterName = getLetterName(widget.letter);
    // Get the word with tashkeel from arabicLetters list
    final letterData = arabicLetters.firstWhere(
      (l) => l.letter == widget.letter,
      orElse: () => arabicLetters[0],
    );
    exampleWord = letterData.word;

    // الحصول على رقم الحرف
    _letterIndex = arabicLetters.indexWhere((l) => l.letter == widget.letter);

    _playIntro();
  }

  Future<void> _playIntro() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'هذا حرف ${widget.letter}. يمكنك الضغط على الحرف لسماع نطقه. اضغط على التمارين لبدء التعلم',
      isMounted: () => mounted,
    );
  }

  void _speak(String text) {
    AppTtsService.instance.speak(text);
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (letterShapes == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('أشكال الحرف'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('الحرف غير متوفر', style: TextStyle(fontSize: 24)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'أشكال حرف ${letterShapes!.name}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header مع الحرف الكبير
            _buildHeader(),

            const SizedBox(height: 20),

            // أشكال الحرف
            _buildShapesSection(),

            const SizedBox(height: 20),

            // مثال على الحرف
            _buildExampleSection(),

            const SizedBox(height: 20),

            // زر الانتقال للتمارين
            _buildCompleteButton(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Header مع الحرف الكبير
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // الحرف مع أيقونة السماعة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                letterShapes!.isolated,
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => _speak(
                  _letterName?.nameWithDiacritics ?? letterShapes!.name,
                ),
                icon: Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 40,
                ),
                tooltip: 'استمع للحرف',
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// قسم أشكال الحرف
  Widget _buildShapesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أشكال الحرف:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildShapeCard(
                  'منفصل',
                  letterShapes!.isolated,
                  AppColors.primary,
                  Icons.fiber_manual_record,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShapeCard(
                  'أول الكلمة',
                  letterShapes!.initial,
                  AppColors.secondary,
                  Icons.arrow_forward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildShapeCard(
                  'وسط الكلمة',
                  letterShapes!.medial,
                  AppColors.accent,
                  Icons.swap_horiz,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShapeCard(
                  'آخر الكلمة',
                  letterShapes!.final_,
                  AppColors.darkSlateBlue,
                  Icons.arrow_back,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بطاقة شكل الحرف
  Widget _buildShapeCard(
    String title,
    String shape,
    Color color,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () =>
          _speak('${widget.letter} $title'),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              shape,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Icon(Icons.volume_up, color: color.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  /// قسم المثال
  Widget _buildExampleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مثال:',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _speak(exampleWord),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    exampleWord,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volume_up, color: Colors.black, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'اضغط للاستماع',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// زر الانتقال للتمارين
  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            AnimatedRoute.slideUp(
              LetterTestSelectionView(
                letter: widget.letter,
                letterIndex: _letterIndex,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.fitness_center, size: 28),
            SizedBox(width: 12),
            Text(
              'ابدأ التمارين 💪',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
