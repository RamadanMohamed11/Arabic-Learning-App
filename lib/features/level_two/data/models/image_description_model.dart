class ImageDescriptionItem {
  final String imagePath; // assets/images/1.jpg
  final List<String> keywords; // words to encourage in the description
  final String sample; // sample sentence

  const ImageDescriptionItem({
    required this.imagePath,
    required this.keywords,
    required this.sample,
  });
}

// Activity 6 items mapped to 1.jpg .. 10.jpg
const List<ImageDescriptionItem> imageDescriptionItems = [
  ImageDescriptionItem(
    imagePath: 'assets/images/1.jpg',
    keywords: ['الأطفال', 'يزرعون', 'الأشجار', 'الحديقة'],
    sample: 'الأطفال يزرعون الأشجار في الحديقة.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/2.jpg',
    keywords: ['المعلمة', 'تشرح', 'الفصل'],
    sample: 'المعلمة تشرح في الفصل.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/3.jpg',
    keywords: ['الطبيب', 'يعالج', 'المريض', 'المستشفى'],
    sample: 'الطبيب يعالج المريض في المستشفى.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/4.jpg',
    keywords: ['المزارع', 'يعمل', 'الحقل'],
    sample: 'المزارع يعمل في الحقل.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/5.jpg',
    keywords: ['الأسرة', 'تتناول', 'الطعام', 'المطعم'],
    sample: 'الأسرة تتناول الطعام في المطعم.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/6.jpg',
    keywords: ['الشرطي', 'ينظم', 'المرور', 'الشارع'],
    sample: 'الشرطي ينظم المرور في الشارع.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/7.jpg',
    keywords: ['المعلم', 'يشرح', 'السبورة'],
    sample: 'المعلم يشرح على السبورة.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/8.jpg',
    keywords: ['الطباخ', 'يعد', 'الطعام', 'المطبخ'],
    sample: 'الطباخ يعد الطعام في المطبخ.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/9.jpg',
    keywords: ['الأطفال', 'يغنون', 'الحفلة'],
    sample: 'الأطفال يغنون في الحفلة.',
  ),
  ImageDescriptionItem(
    imagePath: 'assets/images/10.jpg',
    keywords: ['الولد', 'يرسم', 'الحديقة'],
    sample: 'الولد يرسم في الحديقة.',
  ),
];
