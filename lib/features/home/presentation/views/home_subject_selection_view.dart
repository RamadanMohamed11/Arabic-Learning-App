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
  late Animation<Offset> _bottomSlideAnimation;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    
    _bottomSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller, 
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive scale factor: 1.0 for ~700px height, scales down for shorter screens
    final heightScale = (screenHeight / 700.0).clamp(0.65, 1.2);
    final isSmallScreen = screenHeight < 650;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              // Ensure the content fills at least the screen height minus safe areas
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: isSmallScreen ? 16.0 : 24.0 * heightScale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'ماذا تريد أن تتعلم اليوم؟',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 22 : (28 * heightScale).clamp(22.0, 32.0),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A5568),
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Text(
                            'اختر المادة التعليمية لتبدأ رحلتك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : (16 * heightScale).clamp(13.0, 18.0),
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 24 : (40 * heightScale).clamp(24.0, 48.0)),
                          _SubjectCard(
                            title: 'اللغة العربية',
                            subtitle: 'تعلم الحروف، الكلمات، والجمل',
                            iconString: 'أ ب ت',
                            gradientColors: const [
                              Color(0xFF6BA3D8),
                              Color(0xFFA78BFA),
                            ],
                            isSmallScreen: isSmallScreen,
                            heightScale: heightScale,
                            onTap: () {
                              AppTtsService.instance.stop();
                              context.push(AppRouter.kArabicStartRoute);
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 16 : (28 * heightScale).clamp(16.0, 32.0)),
                          _SubjectCard(
                            title: 'الرياضيات',
                            subtitle: 'تعلم الأرقام، الجمع، والطرح',
                            iconString: '1 + 2',
                            gradientColors: const [
                              Color(0xFF38B2AC),
                              Color(0xFF3182CE),
                            ],
                            isSmallScreen: isSmallScreen,
                            heightScale: heightScale,
                            onTap: () {
                              AppTtsService.instance.stop();
                              context.push(AppRouter.kMathView);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 24 : (40 * heightScale).clamp(24.0, 48.0)),
                    
                    // Info Row Section
                    SlideTransition(
                      position: _bottomSlideAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 16 : 24, 
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _InfoIconItem(
                              icon: Icons.info_rounded,
                              title: 'التطبيق',
                              color: const Color(0xFFF6AD55), // Warm orange
                              isSmallScreen: isSmallScreen,
                              onTap: () {
                                AppTtsService.instance.stop();
                                context.push(AppRouter.kAppInfoView);
                              },
                            ),
                            _InfoIconItem(
                              icon: Icons.groups_rounded,
                              title: 'الفريق',
                              color: const Color(0xFF4FD1C5), // Teal/Cyan
                              isSmallScreen: isSmallScreen,
                              onTap: () {
                                AppTtsService.instance.stop();
                                context.push(AppRouter.kAboutView);
                              },
                            ),
                            _InfoIconItem(
                              icon: Icons.headset_mic_rounded,
                              title: 'تواصل معنا',
                              color: const Color(0xFFF687B3), // Soft pink
                              isSmallScreen: isSmallScreen,
                              onTap: () {
                                AppTtsService.instance.stop();
                                context.push(AppRouter.kContactUsView);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoIconItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _InfoIconItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashColor: color.withValues(alpha: 0.2),
              highlightColor: color.withValues(alpha: 0.1),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconString;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isSmallScreen;
  final double heightScale;

  const _SubjectCard({
    required this.title,
    required this.subtitle,
    required this.iconString,
    required this.gradientColors,
    required this.onTap,
    required this.isSmallScreen,
    required this.heightScale,
  });

  @override
  Widget build(BuildContext context) {
    final double cardVerticalPadding = isSmallScreen
        ? 20.0
        : (36.0 * heightScale).clamp(20.0, 44.0);
    final double iconFontSize = isSmallScreen
        ? 22.0
        : (28.0 * heightScale).clamp(20.0, 34.0);
    final double titleFontSize = isSmallScreen
        ? 20.0
        : (24.0 * heightScale).clamp(18.0, 28.0);
    final double subtitleFontSize = isSmallScreen
        ? 13.0
        : (15.0 * heightScale).clamp(12.0, 17.0);
    final double iconContainerPadding = isSmallScreen ? 12.0 : 16.0;
    final double iconSpacing = isSmallScreen ? 12.0 : 20.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withValues(alpha: 0.3),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Ink(
            padding: EdgeInsets.symmetric(
              vertical: cardVerticalPadding,
              horizontal: 20.0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconContainerPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    iconString,
                    style: TextStyle(
                      fontSize: iconFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      locale: const Locale('ar'),
                    ),
                  ),
                ),
                SizedBox(width: iconSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

