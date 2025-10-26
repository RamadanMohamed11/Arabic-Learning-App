import 'package:arabic_learning_app/features/Alphabet/presentation/views/alphabet_view.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/writing_practice_view.dart';
import 'package:arabic_learning_app/features/word_training/presentation/views/word_training_view.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/views/simple_svg_letter_view.dart';
import 'package:arabic_learning_app/features/placement_test/presentation/views/placement_test_view.dart';
import 'package:arabic_learning_app/features/levels/presentation/views/levels_selection_view.dart';
import 'package:arabic_learning_app/features/about/presentation/views/about_view.dart';
import 'package:arabic_learning_app/features/welcome/presentation/views/welcome_screen_view.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const String kWelcomeScreenView = '/';
  static const String kPlacementTestView = '/placement_test';
  static const String kLevelsSelectionView = '/levels_selection';
  static const String kAlphabetView = '/alphabet_view';
  static const String kWritingPracticeView = '/writing_practice_view';
  static const String kWordTrainingView = '/word_training_view';
  static const String kLetterTracingView = '/letter_tracing_view';
  static const String kAboutView = '/about';
  
  static final GoRouter routes = GoRouter(
    initialLocation: kWelcomeScreenView,
    redirect: (context, state) async {
      final progressService = await UserProgressService.getInstance();
      
      // إذا لم يشاهد شاشة الترحيب بعد، اذهب لها
      if (!progressService.hasSeenWelcomeScreen() && state.matchedLocation != kWelcomeScreenView) {
        return kWelcomeScreenView;
      }
      
      // إذا شاهد شاشة الترحيب وفي أول مرة، اذهب لاختبار تحديد المستوى
      if (progressService.hasSeenWelcomeScreen() && progressService.isFirstTime() && state.matchedLocation == kWelcomeScreenView) {
        return kPlacementTestView;
      }
      
      // إذا لم تكن أول مرة وفي صفحة الترحيب أو الاختبار، اذهب للمستويات
      if (!progressService.isFirstTime() && (state.matchedLocation == kWelcomeScreenView || state.matchedLocation == kPlacementTestView)) {
        return kLevelsSelectionView;
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: kWelcomeScreenView,
        builder: (context, state) => const WelcomeScreenView(),
      ),
      GoRoute(
        path: kPlacementTestView,
        builder: (context, state) => const PlacementTestView(),
      ),
      GoRoute(
        path: kLevelsSelectionView,
        builder: (context, state) => const LevelsSelectionView(),
      ),
      GoRoute(
        path: kAlphabetView,
        builder: (context, state) => const AlphabetView(),
      ),
      GoRoute(
        path: kWritingPracticeView,
        builder: (context, state) => const WritingPracticeView(),
      ),
      GoRoute(
        path: kWordTrainingView,
        builder: (context, state) => const WordTrainingView(),
      ),
      GoRoute(
        path: kLetterTracingView,
        builder: (context, state) {
          final letter = state.uri.queryParameters['letter'] ?? 'ا';
          return SimpleSvgLetterView(letter: letter);
        },
      ),
      GoRoute(
        path: kAboutView,
        builder: (context, state) => const AboutView(),
      ),
    ],
  );
}
