import 'package:arabic_learning_app/features/Alphabet/presentation/views/alphabet_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const String kAlphabetView = '/alphabet_view';
  static final GoRouter routes = GoRouter(
    initialLocation: kAlphabetView,
    routes: [
      GoRoute(
        path: kAlphabetView,
        builder: (context, state) => const AlphabetView(),
      ),
    ],
  );
}
