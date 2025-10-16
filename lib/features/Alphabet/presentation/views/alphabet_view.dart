import 'package:arabic_learning_app/features/Alphabet/presentation/views/widgets/alphabet_view_body.dart';
import 'package:arabic_learning_app/features/exercises/presentation/views/exercises_view.dart';
import 'package:arabic_learning_app/features/about/presentation/views/about_view.dart';
import 'package:flutter/material.dart';

class AlphabetView extends StatefulWidget {
  const AlphabetView({super.key});

  @override
  State<AlphabetView> createState() => _AlphabetViewState();
}

class _AlphabetViewState extends State<AlphabetView> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onBottomNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          AlphabetViewBody(),
          ExercisesView(),
          AboutView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white.withOpacity(0.95),
        indicatorColor: const Color(0xFF667eea).withOpacity(0.2),
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (value) {
          _onBottomNavTapped(value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.abc),
            selectedIcon: Icon(
              Icons.abc,
              color: Color(0xFF667eea),
            ),
            label: 'الحروف',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            selectedIcon: Icon(
              Icons.fitness_center,
              color: Color(0xFF667eea),
            ),
            label: 'تمارين',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(
              Icons.info,
              color: Color(0xFF667eea),
            ),
            label: 'عن التطبيق',
          ),
        ],
      ),
    );
  }
}
