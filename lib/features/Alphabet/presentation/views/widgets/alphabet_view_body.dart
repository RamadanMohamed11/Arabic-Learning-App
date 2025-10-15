import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/features/Alphabet/presentation/views/widgets/letter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  }

  Future<void> _speak(String text) async {
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
                          _speak(
                            '${arabicLetters[index].letter}، ${arabicLetters[index].word}',
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
    );
  }
}
