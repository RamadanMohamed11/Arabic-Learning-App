import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
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
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _playIntroOnce();
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'ماذا تريد أن تتعلم اليوم؟ اختر اللغة العربية أو الرياضيات',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.info_outline, color: Color(0xFF4A5568), size: 28),
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              AppTtsService.instance.stop();
              if (value == 'app_info') {
                context.push(AppRouter.kAppInfoView);
              } else if (value == 'team') {
                context.push(AppRouter.kAboutView);
              } else if (value == 'contact') {
                context.push(AppRouter.kContactUsView);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'app_info',
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Color(0xFF4A5568), size: 22),
                    SizedBox(width: 12),
                    Text('معلومات التطبيق', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A5568))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'team',
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, color: Color(0xFF4A5568), size: 22),
                    SizedBox(width: 12),
                    Text('فريق العمل', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A5568))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'contact',
                child: Row(
                  children: [
                    Icon(Icons.contact_support_rounded, color: Color(0xFF4A5568), size: 22),
                    SizedBox(width: 12),
                    Text('تواصل معنا', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A5568))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
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
                    style: TextStyle(fontSize: 18, color: Colors.black54),
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
                            Color(0xFFA78BFA),
                          ],
                          onTap: () {
                            AppTtsService.instance.stop();
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
                            Color(0xFF3182CE),
                          ],
                          onTap: () {
                            AppTtsService.instance.stop();
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
            color: gradientColors[0].withValues(alpha: 0.4),
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
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              vertical: 28.0,
              horizontal: 16.0,
            ),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    iconString,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      locale: Locale('ar'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
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
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
