import 'package:arabic_learning_app/core/utils/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  // Initialize Gemini API with correct vision model
  Gemini.init(
    apiKey: 'AIzaSyDIZEoUkTYqmGAhhxnvBPhrHr6tzWVW8zk',
    enableDebugging: true,
    generationConfig: GenerationConfig(
      temperature: 0.4,
      topK: 32,
      topP: 1,
      maxOutputTokens: 512,
    ),
  );

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

      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.routes,
    );
  }
}
