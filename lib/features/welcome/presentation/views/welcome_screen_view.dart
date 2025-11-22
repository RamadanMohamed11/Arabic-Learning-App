import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/core/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class WelcomeScreenView extends StatefulWidget {
  const WelcomeScreenView({super.key});

  @override
  State<WelcomeScreenView> createState() => _WelcomeScreenViewState();
}

class _WelcomeScreenViewState extends State<WelcomeScreenView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showNameInput = false;
  bool _isLoading = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  String? _speechErrorMessage;

  // ألوان هادئة ومريحة للعين - محدثة لتكون أكثر وضوحاً
  static const Color _softPrimary = Color(0xFF6BA3D8); // أزرق أكثر وضوحاً
  static const Color _softSecondary = Color(0xFFA78BFA); // بنفسجي أكثر وضوحاً
  static const Color _softText = Color(0xFF4A5568); // رمادي داكن ناعم

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _initTts();
    _initSpeechToText();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  Future<void> _initTts() async {
    await TtsConfig.configure(_flutterTts, speechRate: 0.35, pitch: 1.1);
  }

  Future<void> _initSpeechToText() async {
    final available = await _speechToText.initialize(
      onStatus: _handleSpeechStatus,
      onError: _handleSpeechError,
    );
    if (mounted) {
      setState(() {
        _speechEnabled = available;
      });
    }
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) return;
    setState(() {
      _isListening = status == 'listening';
    });
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _speechErrorMessage = error.errorMsg;
    });
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeechToText();
      if (!_speechEnabled) return;
    }
    await _speechToText.stop();
    await _flutterTts.stop();
    setState(() {
      _speechErrorMessage = null;
      _isListening = true;
    });
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'ar-SA',
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 4),
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    final recognized = result.recognizedWords.trim();
    if (recognized.isEmpty) {
      return;
    }
    setState(() {
      _nameController.text = recognized;
    });
    if (result.finalResult) {
      _stopListening();
      _flutterTts.speak('تم تسجيل اسمك $recognized');
    }
  }

  void _onStartJourney() {
    setState(() {
      _showNameInput = true;
    });
    _flutterTts.speak('مَا اسْمُكَ؟');
  }

  Future<void> _onContinue() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _flutterTts.speak('مِنْ فَضْلِكَ أَدْخِلْ اسْمَكَ');
      return;
    }

    // إغلاق الكيبورد أولاً لتجنب overflow
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // انتظار قليل لإغلاق الكيبورد
    await Future.delayed(const Duration(milliseconds: 300));

    // حفظ الاسم في التفضيلات
    final progressService = await UserProgressService.getInstance();
    await progressService.saveUserName(name);

    // تشغيل صوت ترحيب شخصي
    await _flutterTts.speak('أَهْلاً $name، سَعِيدٌ بِلِقَائِكَ');

    // انتظار كافي حتى ينتهي الصوت (حوالي 3-4 ثواني للجملة)
    await Future.delayed(const Duration(milliseconds: 4000));

    if (mounted) {
      // الانتقال إلى اختبار تحديد المستوى
      context.go(AppRouter.kPlacementTestView);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // إغلاق الكيبورد عند الضغط في أي مكان
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFAFDFF), // أبيض مزرق فاتح جداً
                Color(0xFFF5F8FF), // أزرق فاتح جداً
                Color(0xFFFFF9F5), // بيج دافئ فاتح
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // شعار/أيقونة
                        _buildLogo(),

                        const SizedBox(height: 40),

                        // رسالة الترحيب
                        _buildWelcomeMessage(),

                        const SizedBox(height: 48),

                        // زر البدء أو إدخال الاسم
                        if (!_showNameInput)
                          _buildStartButton()
                        else
                          _buildNameInput(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _softPrimary.withOpacity(0.3),
            _softSecondary.withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _softPrimary.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Text('📚', style: TextStyle(fontSize: 80)),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'مَرْحَباً بِكَ فِي خُطْوَتِكَ الأُولَى',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: _softText,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'نَحْوَ التَّعَلُّمِ',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [_softPrimary, _softSecondary],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                height: 1.4,
              ),
            ),
            const SizedBox(width: 8),
            const Text('✨', style: TextStyle(fontSize: 32)),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'رِحْلَةٌ مُمْتِعَةٌ لِتَعَلُّمِ اللُّغَةِ العَرَبِيَّةِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: _softText.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_softPrimary, _softSecondary],
        ),
        boxShadow: [
          // تأثير توهج خارجي قوي
          BoxShadow(
            color: _softPrimary.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _softSecondary.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          // ظل إضافي للعمق
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onStartJourney,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ابْدَأْ رِحْلَتَكَ الآنَ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      children: [
        // رسالة السؤال
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _softPrimary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('👋', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'مَا اسْمُكَ؟',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _softText,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // حقل إدخال الاسم
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _softPrimary.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            readOnly: true,
            enableInteractiveSelection: false,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _softText,
            ),
            decoration: InputDecoration(
              hintText: 'اضغط على الميكروفون وقل اسمك',
              hintStyle: TextStyle(
                fontSize: 20,
                color: _softText.withOpacity(0.3),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        _SpeechMicButton(
          isListening: _isListening,
          speechEnabled: _speechEnabled,
          speechErrorMessage: _speechErrorMessage,
          onStartListening: _startListening,
          onStopListening: _stopListening,
        ),

        const SizedBox(height: 24),

        // زر المتابعة
        _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_softPrimary),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_softPrimary, _softSecondary],
                  ),
                  boxShadow: [
                    // تأثير توهج قوي
                    BoxShadow(
                      color: _softPrimary.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: _softSecondary.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 12),
                    ),
                    // ظل للعمق
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onContinue,
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.white.withOpacity(0.3),
                    highlightColor: Colors.white.withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'مُتَابَعَة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

class _SpeechMicButton extends StatelessWidget {
  const _SpeechMicButton({
    required this.isListening,
    required this.speechEnabled,
    required this.onStartListening,
    required this.onStopListening,
    this.speechErrorMessage,
  });

  final bool isListening;
  final bool speechEnabled;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final String? speechErrorMessage;

  @override
  Widget build(BuildContext context) {
    final Color primary = _WelcomeScreenViewState._softPrimary;
    final bool disabled = !speechEnabled && speechErrorMessage != null;

    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            backgroundColor: disabled
                ? Colors.grey.shade400
                : (isListening ? Colors.redAccent : primary),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          onPressed: disabled
              ? null
              : (isListening ? onStopListening : onStartListening),
          icon: Icon(isListening ? Icons.stop : Icons.mic),
          label: Text(
            isListening
                ? 'توقف'
                : (speechEnabled ? 'قل اسمك الآن' : 'فعّل الميكروفون'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _buildStatusMessage(disabled),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: disabled ? Colors.redAccent : primary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _buildStatusMessage(bool disabled) {
    if (speechErrorMessage != null) {
      return speechErrorMessage!;
    }
    if (disabled) {
      return 'تحقق من أذونات الميكروفون لديك.';
    }
    if (isListening) {
      return 'نستمع إليك... قل اسمك بوضوح.';
    }
    if (!speechEnabled) {
      return 'سنطلب إذن الميكروفون عند الضغط على الزر.';
    }
    return 'اضغط على الزر ثم قل اسمك بالعربية.';
  }
}
