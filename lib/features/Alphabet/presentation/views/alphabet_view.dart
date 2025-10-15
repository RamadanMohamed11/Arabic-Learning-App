import 'package:arabic_learning_app/features/Alphabet/presentation/views/widgets/alphabet_view_body.dart';
import 'package:flutter/material.dart';

class AlphabetView extends StatelessWidget {
  const AlphabetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("الحروف", style: TextStyle(fontWeight: FontWeight.bold)),
      //   centerTitle: true,
      // ),
      body: AlphabetViewBody(),
    );
  }
}
