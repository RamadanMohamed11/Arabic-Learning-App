import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import '../../../../core/audio/app_tts_service.dart';
import '../../../../core/services/math_progress_service.dart';
import '../../../../core/utils/animated_route.dart';
import 'math_level4_fruit_counting_view.dart';
import 'math_level4_direct_addition_view.dart';
import 'math_level4_number_line_view.dart';

class MathLevel4Half1ActivitiesView extends StatefulWidget {
  const MathLevel4Half1ActivitiesView({super.key});

  @override
  State<MathLevel4Half1ActivitiesView> createState() => _MathLevel4Half1ActivitiesViewState();
}

class _MathLevel4Half1ActivitiesViewState extends State<MathLevel4Half1ActivitiesView> {
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
      'اختر التحدي الذي تريد البدء به.',
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
    return true; // Temporarily return true to unlock all activities for testing
  }

  bool _isActivityCompleted(int activityIndex) {
    if (_progressService == null) return false;
    return _progressService!.isActivityCompleted(4, 1, activityIndex);
  }

  void _handleActivityTap(int activityIndex) async {
    AppTtsService.instance.stop();
    
    Widget nextView;
    switch (activityIndex) {
      case 1:
        nextView = const MathLevel4FruitCountingView();
        break;
      case 2:
        nextView = const MathLevel4DirectAdditionView(isHalf2: false);
        break;
      case 3:
        nextView = const MathLevel4NumberLineView();
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      AnimatedRoute.fadeScale(nextView),
    );
    
    // Check if we should mark Half 1 as complete
    await _loadProgress();
    
    if (_isActivityCompleted(1) && _isActivityCompleted(2) && _isActivityCompleted(3)) {
      if (!_progressService!.isLevel4Half1Completed) {
        await _progressService!.setLevel4Half1Completed(true);
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
        title: Text('أحسنت!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.level4.last)),
        content: const Text(
          'لقد أنهيت الجزء الأول من المستوى الرابع بنجاح! يمكنك الآن جمع الأعداد الأكبر.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.level4.last,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to hub
            },
            child: const Text('موافق', style: TextStyle(color: AppColors.surface)),
          ),
        ],
      ),
    );
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
            'تدريبات الجمع',
            style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0x00000000),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.surface),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                  children: [
                    _buildActivityButton(
                      title: 'عد الفواكه',
                      icon: Icons.apple,
                      isUnlocked: _isActivityUnlocked(1),
                      isCompleted: _isActivityCompleted(1),
                      onTap: () => _handleActivityTap(1),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityButton(
                      title: 'الجمع المباشر',
                      icon: Icons.add_box,
                      isUnlocked: _isActivityUnlocked(2),
                      isCompleted: _isActivityCompleted(2),
                      onTap: () => _handleActivityTap(2),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityButton(
                      title: 'خط الأعداد',
                      icon: Icons.linear_scale,
                      isUnlocked: _isActivityUnlocked(3),
                      isCompleted: _isActivityCompleted(3),
                      onTap: () => _handleActivityTap(3),
                    ),
                  ],
                ),
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
          color: isUnlocked ? AppColors.surface : AppColors.divider,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: isCompleted
              ? Border.all(color: AppColors.success, width: 3)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.level4.first.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? icon : Icons.lock,
                  size: 40,
                  color: isUnlocked ? AppColors.level4.last : AppColors.surface,
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
                  color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            if (isCompleted)
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.check_circle, color: AppColors.success, size: 30),
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
