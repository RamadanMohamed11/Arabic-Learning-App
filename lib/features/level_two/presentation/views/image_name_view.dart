import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/features/level_two/data/models/image_name_model.dart';

class ImageNameView extends StatefulWidget {
  const ImageNameView({super.key});

  @override
  State<ImageNameView> createState() => _ImageNameViewState();
}

class _ImageNameViewState extends State<ImageNameView> {
  int _current = 0;
  int _score = 0;
  bool _complete = false;
  final TextEditingController _ctrl = TextEditingController();
  bool _checked = false;
  bool _lastCorrect = false;
  late final FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
  }

  @override
  void dispose() {
    _tts.stop();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  String _normalize(String s) {
    String t = s.trim();
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    t = t.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '');
    t = t.replaceAll(RegExp(r'[.,!؟?؛:،\-()\[\]{}]'), '');
    t = t.replaceAll(RegExp(r'[\u0622\u0623\u0625\u0671]'), 'ا');
    t = t.replaceAll('ى', 'ي');
    t = t.replaceAll(RegExp(r'ه(?=\s|$)'), 'ة');
    return t;
  }

  bool _isCorrect(String user, ImageNameItem item) {
    final u = _normalize(user);
    final a = _normalize(item.answer);
    if (u == a) return true;
    for (final alt in item.accepted) {
      if (_normalize(alt) == u) return true;
    }
    return false;
  }

  void _onCheck() {
    final item = imageNameItems[_current];
    final correct = _isCorrect(_ctrl.text, item);
    setState(() {
      _checked = true;
      _lastCorrect = correct;
      if (correct) _score++;
    });
    if (correct) {
      FocusScope.of(context).unfocus();
      _speak(item.answer);
    }
  }

  void _next() {
    if (_current < imageNameItems.length - 1) {
      setState(() {
        _current++;
        _ctrl.clear();
        _checked = false;
        _lastCorrect = false;
      });
    } else {
      setState(() => _complete = true);
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _complete = false;
      _ctrl.clear();
      _checked = false;
      _lastCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_complete) return _buildResults();

    final item = imageNameItems[_current];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('النشاط 4: اكتب اسم الصورة', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'السؤال ${_current + 1} من ${imageNameItems.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text('$_score',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (_current + 1) / imageNameItems.length,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      // Image with robust error handling
                      Container(
                        height: 220,
                        width: double.infinity,
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
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    'تعذر تحميل الصورة',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: TextField(
                          controller: _ctrl,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          decoration: const InputDecoration(
                            hintText: 'اكتب اسم الصورة...',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!(_checked && _lastCorrect))
                            ElevatedButton.icon(
                              onPressed: _onCheck,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text('تحقق'),
                            ),
                          if (_checked)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 12.0),
                              child: ElevatedButton.icon(
                                onPressed: _lastCorrect ? _next : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('التالي'),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_checked)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _lastCorrect ? 'أحسنت! إجابة صحيحة.' : 'إجابة غير صحيحة. حاول مرة أخرى.',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _lastCorrect ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final total = imageNameItems.length;
    final percentage = (_score / total * 100).round();
    final isPassed = percentage >= 70;

    return Scaffold(
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
                Text(isPassed ? '🎉' : '💪', style: const TextStyle(fontSize: 80)),
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
                  'نتيجتك: $percentage% ($_score / $total)',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.home, size: 22),
                      label: const Text('الرئيسية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _restart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.refresh, size: 22),
                      label: const Text('إعادة النشاط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
