import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/Alphabet/presentation/views/widgets/letter_card.dart';
import 'package:arabic_learning_app/features/Alphabet/presentation/views/letter_shapes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';

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
    await TtsConfig.configure(flutterTts, language: 'ar-EG', speechRate: 0.5);
    flutterTts.setCompletionHandler(() {});
  }

  Future<void> _speak(String text) async {
    // Stop any ongoing speech
    await flutterTts.stop();
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📚', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Text(
                    'تعلم الحروف العربية',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('📚', style: TextStyle(fontSize: 28)),
                ],
              ),
            ),

            // Letters Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          AnimatedRoute.slideRight(
                            LetterShapesView(
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
    );
  }
}
