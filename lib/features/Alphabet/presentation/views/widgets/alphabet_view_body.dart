import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/core/utils/app_router.dart';
import 'package:arabic_learning_app/features/Alphabet/presentation/views/widgets/letter_card.dart';
import 'package:arabic_learning_app/features/Alphabet/presentation/views/letter_shapes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

class AlphabetViewBody extends StatefulWidget {
  const AlphabetViewBody({super.key});

  @override
  State<AlphabetViewBody> createState() => _AlphabetViewBodyState();
}

class _AlphabetViewBodyState extends State<AlphabetViewBody> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ar-EG");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Set completion handler
    flutterTts.setCompletionHandler(() {
      // Re-initialize after completion
      _initTts();
    });
  }

  Future<void> _speak(String text) async {
    // Stop any ongoing speech
    await flutterTts.stop();
    // Re-initialize to ensure it works
    await _initTts();
    // Speak
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'تعلم الحروف العربية',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Letters Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: arabicLetters.length,
                    itemBuilder: (context, index) {
                      return LetterCard(
                        letter: arabicLetters[index],
                        onTap: () {
                          // نطق الحرف عند الضغط على السماعة
                          _speak(
                            '${arabicLetters[index].letter}، ${arabicLetters[index].word}',
                          );
                        },
                        onCardTap: () {
                          // الانتقال لصفحة أشكال الحرف عند الضغط على البطاقة
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LetterShapesView(
                                letter: arabicLetters[index].letter,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              context.push('${AppRouter.kLetterTracingView}?letter=ا');
            },
            backgroundColor: Colors.indigo,
            heroTag: 'letter_tracing',
            icon: const Icon(Icons.gesture, color: Colors.white),
            label: const Text(
              'تتبع الحروف',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () {
              context.push(AppRouter.kWordTrainingView);
            },
            backgroundColor: Colors.purple,
            heroTag: 'word_training',
            icon: const Icon(Icons.volume_up, color: Colors.white),
            label: const Text(
              'تدريب الكلمات',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () {
              context.push(AppRouter.kWritingPracticeView);
            },
            backgroundColor: Colors.teal,
            heroTag: 'writing_practice',
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'تدريب الكتابة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
