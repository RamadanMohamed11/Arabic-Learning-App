import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class Level3SelfReading2View extends StatefulWidget {
  const Level3SelfReading2View({super.key});

  @override
  State<Level3SelfReading2View> createState() => _Level3SelfReading2ViewState();
}

class _Level3SelfReading2ViewState extends State<Level3SelfReading2View> {
  bool _hasPlayedIntro = false;
  int _score = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _playIntroOnce();
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'اقرأ القصة ثم أجب عن الأسئلة.',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }
  
  // State for answered questions: index -> selected option index
  final Map<int, int> _selectedAnswers = {};
  
  final String title = 'الكلمة الطيبة';
  final String storyText = '''في أحد الأيام، لاحظت منى أن زميلتها الجديدة تجلس وحدها في الفصل ولا تتحدث مع أحد.
كانت تبدو خجولة وحزينة، وبعض الطلاب يتجاهلونها.
فكرت منى قليلًا، ثم قررت أن تذهب إليها وتبتسم وتقول لها كلمة بسيطة: "أهلاً، تحبي تقعدي معايا؟"

تفاجأت البنت بالكلمة اللطيفة، وبدأت تبتسم.
مع مرور الأيام، أصبحت أكثر ثقة بنفسها وبدأت تتكلم وتشارك في الدرس.
أدركت منى أن كلمة صغيرة يمكن أن تغيّر يوم شخص بالكامل، وربما حياته أيضًا.''';

  final List<Map<String, dynamic>> questions = [
    {
      'question': '1. لماذا كانت زميلة منى تجلس وحدها؟',
      'options': ['(أ) لأنها لا تحب الناس', '(ب) لأنها خجولة وحزينة', '(ج) لأنها مشغولة'],
      'correctIndex': 1,
    },
    {
      'question': '2. ماذا فعلت منى؟',
      'options': ['(أ) تجاهلتها', '(ب) ضحكت عليها', '(ج) تحدثت معها بلطف'],
      'correctIndex': 2,
    },
    {
      'question': '3. ماذا حدث بعد ذلك؟',
      'options': ['(أ) ظلت البنت كما هي', '(ب) أصبحت أكثر ثقة وسعادة', '(ج) تركت المدرسة'],
      'correctIndex': 1,
    },
    {
      'question': '4. ماذا نتعلم من القصة؟',
      'options': ['(أ) نتجاهل الآخرين', '(ب) الكلمة الطيبة تؤثر في الناس', '(ج) لا نتحدث مع أحد'],
      'correctIndex': 1,
    },
  ];

  void _checkAnswers() {
    if (_selectedAnswers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء الإجابة على جميع الأسئلة'), backgroundColor: Colors.orange),
      );
      return;
    }

    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers[i] == questions[i]['correctIndex']) {
        correct++;
      }
    }

    setState(() {
      _score = correct;
      _isCompleted = true;
    });

    if (correct == questions.length) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حصلت على $_score من ${questions.length}. بعض الإجابات تحتاج مراجعة!'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('أحسنت!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.softTeal, fontWeight: FontWeight.bold, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 80),
            const SizedBox(height: 16),
            const Text('لقد أجبت عن جميع الأسئلة بشكل صحيح.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('المتابعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اقرأ بنفسك', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.softTeal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.softTeal.withValues(alpha: 0.15),
              AppColors.slateBlue.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Title Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.softTeal, AppColors.slateBlue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.softTeal.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Story Text Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: AppColors.softTeal, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'اقرأ القصة التالية:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slateBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.white,
                        child: Image.asset(
                          'assets/images/Arabic/Level3/Activity2/2.jpeg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      storyText,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Questions Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.slateBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.help_outline, color: AppColors.slateBlue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'الأسئلة:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slateBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Questions List
              ...List.generate(questions.length, (index) {
                final q = questions[index];
                return _buildQuestionCard(index, q);
              }),
              
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _checkAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'التأكد من الإجابات',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int questionIndex, Map<String, dynamic> q) {
    bool showCorrectIncorrect = _isCompleted;
    int correctIndex = q['correctIndex'];
    int? selectedIndex = _selectedAnswers[questionIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.softTeal.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q['question'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(q['options'].length, (optIndex) {
            bool isSelected = selectedIndex == optIndex;
            bool isCorrectOption = correctIndex == optIndex;
            
            Color getStatusColor() {
              if (!showCorrectIncorrect) {
                return isSelected ? AppColors.softTeal : Colors.grey.shade300;
              }
              if (isCorrectOption) return AppColors.success;
              if (isSelected && !isCorrectOption) return AppColors.error;
              return Colors.grey.shade300;
            }

            return GestureDetector(
              onTap: () {
                if (!_isCompleted) {
                  setState(() {
                    _selectedAnswers[questionIndex] = optIndex;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? getStatusColor().withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: getStatusColor(),
                    width: isSelected || (showCorrectIncorrect && isCorrectOption) ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected 
                          ? (showCorrectIncorrect 
                                ? (isCorrectOption ? Icons.check_circle : Icons.cancel)
                                : Icons.radio_button_checked)
                          : (showCorrectIncorrect && isCorrectOption
                                ? Icons.check_circle_outline
                                : Icons.radio_button_unchecked),
                      color: getStatusColor(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        q['options'][optIndex],
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? AppColors.textPrimary : Colors.grey.shade800,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
