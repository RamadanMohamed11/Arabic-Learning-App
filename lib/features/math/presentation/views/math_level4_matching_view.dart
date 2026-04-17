import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import '../../data/math_level4_data.dart';

class MathLevel4MatchingView extends StatefulWidget {
  const MathLevel4MatchingView({super.key});

  @override
  State<MathLevel4MatchingView> createState() => _MathLevel4MatchingViewState();
}

class _MathLevel4MatchingViewState extends State<MathLevel4MatchingView> {
  final int _pairsPerPage = 4;
  int _completedPages = 0;
  final int _totalPages = 3;

  late List<MatchingPair> _currentPairs;
  late List<int> _shuffledAnswers;
  
  int? _selectedEquationIndex;
  final Set<int> _matchedIndices = {};

  @override
  void initState() {
    super.initState();
    _loadNextPage();
    AppTtsService.instance.speakScreenIntro(
      'قم بتوصيل المسألة بالإجابة الصحيحة',
      isMounted: () => mounted,
    );
  }

  void _loadNextPage() {
    setState(() {
      _matchedIndices.clear();
      _selectedEquationIndex = null;
      
      // Get 4 random pairs from the data pool
      final pool = List<MatchingPair>.from(kMatchingPairs)..shuffle();
      _currentPairs = pool.take(_pairsPerPage).toList();
      
      _shuffledAnswers = _currentPairs.map((p) => p.answer).toList()..shuffle();
    });
  }

  Future<void> _handleEquationSelect(int index) async {
    if (_matchedIndices.contains(index)) return;
    
    setState(() {
      _selectedEquationIndex = index;
    });
  }

  Future<void> _handleAnswerSelect(int answerIndex) async {
    if (_selectedEquationIndex == null) return;
    
    final selectedPair = _currentPairs[_selectedEquationIndex!];
    final selectedAnswerValue = _shuffledAnswers[answerIndex];

    if (selectedPair.answer == selectedAnswerValue) {
      await AppTtsService.instance.speak('ممتاز');
      setState(() {
        _matchedIndices.add(_selectedEquationIndex!);
        _selectedEquationIndex = null;
      });
      
      if (_matchedIndices.length == _pairsPerPage) {
        if (!mounted) return;
        _completedPages++;
        
        if (_completedPages >= _totalPages) {
          _handleActivityComplete();
        } else {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) _loadNextPage();
          });
        }
      }
    } else {
      AppTtsService.instance.speak('حاول مرة أخرى');
      setState(() {
        _selectedEquationIndex = null;
      });
    }
  }

  Future<void> _handleActivityComplete() async {
    final progressService = await MathProgressService.getInstance();
    await progressService.completeActivity(4, 2, 2);

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('أحسنت!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.level4.last)),
        content: const Text(
          'لقد أنهيت التدريب بنجاح!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level4.last,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('موافق', style: TextStyle(color: AppColors.surface)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: AppColors.level4,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0x00000000),
        appBar: AppBar(
          title: const Text(
            'وصّل الإجابة',
            style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0x00000000),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.surface),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '${(_completedPages + 1).toString().toArabicDigits()} / ${_totalPages.toString().toArabicDigits()}',
                  style: const TextStyle(fontSize: 24, color: AppColors.surface, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Row(
                    children: [
                      // Equations Column
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_currentPairs.length, (index) {
                            final pair = _currentPairs[index];
                            final isMatched = _matchedIndices.contains(index);
                            final isSelected = _selectedEquationIndex == index;
                            
                            return GestureDetector(
                              onTap: () => _handleEquationSelect(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isMatched 
                                      ? AppColors.lightSlateBlue 
                                      : isSelected 
                                          ? AppColors.level4.first.withValues(alpha: 0.2)
                                          : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isMatched ? const Color(0x00000000) : (isSelected ? AppColors.level4.first : const Color(0x00000000)),
                                    width: 3,
                                  ),
                                  boxShadow: isMatched ? [] : [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${pair.a.toString().toArabicDigits()} + ${pair.b.toString().toArabicDigits()}',
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isMatched ? AppColors.textSecondary : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 30),
                      // Answers Column
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_shuffledAnswers.length, (index) {
                            final answerValue = _shuffledAnswers[index];
                            
                            // Check if this answer is part of an already matched pair
                            bool isAnswerMatched = false;
                            for (int matchedIndex in _matchedIndices) {
                              if (_currentPairs[matchedIndex].answer == answerValue) {
                                isAnswerMatched = true;
                                break;
                              }
                            }
                            
                            return GestureDetector(
                              onTap: () => _handleAnswerSelect(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isAnswerMatched ? AppColors.success : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isAnswerMatched ? [] : [
                                    BoxShadow(
                                      color: AppColors.cardShadow,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    answerValue.toString().toArabicDigits(),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: isAnswerMatched ? AppColors.surface : AppColors.level4.last,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
