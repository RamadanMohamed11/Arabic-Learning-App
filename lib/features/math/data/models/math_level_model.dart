import 'math_number_model.dart';

class MathLevelModel {
  final int level;
  final String title;
  final String description;
  final List<MathNumberModel> numbers;
  final String svgBasePath;

  const MathLevelModel({
    required this.level,
    required this.title,
    required this.description,
    required this.numbers,
    this.svgBasePath = 'assets/svg/numbers',
  });
}
