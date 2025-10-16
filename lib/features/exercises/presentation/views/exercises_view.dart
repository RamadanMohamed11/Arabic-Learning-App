import 'package:flutter/material.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/views/simple_svg_letter_view.dart';
import 'package:arabic_learning_app/features/word_training/presentation/views/widgets/word_training_view_body.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/writing_practice_view_body.dart';
import 'package:arabic_learning_app/features/memory_game/presentation/views/widgets/memory_game_view_body.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text(
          'التمارين',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.gesture, size: 22),
              text: 'تتبع الحروف',
            ),
            Tab(
              icon: Icon(Icons.volume_up, size: 22),
              text: 'تدريب الكلمات',
            ),
            Tab(
              icon: Icon(Icons.edit, size: 22),
              text: 'تدريب الكتابة',
            ),
            Tab(
              icon: Icon(Icons.psychology, size: 22),
              text: 'لعبة الذاكرة',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SimpleSvgLetterView(letter: 'ا'),
          WordTrainingViewBody(),
          WritingPracticeViewBody(),
          MemoryGameViewBody(),
        ],
      ),
    );
  }
}
