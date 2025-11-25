class ImageNameItem {
  final String answer;
  final String imagePath;
  final List<String> accepted; // additional acceptable answers/synonyms
  final String? ttsText; // text with diacritics for proper pronunciation

  const ImageNameItem({
    required this.answer,
    required this.imagePath,
    this.accepted = const [],
    this.ttsText,
  });
}

// Activity 4: اكتب اسم الصورة
// Using only image files that exist under assets/images to avoid missing-asset exceptions.
const List<ImageNameItem> imageNameItems = [
  ImageNameItem(
    answer: 'مستشفى',
    imagePath: 'assets/images/مستشفى.jpg',
    ttsText: 'مُسْتَشْفَى',
  ),
  ImageNameItem(
    answer: 'مكتبة',
    imagePath: 'assets/images/مكتبة.jpg',
    ttsText: 'مَكْتَبَة',
  ),
  ImageNameItem(
    answer: 'حديقة',
    imagePath: 'assets/images/حديقة.jpg',
    ttsText: 'حَدِيقَة',
  ),
  ImageNameItem(
    answer: 'مطعم',
    imagePath: 'assets/images/مطعم.jpg',
    ttsText: 'مَطْعَم',
  ),
  ImageNameItem(
    answer: 'مدرسة',
    imagePath: 'assets/images/مدرسة.jpg',
    ttsText: 'مَدْرَسَة',
  ),
  ImageNameItem(
    answer: 'شرطي',
    imagePath: 'assets/images/شرطي.jpg',
    ttsText: 'شُرْطِي',
  ),
  ImageNameItem(
    answer: 'ممرضة',
    imagePath: 'assets/images/ممرضة.jpg',
    ttsText: 'مُمَرِّضَة',
  ),
  ImageNameItem(
    answer: 'نجار',
    imagePath: 'assets/images/نجار.jpg',
    ttsText: 'نَجَّار',
  ),
  ImageNameItem(
    answer: 'طبيب',
    imagePath: 'assets/images/طبيب.jpg',
    ttsText: 'طَبِيب',
  ),
  ImageNameItem(
    answer: 'مهندس',
    imagePath: 'assets/images/مهندس.jpg',
    ttsText: 'مُهَنْدِس',
  ),
  ImageNameItem(
    answer: 'يرسم',
    imagePath: 'assets/images/يرسم.jpg',
    ttsText: 'يَرْسُم',
  ),
  ImageNameItem(
    answer: 'يكتب',
    imagePath: 'assets/images/يكتب.jpg',
    ttsText: 'يَكْتُب',
  ),
  ImageNameItem(
    answer: 'يقرأ',
    imagePath: 'assets/images/يقرأ.jpg',
    ttsText: 'يَقْرَأ',
  ),
  // ينام: يوجد ملف "نام.jpg"؛ نقبل كلا الصيغتين
  ImageNameItem(
    answer: 'ينام',
    imagePath: 'assets/images/نام.jpg',
    accepted: ['نام'],
    ttsText: 'يَنَام',
  ),
  ImageNameItem(
    answer: 'يشرب',
    imagePath: 'assets/images/يشرب.jpg',
    ttsText: 'يَشْرَب',
  ),
  ImageNameItem(
    answer: 'يسبح',
    imagePath: 'assets/images/يسبح.jpg',
    ttsText: 'يَسْبَح',
  ),
  ImageNameItem(
    answer: 'يعمل',
    imagePath: 'assets/images/يعمل.jpg',
    ttsText: 'يَعْمَل',
  ),
  ImageNameItem(
    answer: 'سوق',
    imagePath: 'assets/images/سوق.jpg',
    ttsText: 'سُوق',
  ),
  ImageNameItem(
    answer: 'مزرعة',
    imagePath: 'assets/images/مزرعة.jpg',
    ttsText: 'مَزْرَعَة',
  ),
  ImageNameItem(
    answer: 'مكتب',
    imagePath: 'assets/images/مكتب.jpg',
    ttsText: 'مَكْتَب',
  ),
];
