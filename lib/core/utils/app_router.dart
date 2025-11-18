import 'package:arabic_learning_app/features/Alphabet/presentation/views/alphabet_view.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/writing_practice_view.dart';
import 'package:arabic_learning_app/features/word_training/presentation/views/word_training_view.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/views/simple_svg_letter_view.dart';
import 'package:arabic_learning_app/features/placement_test/presentation/views/placement_test_view.dart';
import 'package:arabic_learning_app/features/levels/presentation/views/levels_selection_view.dart';
import 'package:arabic_learning_app/features/about/presentation/views/about_view.dart';
import 'package:arabic_learning_app/features/about/presentation/views/app_info_view.dart';
import 'package:arabic_learning_app/features/about/presentation/views/contact_us_view.dart';
import 'package:arabic_learning_app/features/welcome/presentation/views/welcome_screen_view.dart';
import 'package:arabic_learning_app/features/certificate/presentation/views/certificate_view.dart';
import 'package:arabic_learning_app/core/services/user_progress_service.dart';
import 'package:arabic_learning_app/core/utils/page_transitions.dart';
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
  static const String kAppInfoView = '/app_info';
  static const String kContactUsView = '/contact_us';
  static const String kCertificateView = '/certificate_view';

  static final GoRouter routes = GoRouter(
    initialLocation: kWelcomeScreenView,
    redirect: (context, state) async {
      final progressService = await UserProgressService.getInstance();

      // إذا لم يشاهد شاشة الترحيب بعد، اذهب لها
      if (!progressService.hasSeenWelcomeScreen() &&
          state.matchedLocation != kWelcomeScreenView) {
        return kWelcomeScreenView;
      }

      // إذا شاهد شاشة الترحيب وفي أول مرة، اذهب لاختبار تحديد المستوى
      if (progressService.hasSeenWelcomeScreen() &&
          progressService.isFirstTime() &&
          state.matchedLocation == kWelcomeScreenView) {
        return kPlacementTestView;
      }

      // إذا لم تكن أول مرة وفي صفحة الترحيب أو الاختبار، اذهب للمستويات
      if (!progressService.isFirstTime() &&
          (state.matchedLocation == kWelcomeScreenView ||
              state.matchedLocation == kPlacementTestView)) {
        return kLevelsSelectionView;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: kWelcomeScreenView,
        pageBuilder: (context, state) => PageTransitions.fadeScale(
          child: const WelcomeScreenView(),
          state: state,
        ),
      ),
      GoRoute(
        path: kPlacementTestView,
        pageBuilder: (context, state) => PageTransitions.slideScale(
          child: const PlacementTestView(),
          state: state,
        ),
      ),
      GoRoute(
        path: kLevelsSelectionView,
        pageBuilder: (context, state) => PageTransitions.elegantZoom(
          child: const LevelsSelectionView(),
          state: state,
        ),
      ),
      GoRoute(
        path: kAlphabetView,
        pageBuilder: (context, state) => PageTransitions.slideRight(
          child: const AlphabetView(),
          state: state,
        ),
      ),
      GoRoute(
        path: kWritingPracticeView,
        pageBuilder: (context, state) => PageTransitions.slideUp(
          child: const WritingPracticeView(),
          state: state,
        ),
      ),
      GoRoute(
        path: kWordTrainingView,
        pageBuilder: (context, state) => PageTransitions.rotationFade(
          child: const WordTrainingView(),
          state: state,
        ),
      ),
      GoRoute(
        path: kLetterTracingView,
        pageBuilder: (context, state) {
          final letter = state.uri.queryParameters['letter'] ?? 'ا';
          return PageTransitions.slideScale(
            child: SimpleSvgLetterView(letter: letter),
            state: state,
          );
        },
      ),
      GoRoute(
        path: kAboutView,
        pageBuilder: (context, state) =>
            PageTransitions.fade(child: const AboutView(), state: state),
      ),
      GoRoute(
        path: kAppInfoView,
        pageBuilder: (context, state) =>
            PageTransitions.fade(child: const AppInfoView(), state: state),
      ),
      GoRoute(
        path: kContactUsView,
        pageBuilder: (context, state) =>
            PageTransitions.fade(child: const ContactUsView(), state: state),
      ),
      GoRoute(
        path: kCertificateView,
        pageBuilder: (context, state) =>
            PageTransitions.fade(child: const CertificateView(), state: state),
      ),
    ],
  );
}
