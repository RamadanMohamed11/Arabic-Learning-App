import 'package:arabic_learning_app/core/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const ArabicLearningApp());
}

class ArabicLearningApp extends StatelessWidget {
  const ArabicLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), // Arabic
        Locale('en'), // English
      ],
      theme: ThemeData(
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              );
            }
            return TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            );
          }),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.routes,
    );
  }
}
