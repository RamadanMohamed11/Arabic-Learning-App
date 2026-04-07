import 'dart:math';
import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';

class MathLevel1MatchImagesView extends StatefulWidget {
  const MathLevel1MatchImagesView({super.key});

  @override
  State<MathLevel1MatchImagesView> createState() => _MathLevel1MatchImagesViewState();
}

class _MathLevel1MatchImagesViewState extends State<MathLevel1MatchImagesView> {
  final List<int> _numbers = [1, 2, 3, 4, 5];
  final Map<int, String> _numberLabels = {
    1: '١',
    2: '٢',
    3: '٣',
    4: '٤',
    5: '٥',
  };
  final Map<int, String> _imagePaths = {
    1: 'assets/images/1to5 activity/1.jpeg',
    2: 'assets/images/1to5 activity/2.jpeg',
    3: 'assets/images/1to5 activity/3.jpeg',
    4: 'assets/images/1to5 activity/4.jpeg',
    5: 'assets/images/1to5 activity/5.jpeg',
  };

  late List<int> _shuffledNumbers;
  late List<int> _shuffledImages;
  final Set<int> _matchedNumbers = {};

  @override
  void initState() {
    super.initState();
    _shuffledNumbers = List.from(_numbers)..shuffle(Random());
    _shuffledImages = List.from(_numbers)..shuffle(Random());
    _playIntro();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'صلِ كل رقم بالصورة المناسبة',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  void _onMatch(int number) async {
    setState(() {
      _matchedNumbers.add(number);
    });

    if (_matchedNumbers.length == _numbers.length) {
      await AppTtsService.instance.speak('أحسنت! لقد قمت بتوصيل جميع الأرقام بنجاح.');
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('أحسنت!', textAlign: TextAlign.center),
            content: const Text('لقد قمت بتوصيل جميع الأرقام بشكل صحيح.', textAlign: TextAlign.center),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, 'next'); // Return next to continue to num 6
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.level1[0],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('متابعة', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      AppTtsService.instance.speak('أحسنت');
    }
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
              AppColors.level1[0].withValues(alpha: 0.3),
              AppColors.level1[1].withValues(alpha: 0.3)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Numbers Column (Draggables)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _shuffledNumbers.map((number) {
                            final isMatched = _matchedNumbers.contains(number);
                            return isMatched
                                ? Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 40),
                                  )
                                : Draggable<int>(
                                    data: number,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: _buildNumberCard(number, isDragging: true),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.5,
                                      child: _buildNumberCard(number),
                                    ),
                                    child: _buildNumberCard(number),
                                  );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Images Column (DragTargets)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _shuffledImages.map((number) {
                            final isMatched = _matchedNumbers.contains(number);
                            return DragTarget<int>(
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: candidateData.isNotEmpty
                                          ? AppColors.level1[0]
                                          : (isMatched ? Colors.green : Colors.grey.shade300),
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: isMatched
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Opacity(
                                                opacity: 0.5,
                                                child: Image.asset(
                                                  _imagePaths[number]!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                _numberLabels[number]!,
                                                style: const TextStyle(
                                                    fontSize: 48,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green),
                                              ),
                                            ),
                                          ],
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            _imagePaths[number]!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                );
                              },
                              onWillAcceptWithDetails: (details) {
                                return !isMatched; // Can accept if not matched yet
                              },
                              onAcceptWithDetails: (details) {
                                if (details.data == number) {
                                  _onMatch(number);
                                } else {
                                  AppTtsService.instance.speak('حاول مرة أخرى');
                                }
                              },
                            );
                          }).toList(),
                        ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.level1),
        boxShadow: [
          BoxShadow(
            color: AppColors.level1[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 48), // Spacer
          const Expanded(
            child: Column(
              children: [
                Text(
                  'توصيل الأرقام والصور',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'اسحب الرقم إلى الصورة المناسبة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(int number, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.level1[0], width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.level1[0].withValues(alpha: isDragging ? 0.6 : 0.2),
              blurRadius: isDragging ? 12 : 8,
              offset: isDragging ? const Offset(0, 8) : const Offset(0, 4),
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          _numberLabels[number]!,
          style: TextStyle(
            fontSize: isDragging ? 40 : 36,
            fontWeight: FontWeight.bold,
            color: AppColors.level1[0],
          ),
        ),
      ),
    );
  }
}
