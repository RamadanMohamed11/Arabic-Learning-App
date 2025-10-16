import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:arabic_learning_app/features/letter_tracing/data/simple_svg_letter_paths.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SimpleSvgLetterView extends StatefulWidget {
  final String letter;

  const SimpleSvgLetterView({
    super.key,
    required this.letter,
  });

  @override
  State<SimpleSvgLetterView> createState() => _SimpleSvgLetterViewState();
}

class _SimpleSvgLetterViewState extends State<SimpleSvgLetterView> {
  // بيانات الحرف من SVG
  SimpleSvgLetterPath? letterPath;
  bool isLoading = true;

  // TTS
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadLetterPath();
    _initTts();
  }

  Future<void> _loadLetterPath() async {
    final path = await SimpleSvgLetterPathManager.getPath(widget.letter);
    setState(() {
      letterPath = path;
      isLoading = false;
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  /// الحصول على الحرف التالي
  String _getNextLetter() {
    final currentIndex = arabicLetters.indexWhere((l) => l.letter == widget.letter);
    if (currentIndex >= arabicLetters.length - 1) {
      return arabicLetters.first.letter;
    }
    return arabicLetters[currentIndex + 1].letter;
  }

  /// الحصول على الحرف السابق
  String? _getPreviousLetter() {
    final currentIndex = arabicLetters.indexWhere((l) => l.letter == widget.letter);
    if (currentIndex <= 0) {
      return null;
    }
    return arabicLetters[currentIndex - 1].letter;
  }

  /// الانتقال للحرف التالي
  void _goToNextLetter() {
    final nextLetter = _getNextLetter();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleSvgLetterView(letter: nextLetter),
      ),
    );
  }

  /// الانتقال للحرف السابق
  void _goToPreviousLetter() {
    final previousLetter = _getPreviousLetter();
    if (previousLetter != null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SimpleSvgLetterView(letter: previousLetter),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('تتبع حرف ${widget.letter}'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (letterPath == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('تتبع حرف ${widget.letter}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'الحرف غير متوفر',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                'حرف: ${widget.letter}',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('رجوع'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('تتبع حرف ${widget.letter}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_getPreviousLetter() != null)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goToPreviousLetter,
              tooltip: 'الحرف السابق',
            ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speak('حرف ${widget.letter}'),
            tooltip: 'نطق الحرف',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _goToNextLetter,
            tooltip: 'الحرف التالي',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // التعليمات
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 30, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تتبع الحرف بإصبعك على الشاشة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // عرض SVG
            Expanded(
              child: Center(
                child: Container(
                  width: 350,
                  height: 450,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SvgPicture.string(
                      letterPath!.svgContent,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // أزرار التحكم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _speak('حرف ${widget.letter}'),
                    icon: const Icon(Icons.volume_up),
                    label: const Text(
                      'نطق',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _goToNextLetter,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'التالي',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
