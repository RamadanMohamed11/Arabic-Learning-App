import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class MathLevel3ListenWriteView extends StatefulWidget {
  const MathLevel3ListenWriteView({super.key});

  @override
  State<MathLevel3ListenWriteView> createState() => _MathLevel3ListenWriteViewState();
}

class _MathLevel3ListenWriteViewState extends State<MathLevel3ListenWriteView> {
  int _currentIndex = 0;
  bool _showSuccess = false;
  bool _showFailure = false;
  bool _isFinished = false;

  String _currentInput = '';

  final Map<int, String> arabicNumbers = {
    0: '٠', 1: '١', 2: '٢', 3: '٣', 4: '٤', 5: '٥',
    6: '٦', 7: '٧', 8: '٨', 9: '٩'
  };

  String _toArabic(String numberStr) {
    return numberStr.split('').map((char) => arabicNumbers[int.tryParse(char) ?? -1] ?? char).join('');
  }

  final List<Map<String, dynamic>> _questions = [
    {'text': 'خمسة وعشرون', 'correct': '25'},
    {'text': 'سبعة وثلاثون', 'correct': '37'},
    {'text': 'اثنان وأربعون', 'correct': '42'},
    {'text': 'تسعة وخمسين', 'correct': '59'},
    {'text': 'واحد وستون', 'correct': '61'},
    {'text': 'ثلاثة وسبعون', 'correct': '73'},
  ];

  @override
  void initState() {
    super.initState();
    _playIntro();
  }

  Future<void> _playIntro() async {
    await AppTtsService.instance.speakScreenIntro(
      'استمع واكتب الرقم الذي تسمعه',
      isMounted: () => mounted,
    );
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 3), _speakCurrentNumber);
  }

  Future<void> _speakCurrentNumber() async {
    if (!mounted || _isFinished) return;
    await AppTtsService.instance.speak(_questions[_currentIndex]['text']);
  }

  void _onDigitPressed(int digit) {
    if (_showSuccess || _showFailure || _isFinished) return;

    setState(() {
      if (_currentInput.length < 2) {
        _currentInput += digit.toString();
        if (_currentInput.length == 2) {
          _checkAnswer();
        }
      }
    });
  }

  void _onBackspacePressed() {
    if (_showSuccess || _showFailure || _isFinished) return;
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      });
    }
  }

  void _checkAnswer() {
    if (_currentInput == _questions[_currentIndex]['correct']) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
  }

  Future<void> _handleCorrectAnswer() async {
    setState(() {
      _showSuccess = true;
    });

    await AppTtsService.instance.speak('أحسنت إجابة صحيحة');

    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _currentIndex++;
            _currentInput = '';
          });
          _speakCurrentNumber();
        }
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  Future<void> _handleWrongAnswer() async {
    setState(() {
      _showFailure = true;
    });

    await AppTtsService.instance.speak('حاول مرة أخرى');

    if (!mounted) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFailure = false;
          _currentInput = '';
        });
      }
    });
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  Widget _buildKeypad(List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          for (int i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int j = 1; j <= 3; j++)
                    _buildKey(
                      (i * 3 + j).toString(),
                      colors[1],
                      () => _onDigitPressed(i * 3 + j),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKey(
                  'مسح',
                  Colors.red,
                  _onBackspacePressed,
                  isIcon: true,
                  icon: Icons.backspace,
                ),
                _buildKey(
                  '0',
                  colors[1],
                  () => _onDigitPressed(0),
                ),
                const SizedBox(width: 80), // To balance the keypad
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, Color color, VoidCallback onTap, {bool isIcon = false, IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: isIcon && icon != null
              ? Icon(icon, color: color, size: 32)
              : Text(
                  _toArabic(label),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.primaryGradient;

    if (_isFinished) {
      return Scaffold(
        body: Center(
          child: Icon(Icons.check_circle, color: Colors.green, size: 100),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('اسمع واكتب'),
        backgroundColor: colors[0],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'السؤال ${_currentIndex + 1} من ${_questions.length}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors[0]),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _speakCurrentNumber,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.volume_up, size: 80, color: colors[0]),
                ),
              ),
              const SizedBox(height: 40),
              if (_showSuccess)
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 64),
                      SizedBox(height: 16),
                      Text('أحسنت!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                )
              else if (_showFailure)
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 64),
                      SizedBox(height: 16),
                      Text('حاول مرة أخرى', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: colors[0], width: 2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                                BoxShadow(color: colors[0].withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Text(
                            _currentInput.isEmpty ? '?' : _toArabic(_currentInput),
                            style: TextStyle(
                                fontSize: 48, 
                                fontWeight: FontWeight.bold, 
                                color: _currentInput.isEmpty ? Colors.grey : colors[0],
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildKeypad(colors),
                      ],
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
