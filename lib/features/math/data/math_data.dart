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
    description: 'الأرقام المركبة',
    svgBasePath: 'assets/images/Math/level3/numbers',
    numbers: [
      for (final n in [
        11, 13, 15, 16, 17,
        22, 24, 25, 28, 29,
        31, 32, 36, 38, 39,
        42, 43, 45, 46, 47,
        52, 53, 56, 57, 59,
        61, 62, 65, 66, 67,
        72, 75, 76, 78, 79,
        81, 83, 84, 86, 88,
        91, 93, 95, 97, 99,
      ])
        MathNumberModel(number: n, label: n.toArabicDigits()),
    ],
  ),
];
