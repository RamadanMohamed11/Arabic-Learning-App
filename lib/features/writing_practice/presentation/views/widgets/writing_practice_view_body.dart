import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:path_provider/path_provider.dart';
import 'package:arabic_learning_app/constants.dart';

class WritingPracticeViewBody extends StatefulWidget {
  const WritingPracticeViewBody({super.key});

  @override
  State<WritingPracticeViewBody> createState() =>
      _WritingPracticeViewBodyState();
}

class _WritingPracticeViewBodyState extends State<WritingPracticeViewBody> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final PageController _pageController = PageController();
  late Gemini _gemini;

  int _currentLetterIndex = 0;
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.black;
  bool _isRecognizing = false;
  int _correctCount = 0;
  int _attemptCount = 0;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    // Initialize Gemini
    _gemini = Gemini.instance;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureSignatureAsImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Capture at high resolution for better recognition
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('DEBUG: Error capturing image: $e');
      return null;
    }
  }



  Future<void> _recognizeDrawing() async {
    setState(() {
      _isRecognizing = true;
      _feedbackMessage = 'جاري التحقق...';
      _feedbackColor = Colors.blue;
      _attemptCount++;
    });

    try {
      // Step 1: Capture the signature pad as an image
      final imageBytes = await _captureSignatureAsImage();
      if (imageBytes == null) {
        setState(() {
          _feedbackMessage = 'خطأ في التقاط الصورة';
          _feedbackColor = Colors.red;
          _isRecognizing = false;
        });
        return;
      }

      print('DEBUG: Captured image size: ${imageBytes.length} bytes');

      // Step 2: Save image to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/letter_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(imageBytes);
      print('DEBUG: Saved temp file: ${tempFile.path}');

      // Step 3: Get current letter
      final currentLetter = arabicLetters[_currentLetterIndex].letter;
      print('DEBUG: Target letter: $currentLetter');

      // Step 4: Ask Gemini to validate the image
      final promptText = "هل الحرف في هذه الصورة هو الحرف العربي '$currentLetter'؟ أجب بكلمة 'نعم' أو 'لا' فقط بدون أي مقدمات أو شرح إضافي.";

      // Use text and image with Gemini (auto-selects vision model)
      String geminiAnswer = '';
      try {
        final response = await _gemini.textAndImage(
          text: promptText,
          images: [imageBytes],
        );
        
        geminiAnswer = response?.content?.parts?.last.text?.trim().toLowerCase() ?? '';
        print('DEBUG: Raw Gemini response: $geminiAnswer');
      } catch (e) {
        print('DEBUG: Gemini API error: $e');
        setState(() {
          _feedbackMessage = 'حدث خطأ في الشبكة\nتحقق من الاتصال بالإنترنت\n\nالخطأ: ${e.toString().substring(0, 50)}';
          _feedbackColor = Colors.orange;
          _isRecognizing = false;
        });
        return;
      }

      // Clean up temp file
      try {
        await tempFile.delete();
      } catch (e) {
        print('DEBUG: Could not delete temp file: $e');
      }

      // Step 5: Parse Gemini response
      geminiAnswer = geminiAnswer.trim().toLowerCase();
      print('DEBUG: Gemini response: "$geminiAnswer"');

      final isCorrect = geminiAnswer.contains('yes') || geminiAnswer.contains('نعم');

      setState(() {
        if (isCorrect) {
          _correctCount++;
          _feedbackMessage = 'ممتاز! ✓\nالحرف صحيح: $currentLetter';
          _feedbackColor = Colors.green;
        } else {
          _feedbackMessage = 'حاول مرة أخرى!\nالمطلوب: $currentLetter\n\nنصائح:\n• اكتب أكبر\n• اكتب بوضوح\n• تأكد من شكل الحرف';
          _feedbackColor = Colors.orange;
        }
        _isRecognizing = false;
      });
    } catch (e) {
      print('DEBUG: Recognition error: $e');
      setState(() {
        _feedbackMessage = 'خطأ في التعرف:\n${e.toString().substring(0, 100)}';
        _feedbackColor = Colors.red;
        _isRecognizing = false;
      });
    }
  }


  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
    setState(() {
      _feedbackMessage = '';
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
    final accuracy = _attemptCount > 0
        ? ((_correctCount / _attemptCount) * 100).toStringAsFixed(0)
        : '0';

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
              // Stats and tips
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            Icons.check_circle,
                            'صحيح',
                            '$_correctCount',
                            Colors.green,
                          ),
                          _buildStat(
                            Icons.edit,
                            'محاولات',
                            '$_attemptCount',
                            Colors.blue,
                          ),
                          _buildStat(
                            Icons.percent,
                            'دقة',
                            '$accuracy%',
                            Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'نصيحة: اكتب كبيراً وواضحاً في منتصف المربع',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

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
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
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
              ),

              const SizedBox(height: 12),

              // Feedback
              if (_feedbackMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _feedbackColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _feedbackColor, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRecognizing)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _feedbackColor,
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          _feedbackMessage,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _feedbackColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                      onPressed: _recognizeDrawing,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text(
                        'تحقق',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
