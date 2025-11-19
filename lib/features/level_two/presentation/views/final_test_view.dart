import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/level_two/data/models/final_test_model.dart';

class FinalTestView extends StatefulWidget {
  const FinalTestView({super.key});

  @override
  State<FinalTestView> createState() => _FinalTestViewState();
}

class _FinalTestViewState extends State<FinalTestView> {
  late final FlutterTts _tts;
  late final stt.SpeechToText _stt;
  bool _sttReady = false;
  bool _isListening = false;
  String _spoken = '';
  bool _instructionPlayed = false;

  int _section = 0; // 0=A, 1=B, 2=C
  int _index = 0; // index within current section
  int _score = 0;
  bool _completed = false;

  // UI state
  int? _selectedOption; // for A
  bool _checked = false; // for A and C feedback
  final TextEditingController _dictationCtrl = TextEditingController(); // for C
  List<List<int>> _aOptionOrder = [];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
    _stt = stt.SpeechToText();
    _initStt();
    _initRandomization();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playInstruction());
  }

  Future<void> _initStt() async {
    _sttReady = await _stt.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    if (_isListening) {
      _stt.stop();
    }
    _dictationCtrl.dispose();
    super.dispose();
  }

  int get _total =>
      finalAQuestions.length + finalBQuestions.length + finalCQuestions.length;

  int get _flatIndex {
    if (_section == 0) return _index;
    if (_section == 1) return finalAQuestions.length + _index;
    return finalAQuestions.length + finalBQuestions.length + _index;
  }

  void _next() {
    setState(() {
      _checked = false;
      _selectedOption = null;
      _dictationCtrl.clear();
      _spoken = '';
      if (_isListening) {
        _isListening = false;
        _stt.stop();
      }

      if (_section == 0) {
        if (_index < finalAQuestions.length - 1) {
          _index++;
        } else {
          _section = 1;
          _index = 0;
        }
      } else if (_section == 1) {
        if (_index < finalBQuestions.length - 1) {
          _index++;
        } else {
          _section = 2;
          _index = 0;
        }
      } else {
        if (_index < finalCQuestions.length - 1) {
          _index++;
        } else {
          _completed = true;
        }
      }
    });
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _playInstruction() async {
    if (_instructionPlayed) return;
    _instructionPlayed = true;
    await _tts.stop();
    await _tts.speak(
      'هذا اختبار نهاية المستوى الثاني، استمع للتعليمات في كل قسم وأجب بعناية.',
    );
  }

  void _initRandomization() {
    _aOptionOrder = finalAQuestions
        .map((q) => List<int>.generate(q.options.length, (i) => i)..shuffle())
        .toList();
  }

  Future<void> _startListeningB() async {
    if (!_sttReady) {
      _sttReady = await _stt.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      if (!_sttReady) return;
    }
    setState(() {
      _spoken = '';
      _isListening = true;
      _checked = false;
    });
    await _stt.listen(
      localeId: 'ar_SA',
      onResult: _onSpeechResult,
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 30),
    );
  }

  Future<void> _stopListeningB() async {
    await _stt.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _spoken = result.recognizedWords;
    });
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    if (status == 'notListening' ||
        status == 'done' ||
        status == 'doneNoResult') {
      setState(() => _isListening = false);
    }
  }

  void _onSpeechError(dynamic error) {
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  bool _speechMatches(String recognized, String target) {
    final r = _normalize(recognized);
    final t = _normalize(target);
    if (r.isEmpty) return false;
    if (r == t) return true;
    if (r.contains(t) || t.contains(r)) {
      final ml = r.length > t.length ? t.length : r.length;
      final mr = r.length > t.length ? r.length : t.length;
      if (ml / mr >= 0.8) return true;
    }
    final sim = _similarity(r, t);
    return sim >= 0.78;
  }

  int _levenshtein(String s, String t) {
    final m = s.length;
    final n = t.length;
    if (m == 0) return n;
    if (n == 0) return m;
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return dp[m][n];
  }

  double _similarity(String a, String b) {
    final dist = _levenshtein(a, b);
    final denom = a.length > b.length ? a.length : b.length;
    if (denom == 0) return 1.0;
    return 1.0 - dist / denom;
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) return _buildResults();

    final progress = (_flatIndex + 1) / _total;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🧠 اختبار نهاية المستوى الثاني',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _section == 0
                              ? '🅰 الكلمات'
                              : _section == 1
                              ? '✏ الجمل القصيرة'
                              : '🗣 النطق والكتابة',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection() {
    if (_section == 0) return _buildSectionA();
    if (_section == 1) return _buildSectionB();
    return _buildSectionC();
  }

  // Section A: choose correct word for emoji/image
  Widget _buildSectionA() {
    final q = finalAQuestions[_index];
    final isAnswered = _checked;
    final order = _aOptionOrder[_index];
    final isCorrect =
        isAnswered &&
        _selectedOption != null &&
        order[_selectedOption!] == q.correctIndex;

    return Column(
      children: [
        const SizedBox(height: 12),
        Text(q.prompt, style: const TextStyle(fontSize: 72)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(q.options.length, (i) {
            final selected = _selectedOption == i;
            Color bg;
            Color fg = Colors.white;
            if (!isAnswered) {
              if (selected) {
                bg = AppColors.secondary;
                fg = Colors.white;
              } else {
                bg = Colors.white;
                fg = AppColors.primary;
              }
            } else {
              if (order[i] == q.correctIndex) {
                bg = AppColors.success;
              } else if (selected) {
                bg = AppColors.error;
              } else {
                bg = Colors.grey;
              }
            }
            return ElevatedButton(
              onPressed: isAnswered
                  ? null
                  : () {
                      setState(() {
                        _selectedOption = i;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                side: BorderSide(
                  color: selected && !isAnswered
                      ? AppColors.secondary
                      : AppColors.primary,
                  width: 2,
                ),
                elevation: selected && !isAnswered ? 1 : 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                q.options[order[i]],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!(isAnswered && isCorrect))
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _checked = true;
                    if (_selectedOption != null &&
                        order[_selectedOption!] == q.correctIndex) {
                      _score++;
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('تحقق'),
              ),
            const SizedBox(width: 12),
            if (isAnswered)
              ElevatedButton.icon(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالي'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isAnswered)
          Text(
            isCorrect
                ? 'أحسنت! إجابة صحيحة.'
                : 'الإجابة الصحيحة: ${q.options[q.correctIndex]}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCorrect ? AppColors.success : AppColors.error,
            ),
          ),
      ],
    );
  }

  // Section B: read the text (with TTS option)
  Widget _buildSectionB() {
    final q = finalBQuestions[_index];
    final isAnswered = _checked;
    final ok = isAnswered && _speechMatches(_spoken, q.text);
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '"${q.text}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isListening ? _stopListeningB : _startListeningB,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'إيقاف' : 'تحدّث'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_spoken.isNotEmpty)
          Text(
            _spoken,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!(isAnswered && ok))
              ElevatedButton.icon(
                onPressed: () async {
                  final correct = _speechMatches(_spoken, q.text);
                  await _stopListeningB();
                  setState(() {
                    _checked = true;
                    if (correct) _score++;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('تحقق'),
              ),
            const SizedBox(width: 12),
            if (isAnswered)
              ElevatedButton.icon(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالي'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isAnswered)
          Text(
            ok ? 'أحسنت! نطق صحيح.' : 'حاول مرة أخرى.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ok ? AppColors.success : AppColors.error,
            ),
          ),
      ],
    );
  }

  // Section C: listen then write
  Widget _buildSectionC() {
    final q = finalCQuestions[_index];
    final isAnswered = _checked;
    final ok =
        isAnswered && _normalize(_dictationCtrl.text) == _normalize(q.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _speak(q.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.headphones),
              label: const Text('استمع'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _dictationCtrl,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'اكتب ما سمعت...',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!(isAnswered && ok))
              ElevatedButton.icon(
                onPressed: () {
                  final user = _normalize(_dictationCtrl.text);
                  final target = _normalize(q.text);
                  setState(() {
                    _checked = true;
                    if (user.isNotEmpty && user == target) _score++;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('تحقق'),
              ),
            const SizedBox(width: 12),
            if (isAnswered)
              ElevatedButton.icon(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالي'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (isAnswered)
          Text(
            _normalize(_dictationCtrl.text) == _normalize(q.text)
                ? 'أحسنت! إجابة صحيحة.'
                : 'الإجابة الصحيحة: "${q.text}"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _normalize(_dictationCtrl.text) == _normalize(q.text)
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
      ],
    );
  }

  String _normalize(String s) {
    String t = s.trim();
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    t = t.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'),
      '',
    );
    t = t.replaceAll(RegExp(r'[.,!؟?؛:،\-()\[\]{}]'), '');
    t = t.replaceAll(RegExp(r'[\u0622\u0623\u0625\u0671]'), 'ا');
    t = t.replaceAll('ى', 'ي');
    t = t.replaceAll(RegExp(r'ه(?=\s|$)'), 'ة');
    return t;
  }

  Widget _buildResults() {
    final percentage = (_score / _total * 100).round();
    final isPassed = percentage >= 70;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isPassed
                  ? [AppColors.success, AppColors.success.withOpacity(0.7)]
                  : [AppColors.warning, AppColors.warning.withOpacity(0.7)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    isPassed ? '🎉' : '💪',
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPassed ? 'ممتاز!' : 'أحسنت المحاولة!',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'نتيجتك: $percentage% ($_score / $_total)',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.home, size: 22),
                        label: const Text(
                          'الرئيسية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _section = 0;
                            _index = 0;
                            _score = 0;
                            _completed = false;
                            _checked = false;
                            _selectedOption = null;
                            _dictationCtrl.clear();
                            _spoken = '';
                            _initRandomization();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                        ),
                        icon: const Icon(Icons.refresh, size: 22),
                        label: const Text(
                          'إعادة الاختبار',
                          style: TextStyle(
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
          ),
        ),
      ),
    );
  }
}
