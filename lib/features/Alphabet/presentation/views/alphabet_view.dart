import 'package:arabic_learning_app/features/Alphabet/presentation/views/widgets/alphabet_view_body.dart';
import 'package:arabic_learning_app/features/exercises/presentation/views/exercises_view.dart';
import 'package:flutter/material.dart';

class AlphabetView extends StatefulWidget {
  const AlphabetView({super.key});

  @override
  State<AlphabetView> createState() => _AlphabetViewState();
}

class _AlphabetViewState extends State<AlphabetView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.abc, size: 28),
              text: 'الحروف',
            ),
            Tab(
              icon: Icon(Icons.fitness_center, size: 28),
              text: 'تمارين',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AlphabetViewBody(),
          ExercisesView(),
        ],
      ),
    );
  }
}
