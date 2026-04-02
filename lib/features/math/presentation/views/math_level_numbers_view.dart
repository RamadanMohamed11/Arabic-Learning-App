import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';
import 'package:arabic_learning_app/core/services/math_progress_service.dart';
import 'package:arabic_learning_app/features/math/data/models/math_level_model.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'math_number_activities_view.dart';

class MathLevelNumbersView extends StatefulWidget {
  final MathLevelModel level;

  const MathLevelNumbersView({super.key, required this.level});

  @override
  State<MathLevelNumbersView> createState() => _MathLevelNumbersViewState();
}

class _MathLevelNumbersViewState extends State<MathLevelNumbersView> {
  MathProgressService? _progressService;
  final FlutterTts _flutterTts = FlutterTts();
  bool _ttsInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _progressService = await MathProgressService.getInstance();
    if (!_ttsInitialized) {
      _ttsInitialized = true;
      _initTts();
    }
    setState(() {});
  }

  Future<void> _initTts() async {
    await TtsConfig.configure(_flutterTts, speechRate: 0.4, pitch: 1.0);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      await _flutterTts.speak(
        '${widget.level.title}. اختر الرقم الذي تريد تعلمه',
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.level.level == 1
        ? AppColors.level1
        : widget.level.level == 2
        ? AppColors.level2
        : AppColors.primaryGradient;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[0].withOpacity(0.3), colors[1].withOpacity(0.3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, colors),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: widget.level.numbers.length,
                  itemBuilder: (context, index) {
                    final numberModel = widget.level.numbers[index];
                    final isUnlocked =
                        _progressService?.isNumberUnlocked(
                          widget.level.level,
                          numberModel.number,
                        ) ??
                        false;
                    return _buildNumberCard(numberModel, isUnlocked, colors);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<Color> colors) {
    // Calculate progress for this level
    int completedCount = 0;
    for (var n in widget.level.numbers) {
      if (_progressService?.isNumberCompleted(widget.level.level, n.number) ==
          true) {
        completedCount++;
      }
    }
    final total = widget.level.numbers.length;
    final progressVal = total > 0 ? (completedCount / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 48), // Spacer for balance
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.level.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.level.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'التقدم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$completedCount / $total أرقام',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressVal,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.greenAccent,
                  ),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(
    dynamic numberModel,
    bool isUnlocked,
    List<Color> colors,
  ) {
    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              await Navigator.push(
                context,
                AnimatedRoute.slideRight(
                  MathNumberActivitiesView(
                    numberModel: numberModel,
                    levelModel: widget.level,
                  ),
                ),
              );
              _loadProgress();
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? colors
                : [Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? colors[0].withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Text(
                numberModel.label,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ] else ...[
              const Icon(Icons.lock, size: 30, color: Colors.white70),
              const SizedBox(height: 4),
              Text(
                numberModel.label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
