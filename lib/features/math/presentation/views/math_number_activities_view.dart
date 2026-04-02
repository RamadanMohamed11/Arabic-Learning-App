import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:arabic_learning_app/features/math/data/models/math_number_model.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';
import 'package:arabic_learning_app/features/math/presentation/views/svg_number_tracing_view.dart';

class MathNumberActivitiesView extends StatefulWidget {
  final MathNumberModel numberModel;
  final MathLevelModel levelModel;

  const MathNumberActivitiesView({
    super.key,
    required this.numberModel,
    required this.levelModel,
  });

  @override
  State<MathNumberActivitiesView> createState() =>
      _MathNumberActivitiesViewState();
}

class _MathNumberActivitiesViewState extends State<MathNumberActivitiesView> {
  MathProgressService? _progressService;
  bool _isLoading = true;

  /// Activity definitions.
  /// id 1 (التتبع) is the only implemented activity so far (SVG tracing).
  final List<Map<String, dynamic>> _activities = [
    {
      'id': 0,
      'title': 'التعلم',
      'icon': Icons.menu_book,
      'color': Colors.blue,
      'implemented': false,
    },
    {
      'id': 1,
      'title': 'التتبع',
      'icon': Icons.edit,
      'color': Colors.purple,
      'implemented': true,
    },
    {
      'id': 2,
      'title': 'الاستماع',
      'icon': Icons.headset,
      'color': Colors.orange,
      'implemented': false,
    },
    {
      'id': 3,
      'title': 'العد',
      'icon': Icons.calculate,
      'color': Colors.green,
      'implemented': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await MathProgressService.getInstance();
    if (_isLoading) {
      _initTts();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initTts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      await AppTtsService.instance.speak(
        'الرقم ${widget.numberModel.label}. أكمل جميع الأنشطة للانتقال للرقم التالي',
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Navigate to the appropriate activity screen
  Future<void> _openActivity(Map<String, dynamic> activity) async {
    final activityId = activity['id'] as int;

    if (activityId == 1) {
      // التتبع — SVG Number Tracing (only for numbers 1-10)
      if (widget.numberModel.number >= 1 && widget.numberModel.number <= 10) {
        await Navigator.push(
          context,
          AnimatedRoute.fadeScale(
            SvgNumberTracingView(
              numberModel: widget.numberModel,
              levelModel: widget.levelModel,
            ),
          ),
        );
        // Refresh progress after returning
        _progressService = await MathProgressService.getInstance();
        if (mounted) setState(() {});
      }
    }
    // Other activities not yet implemented
  }

  /// Check if activity is available (implemented and applicable to this number)
  bool _isActivityAvailable(Map<String, dynamic> activity) {
    if (activity['implemented'] != true) return false;

    final activityId = activity['id'] as int;
    if (activityId == 1) {
      // Tracing only available for numbers 1-10 (SVGs exist only for these)
      return widget.numberModel.number >= 1 && widget.numberModel.number <= 10;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('الرقم ${widget.numberModel.label}'),
        backgroundColor: widget.levelModel.level == 1
            ? AppColors.level1[0]
            : widget.levelModel.level == 2
            ? AppColors.level2[0]
            : AppColors.primaryGradient[0],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  final isCompleted = _progressService!.isActivityCompleted(
                    widget.levelModel.level,
                    widget.numberModel.number,
                    activity['id'],
                  );
                  final isAvailable = _isActivityAvailable(activity);

                  return _buildActivityCard(activity, isCompleted, isAvailable);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    Map<String, dynamic> activity,
    bool isCompleted,
    bool isAvailable,
  ) {
    return GestureDetector(
      onTap: isAvailable && !isCompleted
          ? () => _openActivity(activity)
          : isCompleted
          ? () =>
                _openActivity(activity) // allow replay
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 5),
              blurRadius: 10,
            ),
          ],
          border: Border.all(
            color: isCompleted
                ? Colors.green
                : isAvailable
                ? (activity['color'] as Color).withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(activity['icon'], size: 48, color: activity['color']),
            const SizedBox(height: 12),
            Text(
              activity['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isCompleted)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 4),
                  Text('مكتمل', style: TextStyle(color: Colors.green)),
                ],
              )
            else if (isAvailable)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    color: activity['color'],
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ابدأ',
                    style: TextStyle(
                      color: activity['color'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_clock, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('قريباً', style: TextStyle(color: Colors.grey)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
