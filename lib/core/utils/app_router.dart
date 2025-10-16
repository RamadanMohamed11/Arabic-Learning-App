import 'package:arabic_learning_app/features/Alphabet/presentation/views/alphabet_view.dart';
import 'package:arabic_learning_app/features/writing_practice/presentation/views/writing_practice_view.dart';
import 'package:arabic_learning_app/features/word_training/presentation/views/word_training_view.dart';
import 'package:arabic_learning_app/features/letter_tracing/presentation/views/simple_svg_letter_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const String kAlphabetView = '/alphabet_view';
  static const String kWritingPracticeView = '/writing_practice_view';
  static const String kWordTrainingView = '/word_training_view';
  static const String kLetterTracingView = '/letter_tracing_view';
  
  static final GoRouter routes = GoRouter(
    initialLocation: kAlphabetView,
    routes: [
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
    ],
  );
}
