import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/models/letter_shapes.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/constants.dart';

class LetterShapesView extends StatefulWidget {
  final String letter;

  const LetterShapesView({super.key, required this.letter});

  @override
  State<LetterShapesView> createState() => _LetterShapesViewState();
}

class _LetterShapesViewState extends State<LetterShapesView> {
  final FlutterTts _flutterTts = FlutterTts();
  LetterShapes? letterShapes;
  String exampleWord = '';
  bool _isSpeaking = false;
  UserProgressService? _progressService;
  int _letterIndex = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initProgress();
    letterShapes = ArabicLetterShapes.getShapes(widget.letter);
    // Get the word with tashkeel from arabicLetters list
    final letterData = arabicLetters.firstWhere(
      (l) => l.letter == widget.letter,
      orElse: () => arabicLetters[0],
    );
    exampleWord = letterData.word;

    // الحصول على رقم الحرف
    _letterIndex = arabicLetters.indexWhere((l) => l.letter == widget.letter);
  }

  Future<void> _initProgress() async {
    _progressService = await UserProgressService.getInstance();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    setState(() {
      _isSpeaking = true;
    });
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (letterShapes == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('أشكال الحرف'),
          backgroundColor: const Color(0xFF1A237E),
        ),
        body: const Center(
          child: Text('الحرف غير متوفر', style: TextStyle(fontSize: 24)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'أشكال حرف ${letterShapes!.name}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
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

            // زر إكمال الحرف
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A237E), Colors.indigo.shade700],
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
                onPressed: () => _speak(letterShapes!.isolated),
                icon: Icon(
                  _isSpeaking ? Icons.volume_off : Icons.volume_up,
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
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildShapeCard(
                  'منفصل',
                  letterShapes!.isolated,
                  Colors.blue,
                  Icons.fiber_manual_record,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShapeCard(
                  'أول الكلمة',
                  letterShapes!.initial,
                  Colors.green,
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
                  Colors.orange,
                  Icons.swap_horiz,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShapeCard(
                  'آخر الكلمة',
                  letterShapes!.final_,
                  Colors.purple,
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
      onTap: () => _speak(shape),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
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
            Icon(Icons.volume_up, color: color.withOpacity(0.5), size: 20),
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
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _speak(exampleWord),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade100, Colors.orange.shade100],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
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
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_up,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'اضغط للاستماع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
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

  /// زر إكمال الحرف
  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () async {
          if (_progressService != null) {
            await _progressService!.completeLetter(_letterIndex);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _letterIndex < 27
                        ? 'أحسنت! تم فتح الحرف التالي 🎉'
                        : 'مبروك! أكملت جميع الحروف 🎆',
                    style: const TextStyle(fontSize: 16),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              // العودة للمستوى الأول
              Navigator.pop(context);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 28),
            SizedBox(width: 12),
            Text(
              'أكملت الحرف ✅',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
