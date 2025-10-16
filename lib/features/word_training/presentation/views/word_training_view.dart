import 'package:flutter/material.dart';
import 'package:arabic_learning_app/features/word_training/presentation/views/widgets/word_training_view_body.dart';

class WordTrainingView extends StatelessWidget {
  const WordTrainingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تدريب الكتابة بالصوت',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const WordTrainingViewBody(),
    );
  }
}
