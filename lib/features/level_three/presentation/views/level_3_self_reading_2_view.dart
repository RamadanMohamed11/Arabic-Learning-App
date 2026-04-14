import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Level3SelfReading2View extends StatefulWidget {
  const Level3SelfReading2View({super.key});

  @override
  State<Level3SelfReading2View> createState() => _Level3SelfReading2ViewState();
}

class _Level3SelfReading2ViewState extends State<Level3SelfReading2View> {
  int _score = 0;
  bool _isCompleted = false;

  // ─── Speech Recognition ──────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isReadingMode = false;
  int _currentSentenceIndex = 0;
  String _recognizedText = '';
  final Map<int, bool?> _sentenceResults = {};

  // ─── بيانات القصة ─────────────────────────────────────────────
  final Map<int, int> _selectedAnswers = {};

  final String title = 'الكلمة الطيبة';
  final String storyText = '''في أحد الأيام، لاحظت منى أن زميلتها الجديدة تجلس وحدها في الفصل ولا تتحدث مع أحد.
كانت تبدو خجولة وحزينة، وبعض الطلاب يتجاهلونها.
فكرت منى قليلًا، ثم قررت أن تذهب إليها وتبتسم وتقول لها كلمة بسيطة: "أهلاً، تحبي تقعدي معايا؟"
تفاجأت البنت بالكلمة اللطيفة، وبدأت تبتسم.
مع مرور الأيام، أصبحت أكثر ثقة بنفسها وبدأت تتكلم وتشارك في الدرس.
أدركت منى أن كلمة صغيرة يمكن أن تغيّر يوم شخص بالكامل، وربما حياته أيضًا.''';

  late final List<String> _sentences;
  final String imagePath = 'assets/images/Arabic/Level3/Activity2/2.jpeg';

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

