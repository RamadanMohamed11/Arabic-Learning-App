class SentenceOrderQuestion {
  final List<String> words; // shuffled to present
  final String sentence; // correct sentence

  const SentenceOrderQuestion({
    required this.words,
    required this.sentence,
  });
}

// Activity 5: رتّب الكلمات لتكوين جملة صحيحة
const List<SentenceOrderQuestion> sentenceOrderQuestions = [
  SentenceOrderQuestion(
    words: ['الأطفال', 'يلعبون', 'في', 'المدرسة'],
    sentence: 'الأطفال يلعبون في المدرسة.',
  ),
  SentenceOrderQuestion(
    words: ['محمد', 'يقرأ', 'كتابًا', 'جديدًا'],
    sentence: 'محمد يقرأ كتابًا جديدًا.',
  ),
  SentenceOrderQuestion(
    words: ['أمي', 'تطبخ', 'الطعام', 'في', 'المطبخ'],
    sentence: 'أمي تطبخ الطعام في المطبخ.',
  ),
  SentenceOrderQuestion(
    words: ['نذهب', 'إلى', 'الحافلة', 'كل', 'يوم'],
    sentence: 'نذهب إلى الحافلة كل يوم.',
  ),
  SentenceOrderQuestion(
    words: ['ذهبنا', 'إلى', 'حديقة', 'جميلة', 'في', 'نزهة'],
    sentence: 'ذهبنا إلى حديقة جميلة في نزهة.',
  ),
  SentenceOrderQuestion(
    words: ['المعلم', 'يكتب', 'الدرس', 'على', 'السبورة'],
    sentence: 'المعلم يكتب الدرس على السبورة.',
  ),
  SentenceOrderQuestion(
    words: ['الطفل', 'يلعب', 'بالكرة', 'في', 'الحديقة'],
    sentence: 'الطفل يلعب بالكرة في الحديقة.',
  ),
  SentenceOrderQuestion(
    words: ['الجو', 'كان', 'رائعًا', 'على', 'البحر'],
    sentence: 'الجو كان رائعًا على البحر.',
  ),
  SentenceOrderQuestion(
    words: ['أحمد', 'يشاهد', 'التلفاز', 'في', 'المساء'],
    sentence: 'أحمد يشاهد التلفاز في المساء.',
  ),
  SentenceOrderQuestion(
    words: ['الممرضة', 'تساعد', 'المريض', 'في', 'المستشفى'],
    sentence: 'الممرضة تساعد المريض في المستشفى.',
  ),
  SentenceOrderQuestion(
    words: ['المعلم', 'يتحدث', 'مع', 'طلابه'],
    sentence: 'المعلم يتحدث مع طلابه.',
  ),
  SentenceOrderQuestion(
    words: ['الرجل', 'يسافر', 'في', 'القطار', 'إلى', 'المدينة'],
    sentence: 'الرجل يسافر في القطار إلى المدينة.',
  ),
  SentenceOrderQuestion(
    words: ['الطفلة', 'الصغيرة', 'تلعب', 'مع', 'أخيها'],
    sentence: 'الطفلة الصغيرة تلعب مع أخيها.',
  ),
  SentenceOrderQuestion(
    words: ['الرجل', 'الكبير', 'يحمل', 'الحقيبة', 'الثقيلة'],
    sentence: 'الرجل الكبير يحمل الحقيبة الثقيلة.',
  ),
  SentenceOrderQuestion(
    words: ['الرجل', 'يمشي', 'في', 'الشارع', 'صباحًا'],
    sentence: 'الرجل يمشي في الشارع صباحًا.',
  ),
];
