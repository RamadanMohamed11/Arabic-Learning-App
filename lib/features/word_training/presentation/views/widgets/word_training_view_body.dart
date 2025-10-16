import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/features/word_training/models/word_model.dart';
import 'package:arabic_learning_app/constants.dart';

class WordTrainingViewBody extends StatefulWidget {
  const WordTrainingViewBody({super.key});

  @override
  State<WordTrainingViewBody> createState() => _WordTrainingViewBodyState();
}

class _WordTrainingViewBodyState extends State<WordTrainingViewBody> {
  final FlutterTts _flutterTts = FlutterTts();
  final PageController _pageController = PageController();

  int _currentWordIndex = 0;
  String _userInput = '';
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.black;
  int _correctCount = 0;
  int _attemptCount = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
      });
      // Re-initialize after completion
      _initializeTts();
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isPlaying = false;
      });
      // Re-initialize on error
      _initializeTts();
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playWord() async {
    setState(() {
      _isPlaying = true;
    });

    try {
      // Stop any ongoing speech
      await _flutterTts.stop();
      // Re-initialize to ensure it works
      await _initializeTts();
      // Speak
      final currentWord = trainingWords[_currentWordIndex];
      await _flutterTts.speak(currentWord.audioText);
    } catch (e) {
      print('Error playing word: $e');
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _addLetter(String letter) {
    setState(() {
      _userInput += letter;
      _feedbackMessage = '';
    });
  }

  void _removeLetter() {
    if (_userInput.isNotEmpty) {
      setState(() {
        _userInput = _userInput.substring(0, _userInput.length - 1);
        _feedbackMessage = '';
      });
    }
  }

  void _clearInput() {
    setState(() {
      _userInput = '';
      _feedbackMessage = '';
    });
  }

  Future<void> _checkAnswer() async {
    final currentWord = trainingWords[_currentWordIndex];
    final normalizedInput = _normalizeArabicText(_userInput);
    final normalizedTarget = _normalizeArabicText(currentWord.word);

    setState(() {
      _attemptCount++;

      if (normalizedInput == normalizedTarget) {
        _correctCount++;
        _feedbackMessage = 'ممتاز! ✓\nالكلمة صحيحة';
        _feedbackColor = Colors.green;
      } else {
        _feedbackMessage =
            'حاول مرة أخرى\nكتبت: $_userInput\nالصحيح: ${currentWord.word}';
        _feedbackColor = Colors.red;
      }
    });

    // Play success sound if correct
    if (normalizedInput == normalizedTarget) {
      try {
        await _flutterTts.stop();
        await _initializeTts();
        await _flutterTts.speak('ممتاز');
      } catch (e) {
        print('Error playing success sound: $e');
      }
    }
  }

  String _normalizeArabicText(String text) {
    final Map<String, String> normalizationMap = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'ء': 'ا',
      'ٱ': 'ا',
      'ة': 'ه',
      'ى': 'ي',
    };

    String normalized = text;
    normalizationMap.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    // Remove diacritics
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    normalized = normalized.trim().replaceAll(' ', '');

    return normalized;
  }

  void _nextWord() {
    final nextIndex = (_currentWordIndex + 1) % trainingWords.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousWord() {
    final prevIndex =
        (_currentWordIndex - 1 + trainingWords.length) % trainingWords.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentWordIndex = index;
      _userInput = '';
      _feedbackMessage = '';
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
          colors: [Colors.purple.shade50, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Stats
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
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
                ),
              ),

              const SizedBox(height: 16),

              // Word display with audio
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: trainingWords.length,
                  itemBuilder: (context, index) {
                    final word = trainingWords[index];
                    return Card(
                      elevation: 8,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.purple.shade600,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'استمع واكتب الكلمة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  word.emoji,
                                  style: const TextStyle(fontSize: 60),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton.icon(
                                  onPressed: _isPlaying ? null : _playWord,
                                  icon: Icon(
                                    _isPlaying
                                        ? Icons.volume_up
                                        : Icons.play_arrow,
                                  ),
                                  label: Text(
                                    _isPlaying ? 'يتم التشغيل...' : 'استمع',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.purple,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _previousWord,
                    icon: const Icon(Icons.arrow_back_ios),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentWordIndex + 1} / ${trainingWords.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _nextWord,
                    icon: const Icon(Icons.arrow_forward_ios),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // User input display
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'كتابتك:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userInput.isEmpty ? '...' : _userInput,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _userInput.isEmpty
                              ? Colors.grey.shade300
                              : Colors.purple.shade700,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Feedback
              if (_feedbackMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _feedbackColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _feedbackColor, width: 2),
                  ),
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

              const SizedBox(height: 16),

              // Arabic keyboard
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'اختر الحروف',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: arabicLetters.length,
                            itemBuilder: (context, index) {
                              final letter = arabicLetters[index].letter;
                              return ElevatedButton(
                                onPressed: () => _addLetter(letter),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade100,
                                  foregroundColor: Colors.purple.shade900,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _removeLetter,
                      icon: const Icon(Icons.backspace, size: 20),
                      label: const Text(
                        'مسح حرف',
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
                      onPressed: _clearInput,
                      icon: const Icon(Icons.clear_all, size: 20),
                      label: const Text(
                        'مسح الكل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _userInput.isEmpty ? null : _checkAnswer,
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
                        disabledBackgroundColor: Colors.grey,
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
