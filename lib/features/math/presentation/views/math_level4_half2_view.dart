import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import '../../../../core/audio/app_tts_service.dart';
import '../../../../core/services/math_progress_service.dart';
import '../../../../core/utils/animated_route.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/math_level4_data.dart';
import 'math_level4_direct_addition_view.dart';
import 'math_level4_matching_view.dart';
import 'math_level4_word_problems_view.dart';
import 'math_level4_speed_challenge_view.dart';

class MathLevel4Half2View extends StatefulWidget {
  const MathLevel4Half2View({super.key});

  @override
  State<MathLevel4Half2View> createState() => _MathLevel4Half2ViewState();
}

class _MathLevel4Half2ViewState extends State<MathLevel4Half2View> {
  MathProgressService? _progressService;
  bool _isLoading = true;
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _playIntroOnce();
  }

  Future<void> _loadProgress() async {
    _progressService = await MathProgressService.getInstance();
    if (_isLoading) {
      _isLoading = false;
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'الآن سنتعلم كيفية جمع الأعداد الكبيرة!',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  bool _isActivityUnlocked(int activityIndex) {
    if (_progressService == null) return false;
    
    // H2 Activity 1 is always unlocked
    if (activityIndex == 1) return true;
    
    // 2 requires 1, etc. using number=2 to represent Half 2 in progress service
    if (activityIndex == 2) {
      return _progressService!.isActivityCompleted(4, 2, 1);
    }
    if (activityIndex == 3) {
      return _progressService!.isActivityCompleted(4, 2, 1) && 
             _progressService!.isActivityCompleted(4, 2, 2);
    }
    if (activityIndex == 4) {
      return _progressService!.isActivityCompleted(4, 2, 1) && 
             _progressService!.isActivityCompleted(4, 2, 2) &&
             _progressService!.isActivityCompleted(4, 2, 3);
    }
    return false;
  }

  bool _isActivityCompleted(int activityIndex) {
    if (_progressService == null) return false;
    return _progressService!.isActivityCompleted(4, 2, activityIndex);
  }

  void _handleActivityTap(int activityIndex) async {
    AppTtsService.instance.stop();
    
    Widget nextView;
    switch (activityIndex) {
      case 1:
        nextView = const MathLevel4DirectAdditionView(isHalf2: true);
        break;
      case 2:
        nextView = const MathLevel4MatchingView();
        break;
      case 3:
        nextView = const MathLevel4WordProblemsView();
        break;
      case 4:
        nextView = const MathLevel4SpeedChallengeView();
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      AnimatedRoute.fadeScale(nextView),
    );
    
    await _loadProgress();
    
    if (_isActivityCompleted(1) && _isActivityCompleted(2) && 
        _isActivityCompleted(3) && _isActivityCompleted(4)) {
      if (!_progressService!.isLevel4Half2Completed) {
        await _progressService!.setLevel4Half2Completed(true);
        if (mounted) {
          _showCompletionDialog();
        }
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('عمل رائع!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary)),
        content: const Text(
          'ألف مبروك! لقد أتممت المستوى الرابع كاملاً وأصبحت بطلاً في الجمع!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // exit to hub
              Navigator.pop(context); // exit hub to levels menu
            },
            child: const Text('العودة للقائمة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'جمع الأعداد الكبيرة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: AppColors.level4,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Introduction Script Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline, size: 40, color: Color(0xFFD4803C)),
                          const SizedBox(height: 10),
                          const Text(
                            'طريقة الحل السهلة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4803C)
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            kPlaceValueScriptText,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    
                    // Activities
                    _buildActivityButton(
                      title: 'جمع الآحاد والعشرات',
                      icon: Icons.add_box,
                      isUnlocked: _isActivityUnlocked(1),
                      isCompleted: _isActivityCompleted(1),
                      onTap: () => _handleActivityTap(1),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityButton(
                      title: 'وصّل الإجابة',
                      icon: Icons.compare_arrows,
                      isUnlocked: _isActivityUnlocked(2),
                      isCompleted: _isActivityCompleted(2),
                      onTap: () => _handleActivityTap(2),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityButton(
                      title: 'مسائل حياتية',
                      icon: Icons.psychology,
                      isUnlocked: _isActivityUnlocked(3),
                      isCompleted: _isActivityCompleted(3),
                      onTap: () => _handleActivityTap(3),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityButton(
                      title: 'تحدي السرعة',
                      icon: Icons.timer,
                      isUnlocked: _isActivityUnlocked(4),
                      isCompleted: _isActivityCompleted(4),
                      onTap: () => _handleActivityTap(4),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActivityButton({
    required String title,
    required IconData icon,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: isCompleted
              ? Border.all(color: Colors.green, width: 3)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.level4.first.withValues(alpha: 0.2)
                    : Colors.grey.shade400,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? icon : Icons.lock,
                  size: 40,
                  color: isUnlocked ? AppColors.level4.last : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
            if (isCompleted)
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.check_circle, color: Colors.green, size: 30),
              )
            else if (isUnlocked)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Icon(Icons.play_circle_fill, color: AppColors.level4.last, size: 30),
              ),
          ],
        ),
      ),
    );
  }
}
