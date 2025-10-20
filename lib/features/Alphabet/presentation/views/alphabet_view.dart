import 'package:arabic_learning_app/core/utils/app_colors.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          elevation: 0,
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.white.withOpacity(0.3),
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (value) {
            _onBottomNavTapped(value);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.abc,
                color: Colors.white.withOpacity(0.7),
              ),
              selectedIcon: const Icon(
                Icons.abc,
                color: Colors.white,
                size: 28,
              ),
              label: 'الحروف',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.fitness_center,
                color: Colors.white.withOpacity(0.7),
              ),
              selectedIcon: const Icon(
                Icons.fitness_center,
                color: Colors.white,
                size: 28,
              ),
              label: 'تمارين',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.7),
              ),
              selectedIcon: const Icon(
                Icons.info,
                color: Colors.white,
                size: 28,
              ),
              label: 'عن التطبيق',
            ),
          ],
        ),
      ),
    );
  }
}