  @override
  void initState() {
    super.initState();
    _sentences = storyText
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  // ─── Speech Recognition Logic ────────────────────────────────────

  void _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التعرف على الكلام غير متاح على هذا الجهاز'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() { _recognizedText = ''; _isListening = true; });

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() => _recognizedText = result.recognizedWords);
          if (result.finalResult) _checkSentence();
        }
      },
      localeId: 'ar-SA',
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
      ),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_recognizedText.isNotEmpty) _checkSentence();
  }

  void _checkSentence() {
    final expected = _normalizeSentence(_sentences[_currentSentenceIndex]);
    final spoken = _normalizeSentence(_recognizedText);
    final similarity = _calculateSimilarity(expected, spoken);
    final isCorrect = similarity >= 0.5;

    setState(() => _sentenceResults[_currentSentenceIndex] = isCorrect);

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        if (_currentSentenceIndex < _sentences.length - 1) {
          setState(() { _currentSentenceIndex++; _recognizedText = ''; });
        } else {
          setState(() => _isReadingMode = false);
        }
      });
    }
  }

  String _normalizeSentence(String text) {
    final diacritics = RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]');
    String normalized = text.replaceAll(diacritics, '');
    normalized = normalized.replaceAll(RegExp(r'[^\u0600-\u06FF\s]'), '');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final wordsA = a.split(' ').where((w) => w.isNotEmpty).toList();
    final wordsB = b.split(' ').where((w) => w.isNotEmpty).toList();
    if (wordsA.isEmpty) return 0.0;
    int matched = 0;
    for (final wordA in wordsA) {
      for (final wordB in wordsB) {
        if (_wordSimilar(wordA, wordB)) { matched++; break; }
      }
    }
    return matched / wordsA.length;
  }

  bool _wordSimilar(String a, String b) {
    if (a == b) return true;
    if (a.length <= 2 || b.length <= 2) return a == b;
    if (a.contains(b) || b.contains(a)) return true;
    final maxLen = a.length > b.length ? a.length : b.length;
    final dist = _levenshteinDistance(a, b);
    return dist / maxLen <= 0.4;
  }

  int _levenshteinDistance(String s, String t) {
    final n = s.length, m = t.length;
    final d = List.generate(n + 1, (_) => List.filled(m + 1, 0));
    for (int i = 0; i <= n; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= m; j++) {
      d[0][j] = j;
    }
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost].reduce((a, b) => a < b ? a : b);
      }
    }
    return d[n][m];
  }

  // ─── Quiz Logic ──────────────────────────────────────────────────

  void _checkAnswers() {
    if (_selectedAnswers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء الإجابة على جميع الأسئلة'), backgroundColor: Colors.orange),
      );
      return;
    }
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers[i] == questions[i]['correctIndex']) correct++;
    }
    setState(() { _score = correct; _isCompleted = true; });
    if (correct == questions.length) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حصلت على $_score من ${questions.length}. بعض الإجابات تحتاج مراجعة!'), backgroundColor: AppColors.error),
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
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softTeal, foregroundColor: Colors.white,
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

  // ═══════════════════════════════════════════════════════════════════
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
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.softTeal.withValues(alpha: 0.15), AppColors.slateBlue.withValues(alpha: 0.08)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // عنوان القصة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.softTeal, AppColors.slateBlue]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.softTeal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Center(child: Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              const SizedBox(height: 24),

              // بطاقة نص القصة
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: AppColors.softTeal, size: 28),
                        SizedBox(width: 8),
                        Text('اقرأ القصة التالية:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.slateBlue)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.white,
                        child: Image.asset(imagePath, width: double.infinity, height: 200, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isReadingMode
                        ? _buildReadingModeText()
                        : Text(storyText, style: const TextStyle(fontSize: 22, height: 1.8, color: Colors.black87), textAlign: TextAlign.justify),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── زر القراءة بصوتك ──
              if (!_isReadingMode)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _isReadingMode = true; _currentSentenceIndex = 0; _sentenceResults.clear(); _recognizedText = ''; });
                  },
                  icon: const Icon(Icons.mic, size: 24),
                  label: const Text('اقرأ بصوتك 🎙️', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slateBlue, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 4,
                  ),
                ),

              const SizedBox(height: 32),

              // عنوان الأسئلة
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.slateBlue.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.help_outline, color: AppColors.slateBlue),
                ),
                const SizedBox(width: 12),
                const Text('الأسئلة:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.slateBlue)),
              ]),
              const SizedBox(height: 16),

              ...List.generate(questions.length, (i) => _buildQuestionCard(i, questions[i])),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _checkAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softTeal, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 4,
                ),
                child: const Text('التأكد من الإجابات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── عرض النص بوضع القراءة مع ميكروفون مُدمج ──
  Widget _buildReadingModeText() {
    final allDone = _sentenceResults.length == _sentences.length && _sentenceResults.values.every((v) => v == true);
    return Column(
      children: [
        ...List.generate(_sentences.length, (index) {
          final isCurrent = index == _currentSentenceIndex;
          final result = _sentenceResults[index];
          final isCorrect = result == true;
          final isWrong = result == false;
          final isPending = result == null;

          Color bgColor, borderColor;
          if (isCorrect) { bgColor = AppColors.success.withValues(alpha: 0.1); borderColor = AppColors.success; }
          else if (isWrong) { bgColor = AppColors.error.withValues(alpha: 0.1); borderColor = AppColors.error; }
          else if (isCurrent) { bgColor = AppColors.softTeal.withValues(alpha: 0.1); borderColor = AppColors.softTeal; }
          else { bgColor = Colors.transparent; borderColor = Colors.grey.shade300; }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: isCurrent ? 2.5 : 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Icon(
                    isCorrect ? Icons.check_circle : isWrong ? Icons.cancel : isCurrent ? Icons.arrow_forward_ios : Icons.circle_outlined,
                    color: isCorrect ? AppColors.success : isWrong ? AppColors.error : isCurrent ? AppColors.softTeal : Colors.grey.shade400,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_sentences[index], style: TextStyle(fontSize: isCurrent ? 20 : 18, height: 1.8, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isPending && !isCurrent ? Colors.grey.shade500 : Colors.black87))),
                ]),
                if (isCurrent && !allDone) ...[
                  const SizedBox(height: 12),
                  if (_recognizedText.isNotEmpty)
                    Container(
                      width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('ما سمعته:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(_recognizedText, style: const TextStyle(fontSize: 17, color: Colors.black87)),
                      ]),
                    ),
                  if (isWrong)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('حاول مرة أخرى! 💪', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.error, fontWeight: FontWeight.bold)),
                    ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300), width: 56, height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _isListening ? AppColors.error : AppColors.softTeal,
                          boxShadow: [BoxShadow(color: (_isListening ? AppColors.error : AppColors.softTeal).withValues(alpha: 0.4), blurRadius: _isListening ? 18 : 8, spreadRadius: _isListening ? 3 : 0)],
                        ),
                        child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 28),
                      ),
                    ),
                    if (_isListening) ...[
                      const SizedBox(width: 10),
                      Text('🎤 تحدث الآن...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error.withValues(alpha: 0.8))),
                    ],
                  ]),
                ],
              ],
            ),
          );
        }),
        if (allDone)
          Container(
            margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: Column(children: [
              const Icon(Icons.celebration, color: Colors.amber, size: 48),
              const SizedBox(height: 8),
              const Text('أحسنت! قرأت القصة كاملة بشكل صحيح! 🎉', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.softTeal)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => setState(() => _isReadingMode = false), child: const Text('إغلاق القراءة')),
            ]),
          ),
        if (!allDone)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton.icon(
              onPressed: () { _speech.stop(); setState(() { _isReadingMode = false; _isListening = false; }); },
              icon: const Icon(Icons.close), label: const Text('إغلاق القراءة'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionCard(int questionIndex, Map<String, dynamic> q) {
    bool showCorrectIncorrect = _isCompleted;
    int correctIndex = q['correctIndex'];
    int? selectedIndex = _selectedAnswers[questionIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softTeal.withValues(alpha: 0.3), width: 2),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q['question'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ...List.generate(q['options'].length, (optIndex) {
          bool isSelected = selectedIndex == optIndex;
          bool isCorrectOption = correctIndex == optIndex;
          Color getStatusColor() {
            if (!showCorrectIncorrect) return isSelected ? AppColors.softTeal : Colors.grey.shade300;
            if (isCorrectOption) return AppColors.success;
            if (isSelected && !isCorrectOption) return AppColors.error;
            return Colors.grey.shade300;
          }
          return GestureDetector(
            onTap: () { if (!_isCompleted) setState(() => _selectedAnswers[questionIndex] = optIndex); },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? getStatusColor().withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getStatusColor(), width: isSelected || (showCorrectIncorrect && isCorrectOption) ? 2 : 1),
              ),
              child: Row(children: [
                Icon(
                  isSelected ? (showCorrectIncorrect ? (isCorrectOption ? Icons.check_circle : Icons.cancel) : Icons.radio_button_checked)
                      : (showCorrectIncorrect && isCorrectOption ? Icons.check_circle_outline : Icons.radio_button_unchecked),
                  color: getStatusColor(),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(q['options'][optIndex], style: TextStyle(fontSize: 16, color: isSelected ? AppColors.textPrimary : Colors.grey.shade800, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}
