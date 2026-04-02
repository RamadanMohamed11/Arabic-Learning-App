import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/models/math_number_model.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';

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
  final FlutterTts _flutterTts = FlutterTts();

  final List<Map<String, dynamic>> _activities = [
    {'id': 0, 'title': 'التعلم', 'icon': Icons.menu_book, 'color': Colors.blue},
    {'id': 1, 'title': 'التتبع', 'icon': Icons.edit, 'color': Colors.purple},
    {
      'id': 2,
      'title': 'الاستماع',
      'icon': Icons.headset,
      'color': Colors.orange,
    },
    {'id': 3, 'title': 'العد', 'icon': Icons.calculate, 'color': Colors.green},
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
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initTts() async {
    await TtsConfig.configure(_flutterTts, speechRate: 0.4, pitch: 1.0);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      await _flutterTts.speak(
        'الرقم ${widget.numberModel.label}. أكمل جميع الأنشطة للانتقال للرقم التالي',
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _completeActivity(int activityId) async {
    if (_progressService == null) return;

    await _progressService!.completeActivity(
      widget.levelModel.level,
      widget.numberModel.number,
      activityId,
    );

    // Check if all activities for this number are completed
    if (_progressService!.isNumberCompleted(
      widget.levelModel.level,
      widget.numberModel.number,
      totalActivities: 4,
    )) {
      _unlockNextNumber();
    }

    _loadProgress();
  }

  Future<void> _unlockNextNumber() async {
    // Find the current index of this number in the level
    final currentIdx = widget.levelModel.numbers.indexWhere(
      (n) => n.number == widget.numberModel.number,
    );

    if (currentIdx != -1) {
      if (currentIdx + 1 < widget.levelModel.numbers.length) {
        // Unlock next number in the same level
        final nextNumber = widget.levelModel.numbers[currentIdx + 1].number;
        await _progressService!.unlockNumber(widget.levelModel.level, nextNumber);
      } else {
        // All numbers in this level completed! Unlock next level
        if (widget.levelModel.level == 1) {
          await _progressService!.setLevel1Completed(true);
        } else if (widget.levelModel.level == 2) {
          await _progressService!.setLevel2Completed(true);
        } else if (widget.levelModel.level == 3) {
          await _progressService!.setLevel3Completed(true);
        }
      }
    }
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

                  return _buildActivityCard(activity, isCompleted);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, bool isCompleted) {
    return Container(
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
          color: isCompleted ? Colors.green : Colors.transparent,
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
          else
            ElevatedButton(
              onPressed: () => _completeActivity(activity['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: activity['color'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Complete (Test)',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
