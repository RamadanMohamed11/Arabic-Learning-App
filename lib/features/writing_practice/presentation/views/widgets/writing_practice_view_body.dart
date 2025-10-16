import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:arabic_learning_app/constants.dart';

class WritingPracticeViewBody extends StatefulWidget {
  const WritingPracticeViewBody({super.key});

  @override
  State<WritingPracticeViewBody> createState() =>
      _WritingPracticeViewBodyState();
}

class _WritingPracticeViewBodyState extends State<WritingPracticeViewBody> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  final PageController _pageController = PageController();

  int _currentLetterIndex = 0;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
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
                    return Card(
                      elevation: 8,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade400,
                              Colors.teal.shade600,
                            ],
                          ),
                        ),
                        child: Column(
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
