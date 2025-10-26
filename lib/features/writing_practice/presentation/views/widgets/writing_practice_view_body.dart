import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/automated_letter_trace_screen.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

class WritingPracticeViewBody extends StatefulWidget {
  const WritingPracticeViewBody({super.key});

  @override
  State<WritingPracticeViewBody> createState() =>
      _WritingPracticeViewBodyState();
}

class _WritingPracticeViewBodyState extends State<WritingPracticeViewBody> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  final PageController _pageController = PageController();
  UserProgressService? _progressService;

  int _currentLetterIndex = 0;
  bool _showHint = false;
  List<int> _unlockedLetters = [0];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await UserProgressService.getInstance();
    
    setState(() {
      _unlockedLetters = _progressService!.getUnlockedLetters();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }



  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
    setState(() {
      _showHint = false;
    });
  }

  void _nextLetter() {
    final nextIndex = (_currentLetterIndex + 1) % arabicLetters.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousLetter() {
    final prevIndex =
        (_currentLetterIndex - 1 + arabicLetters.length) % arabicLetters.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentLetterIndex = index;
    });
    _clearSignature();
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  void _startTracingPractice() async {
    if (_progressService == null) return;
    
    final currentLetter = arabicLetters[_currentLetterIndex];
    
    // Check if letter is unlocked
    final isUnlocked = _unlockedLetters.contains(_currentLetterIndex);
    if (!isUnlocked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('أكمل الحرف السابق أولاً!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    const int tracingActivityIndex = 0; // Activity 0 = Tracing Exercise
    
    // Navigate to tracing screen
    if (mounted) {
      await Navigator.push(
        context,
        AnimatedRoute.slideScale(
          AutomatedLetterTraceScreen(
            svgAssetPath: 'assets/svg/${currentLetter.letter}.svg',
            letterIndex: _currentLetterIndex,
            onComplete: () async {
              // Mark tracing activity as completed
              await _progressService!.completeActivity(
                _currentLetterIndex,
                tracingActivityIndex,
              );
              
              // Check if all activities for this letter are completed
              // For now, we only have 1 activity (tracing), so complete the letter
              await _progressService!.completeLetter(_currentLetterIndex);
              
              // Reload progress
              await _loadProgress();
              
              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('أحسنت! لقد أكملت حرف ${currentLetter.letter}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
      );
      
      // Reload progress after returning from tracing screen
      await _loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade50, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Letter display
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: arabicLetters.length,
                  itemBuilder: (context, index) {
                    final letter = arabicLetters[index];
                    // Check if tracing activity (activity 0) is completed for this letter
                    final isCompleted = _progressService?.isActivityCompleted(index, 0) ?? false;
                    final isLocked = !_unlockedLetters.contains(index);
                    
                    return Card(
                      elevation: 8,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: isLocked
                                ? [Colors.grey.shade400, Colors.grey.shade600]
                                : isCompleted
                                    ? [Colors.green.shade400, Colors.green.shade600]
                                    : [Colors.teal.shade400, Colors.teal.shade600],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'اكتب الحرف',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      letter.letter,
                                      style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      letter.emoji,
                                      style: const TextStyle(fontSize: 45),
                                    ),
                                  ],
                                ),
                                Text(
                                  letter.word,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            // Lock or completion indicator
                            if (isLocked)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                              ),
                            if (isCompleted && !isLocked)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _previousLetter,
                    icon: const Icon(Icons.arrow_back_ios),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.teal.shade100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentLetterIndex + 1} / ${arabicLetters.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _nextLetter,
                    icon: const Icon(Icons.arrow_forward_ios),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.teal.shade100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Tracing Practice Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Builder(
                  builder: (context) {
                    final isCompleted = _progressService?.isActivityCompleted(
                      _currentLetterIndex,
                      0, // Tracing activity
                    ) ?? false;
                    final isLocked = !_unlockedLetters.contains(_currentLetterIndex);
                    
                    return ElevatedButton.icon(
                      onPressed: isLocked ? null : _startTracingPractice,
                      icon: Icon(
                        isCompleted ? Icons.check_circle : Icons.draw,
                        size: 24,
                      ),
                      label: Text(
                        isCompleted ? 'تم إكمال التمرين ✓' : 'تدريب تتبع الحرف',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLocked
                            ? Colors.grey
                            : isCompleted
                                ? Colors.green
                                : Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Signature pad with guidance overlay
              Expanded(
                child: Card(
                  elevation: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          // White background
                          Container(color: Colors.white),

                            // Guidance frame
                            Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.teal.withOpacity(0.3),
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'اكتب هنا',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.teal.withOpacity(0.3),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Hint overlay
                            if (_showHint)
                              Center(
                                child: Opacity(
                                  opacity: 0.15,
                                  child: Text(
                                    arabicLetters[_currentLetterIndex].letter,
                                    style: TextStyle(
                                      fontSize: 180,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                ),
                              ),

                          // Signature pad
                          SfSignaturePad(
                            key: _signaturePadKey,
                            backgroundColor: Colors.transparent,
                            strokeColor: Colors.black,
                            minimumStrokeWidth: 20,
                            maximumStrokeWidth: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleHint,
                      icon: Icon(
                        _showHint ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      label: Text(
                        _showHint ? 'إخفاء' : 'مساعدة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearSignature,
                      icon: const Icon(Icons.clear, size: 20),
                      label: const Text(
                        'مسح',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextLetter,
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      label: const Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
