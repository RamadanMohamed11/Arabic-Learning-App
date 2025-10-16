import 'package:arabic_learning_app/features/writing_practice/presentation/views/widgets/writing_practice_view_body.dart';
import 'package:flutter/material.dart';

class WritingPracticeView extends StatelessWidget {
  const WritingPracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "تدريب الكتابة",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const WritingPracticeViewBody(),
    );
  }
}
