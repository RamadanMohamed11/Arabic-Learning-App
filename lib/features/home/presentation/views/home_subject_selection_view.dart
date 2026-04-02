import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/utils/app_router.dart';

class HomeSubjectSelectionView extends StatefulWidget {
  const HomeSubjectSelectionView({super.key});

  @override
  State<HomeSubjectSelectionView> createState() =>
      _HomeSubjectSelectionViewState();
}

class _HomeSubjectSelectionViewState extends State<HomeSubjectSelectionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _initTts();
  }

  Future<void> _initTts() async {
    await TtsConfig.configure(_flutterTts, speechRate: 0.4, pitch: 1.0);
    // Small delay to let the screen animate in first
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      await _flutterTts.speak(
        'ماذا تريد أن تتعلم اليوم؟ اختر اللغة العربية أو الرياضيات',
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ماذا تريد أن تتعلم اليوم؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A5568),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'اختر المادة التعليمية لتبدأ رحلتك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SubjectCard(
                          title: 'اللغة العربية',
                          subtitle: 'تعلم الحروف، الكلمات، والجمل',
                          iconString: 'أ ب ت',
                          gradientColors: const [
                            Color(0xFF6BA3D8),
                            Color(0xFFA78BFA)
                          ],
                          onTap: () {
                            context.push(AppRouter.kArabicStartRoute);
                          },
                        ),
                        const SizedBox(height: 32),
                        _SubjectCard(
                          title: 'الرياضيات',
                          subtitle: 'تعلم الأرقام، الجمع، والطرح',
                          iconString: '1 + 2',
                          gradientColors: const [
                            Color(0xFF38B2AC),
                            Color(0xFF3182CE)
                          ],
                          onTap: () {
                            context.push(AppRouter.kMathView);
                          },
                        ),
                      ],
                    ),
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

class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconString;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
    required this.subtitle,
    required this.iconString,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Ink(
            padding:
                const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    iconString,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      locale: Locale('ar'),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
