import 'models/math_level_model.dart';
import 'models/math_number_model.dart';

final List<MathLevelModel> mathLevels = [
  MathLevelModel(
    level: 1,
    title: 'المستوى الأول',
    description: 'الأرقام من 1 إلى 10',
    numbers: List.generate(
      10,
      (index) => MathNumberModel(number: index + 1, label: '${index + 1}'),
    ),
  ),
  MathLevelModel(
    level: 2,
    title: 'المستوى الثاني',
    description: 'مضاعفات الرقم 10',
    numbers: List.generate(
      10,
      (index) => MathNumberModel(
        number: (index + 1) * 10,
        label: '${(index + 1) * 10}',
      ),
    ),
  ),
  MathLevelModel(
    level: 3,
    title: 'المستوى الثالث',
    description: 'الأرقام المركبة (21-99)',
    numbers:
        List.generate(79, (index) {
          final num = index + 21;
          return MathNumberModel(number: num, label: '$num');
        })..removeWhere(
          (element) => element.number % 10 == 0,
        ), // Remove multiples of 10 if necessary, but 21-99 usually contains them unless specified otherwise. Let's keep all 21-99 except multiples of 10, or just all of them. The requirement says "compound numbers 21-99". A compound number in this context usually means numbers like 21, 22 ... 99.
  ),
];
