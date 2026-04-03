import 'package:arabic_learning_app/core/utils/arabic_numbers_extension.dart';
import 'models/math_level_model.dart';
import 'models/math_number_model.dart';

final List<MathLevelModel> mathLevels = [
  MathLevelModel(
    level: 1,
    title: 'المستوى الأول',
    description: 'الأرقام من ١ إلى ١٠',
    numbers: List.generate(
      10,
      (index) => MathNumberModel(
        number: index + 1,
        label: (index + 1).toArabicDigits(),
      ),
    ),
  ),
  MathLevelModel(
    level: 2,
    title: 'المستوى الثاني',
    description: 'مضاعفات الرقم ١٠',
    numbers: List.generate(
      10,
      (index) => MathNumberModel(
        number: (index + 1) * 10,
        label: ((index + 1) * 10).toArabicDigits(),
      ),
    ),
  ),
  MathLevelModel(
    level: 3,
    title: 'المستوى الثالث',
    description: 'الأرقام المركبة (٢١-٩٩)',
    numbers: List.generate(79, (index) {
      final num = index + 21;
      return MathNumberModel(number: num, label: num.toArabicDigits());
    })..removeWhere((element) => element.number % 10 == 0),
  ),
];
