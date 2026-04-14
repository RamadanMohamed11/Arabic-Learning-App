import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel1TestWriteNumbersView extends StatefulWidget {
  final int part; // 1 for 1..5, 2 for 6..10

  const MathLevel1TestWriteNumbersView({super.key, required this.part});

  @override
  State<MathLevel1TestWriteNumbersView> createState() =>
      _MathLevel1TestWriteNumbersViewState();
}

class _MathLevel1TestWriteNumbersViewState
    extends State<MathLevel1TestWriteNumbersView> {

  // Test data based on provided folders
  late List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  bool _showSuccess = false;
  bool _isFinished = false;
  String _currentInput = "";

  @override
  void initState() {
    super.initState();
    if (widget.part == 1) {
      _questions = [
        {'image': 'assets/images/1to5 activity/2/1.jpeg', 'answer': 1},
        {'image': 'assets/images/1to5 activity/2/3.jpeg', 'answer': 3},
        {'image': 'assets/images/1to5 activity/2/5.jpeg', 'answer': 5},
      ];
    } else {
      _questions = [
        {'image': 'assets/images/6to10 activity/2/7.jpeg', 'answer': 7},
        {'image': 'assets/images/6to10 activity/2/8.jpeg', 'answer': 8},
        {'image': 'assets/images/6to10 activity/2/10.jpeg', 'answer': 10},
      ];
    }
    _playIntro();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'عُدَّ الأشياءَ واكْتُب الرَّقَمَ الصَّحِيح',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  void _onNumberPressed(int number) {
    if (_showSuccess || _isFinished) return;

    if (number == _questions[_currentIndex]['answer']) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
  }

  Future<void> _handleCorrectAnswer() async {
    setState(() {
      _showSuccess = true;
      _currentInput = _questions[_currentIndex]['answer'].toString();
    });

    await AppTtsService.instance.speak('أحسنت إجابة صحيحة');

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _currentInput = "";
            _currentIndex++;
          });
        }
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context, 'next'); // Return to selection view
        }
      });
    }
  }

  Future<void> _handleWrongAnswer() async {
    setState(() {
      _currentInput = "❌";
    });
    await AppTtsService.instance.speak('حاول مرة أخرى');
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _currentInput == "❌") {
        setState(() {
          _currentInput = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.part == 1 ? AppColors.level1 : AppColors.level2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('عد واكتب الرقم'),
        backgroundColor: colors[0],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors[0].withValues(alpha: 0.2),
                  colors[1].withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          if (_isFinished)
            Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
            )
          else
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'السؤال ${_currentIndex + 1} من ${_questions.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors[0],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Image
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          _questions[_currentIndex]['image'],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Input display
                  Container(
                    width: 120,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _showSuccess ? Colors.green : colors[0],
                        width: 3,
                      ),
                    ),
                    child: Text(
                      _currentInput,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _showSuccess ? Colors.green : colors[0],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Custom Number Keypad
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          // Display 1-5 for part 1, 6-10 for part 2
                          int number = widget.part == 1 ? index + 1 : index + 6;
                          if (number > 10) return const SizedBox.shrink(); // Hide if > 10
                          return _buildKeypadButton(number, colors[0]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(int number, Color baseColor) {
    final Map<int, String> arabicNumbers = {
      1: '١', 2: '٢', 3: '٣', 4: '٤', 5: '٥',
      6: '٦', 7: '٧', 8: '٨', 9: '٩', 10: '١٠'
    };
    
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: baseColor.withValues(alpha: 0.5), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          arabicNumbers[number] ?? '$number',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: baseColor,
          ),
        ),
      ),
    );
  }
}
