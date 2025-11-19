class ImageNameItem {
  final String answer;
  final String imagePath;
  final List<String> accepted; // additional acceptable answers/synonyms

  const ImageNameItem({
    required this.answer,
    required this.imagePath,
    this.accepted = const [],
  });
}

// Activity 4: اكتب اسم الصورة
// Using only image files that exist under assets/images to avoid missing-asset exceptions.
const List<ImageNameItem> imageNameItems = [
  ImageNameItem(answer: 'مستشفى', imagePath: 'assets/images/مستشفى.jpg'),
  ImageNameItem(answer: 'مكتبة', imagePath: 'assets/images/مكتبة.jpg'),
  ImageNameItem(answer: 'حديقة', imagePath: 'assets/images/حديقة.jpg'),
  ImageNameItem(answer: 'مطعم', imagePath: 'assets/images/مطعم.jpg'),
  ImageNameItem(answer: 'مدرسة', imagePath: 'assets/images/مدرسة.jpg'),
  ImageNameItem(answer: 'شرطي', imagePath: 'assets/images/شرطي.jpg'),
  ImageNameItem(answer: 'ممرضة', imagePath: 'assets/images/ممرضة.jpg'),
  ImageNameItem(answer: 'نجار', imagePath: 'assets/images/نجار.jpg'),
  ImageNameItem(answer: 'طبيب', imagePath: 'assets/images/طبيب.jpg'),
  ImageNameItem(answer: 'مهندس', imagePath: 'assets/images/مهندس.jpg'),
  ImageNameItem(answer: 'يرسم', imagePath: 'assets/images/يرسم.jpg'),
  ImageNameItem(answer: 'يكتب', imagePath: 'assets/images/يكتب.jpg'),
  ImageNameItem(answer: 'يقرأ', imagePath: 'assets/images/يقرأ.jpg'),
  // ينام: يوجد ملف "نام.jpg"؛ نقبل كلا الصيغتين
  ImageNameItem(answer: 'ينام', imagePath: 'assets/images/نام.jpg', accepted: ['نام']),
  ImageNameItem(answer: 'يشرب', imagePath: 'assets/images/يشرب.jpg'),
  ImageNameItem(answer: 'يسبح', imagePath: 'assets/images/يسبح.jpg'),
  ImageNameItem(answer: 'يعمل', imagePath: 'assets/images/يعمل.jpg'),
  ImageNameItem(answer: 'سوق', imagePath: 'assets/images/سوق.jpg'),
  ImageNameItem(answer: 'مزرعة', imagePath: 'assets/images/مزرعة.jpg'),
  ImageNameItem(answer: 'مكتب', imagePath: 'assets/images/مكتب.jpg'),
];
