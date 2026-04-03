import 'package:flutter/material.dart';
import 'package:arabic_learning_app/constants.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'dart:math';

class MemoryCard {
  final String id;
  final String content; // حرف أو emoji
  final bool isLetter; // true للحرف، false للصورة
  final String letter; // الحرف المرتبط
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.content,
    required this.isLetter,
    required this.letter,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGameViewBody extends StatefulWidget {
  const MemoryGameViewBody({super.key});

  @override
  State<MemoryGameViewBody> createState() => _MemoryGameViewBodyState();
}

class _MemoryGameViewBodyState extends State<MemoryGameViewBody> {
  List<MemoryCard> cards = [];
  List<MemoryCard> flippedCards = [];
  bool isChecking = false;
  int moves = 0;
  int matches = 0;
  int totalPairs = 6; // عدد الأزواج في اللعبة

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initInstructionTts();
  }

  Future<void> _initInstructionTts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await AppTtsService.instance.speak(
        "لُعْبَةُ الذَّاكِرَةِ، اُنْقُرْ عَلَى الْبِطَاقَاتِ لِتُطَابِقَ كُلَّ حَرْفٍ مَعَ الصُّورَةِ الْمُنَاسِبَةِ لَهُ.",
      );
    }
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  void _initializeGame() {
    cards.clear();
    flippedCards.clear();
    moves = 0;
    matches = 0;
    isChecking = false;

    // اختيار حروف عشوائية
    final random = Random();
    final selectedLetters = <int>[];
    while (selectedLetters.length < totalPairs) {
      final index = random.nextInt(arabicLetters.length);
      if (!selectedLetters.contains(index)) {
        selectedLetters.add(index);
      }
    }

    // إنشاء البطاقات
    for (final index in selectedLetters) {
      final letterData = arabicLetters[index];

      // بطاقة الحرف
      cards.add(
        MemoryCard(
          id: '${letterData.letter}_letter',
          content: letterData.letter,
          isLetter: true,
          letter: letterData.letter,
        ),
      );

      // بطاقة الصورة
      cards.add(
        MemoryCard(
          id: '${letterData.letter}_emoji',
          content: letterData.emoji,
          isLetter: false,
          letter: letterData.letter,
        ),
      );
    }

    // خلط البطاقات
    cards.shuffle();
    setState(() {});
  }

  void _onCardTap(MemoryCard card) {
    if (isChecking ||
        card.isFlipped ||
        card.isMatched ||
        flippedCards.length >= 2) {
      return;
    }

    setState(() {
      card.isFlipped = true;
      flippedCards.add(card);
    });

    if (flippedCards.length == 2) {
      moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    setState(() {
      isChecking = true;
    });

    final card1 = flippedCards[0];
    final card2 = flippedCards[1];

    // التحقق من التطابق
    if (card1.letter == card2.letter && card1.id != card2.id) {
      // تطابق!
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          card1.isMatched = true;
          card2.isMatched = true;
          matches++;
          flippedCards.clear();
          isChecking = false;

          // التحقق من الفوز
          if (matches == totalPairs) {
            _showWinDialog();
          }
        });
      });
    } else {
      // لا يوجد تطابق
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          card1.isFlipped = false;
          card2.isFlipped = false;
          flippedCards.clear();
          isChecking = false;
        });
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉', style: TextStyle(fontSize: 30)),
            SizedBox(width: 8),
            Text('أحسنت!', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Text('🎉', style: TextStyle(fontSize: 30)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'لقد أكملت اللعبة بنجاح!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.swap_horiz, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'عدد المحاولات: $moves',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'الأزواج المتطابقة: $matches',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: const Text(
              'لعب مرة أخرى',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade50, Colors.pink.shade50],
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(3),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🧠', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 12),
                    Text(
                      'لعبة الذاكرة',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('🧠', style: TextStyle(fontSize: 28)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      Icons.swap_horiz,
                      'المحاولات',
                      '$moves',
                      Colors.blue,
                    ),
                    _buildStatCard(
                      Icons.check_circle,
                      'الأزواج',
                      '$matches / $totalPairs',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Game Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return _buildCard(cards[index]);
                },
              ),
            ),
          ),

          // Reset Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _initializeGame();
                });
              },
              icon: const Icon(Icons.refresh, size: 24),
              label: const Text(
                'لعبة جديدة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(MemoryCard card) {
    return GestureDetector(
      onTap: () => _onCardTap(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isMatched
              ? Colors.green.shade100
              : card.isFlipped
              ? Colors.white
              : const Color(0xFF6A1B9A),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: card.isMatched ? Colors.green : Colors.transparent,
            width: 3,
          ),
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Text(
                  card.content,
                  style: TextStyle(
                    fontSize: card.isLetter ? 50 : 60,
                    fontWeight: FontWeight.bold,
                    color: card.isMatched
                        ? Colors.green.shade700
                        : Colors.black87,
                  ),
                )
              : const Icon(Icons.question_mark, size: 50, color: Colors.white),
        ),
      ),
    );
  }
}
