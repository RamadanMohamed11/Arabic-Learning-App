import 'package:flutter/material.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/views/simple_svg_letter_view.dart';
import 'package:arabic_learning_app/features/word_training/presentation/views/widgets/word_training_view_body.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/writing_practice_view_body.dart';
import 'package:arabic_learning_app/features/memory_game/presentation/views/widgets/memory_game_view_body.dart';
import 'package:arabic_learning_app/features/word_search/presentation/views/widgets/word_search_view_body.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({super.key});

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'التمارين',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: const Color(0xFF6A1B9A),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              isScrollable: true,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.gesture, size: 24),
                  text: 'تتبع الحروف',
                ),
                Tab(
                  icon: Icon(Icons.volume_up, size: 24),
                  text: 'تدريب الكلمات',
                ),
                Tab(
                  icon: Icon(Icons.edit, size: 24),
                  text: 'تدريب الكتابة',
                ),
                Tab(
                  icon: Icon(Icons.psychology, size: 24),
                  text: 'لعبة الذاكرة',
                ),
                Tab(
                  icon: Icon(Icons.search, size: 24),
                  text: 'البحث عن الكلمات',
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildAnimatedTab(const SimpleSvgLetterView(letter: 'ا'), 0),
              _buildAnimatedTab(const WordTrainingViewBody(), 1),
              _buildAnimatedTab(const WritingPracticeViewBody(), 2),
              _buildAnimatedTab(const MemoryGameViewBody(), 3),
              _buildAnimatedTab(const WordSearchViewBody(), 4),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedTab(Widget child, int index) {
    final value = _tabController.animation!.value;
    final opacity = (1 - (value - index).abs()).clamp(0.0, 1.0);
    final scale = 0.95 + (0.05 * opacity);

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}
