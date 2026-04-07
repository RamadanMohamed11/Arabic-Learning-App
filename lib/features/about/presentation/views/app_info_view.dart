import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class AppInfoView extends StatelessWidget {
  const AppInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'معلومات عن التطبيق',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // App Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_rounded, size: 48, color: AppColors.primary),
                          const SizedBox(width: 12),
                          const Icon(Icons.calculate_rounded, size: 48, color: Color(0xFF6A3DE8)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'تطبيق البداية',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'تعلّم الحروف والأرقام العربية',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'تطبيق "البداية" هو منصة تعليمية تفاعلية متكاملة تجمع بين تعلّم الحروف العربية والأرقام في رحلة واحدة ممتعة — بخطوات بسيطة، وصوت وصورة، وأنشطة تفاعلية متنوعة تناسب جميع المستويات.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Arabic Section
                _buildSection(
                  title: 'قسم الحروف العربية',
                  icon: Icons.menu_book_rounded,
                  iconColor: AppColors.primary,
                  child: Column(
                    children: const [
                      _FeatureRow(
                        icon: Icons.record_voice_over,
                        text: 'نطق الحروف في أشكالها الثلاثة (أول، وسط، آخر الكلمة)',
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.draw_rounded,
                        text: 'تتبع الحروف ورسمها تفاعلياً',
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.quiz_outlined,
                        text: 'اختبارات مراجعة بعد كل مجموعة حروف',
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.lock_open,
                        text: 'نظام فتح تدريجي للحروف مع متابعة التقدم',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Math Section
                _buildSection(
                  title: 'قسم الأرقام والرياضيات',
                  icon: Icons.calculate_rounded,
                  iconColor: const Color(0xFF6A3DE8),
                  child: Column(
                    children: const [
                      _FeatureRow(
                        icon: Icons.gesture,
                        text: 'تتبع الأرقام العربية (١–١٠) برسم تفاعلي',
                        color: Color(0xFF6A3DE8),
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.extension,
                        text: 'نشاط توصيل الأرقام بالصور',
                        color: Color(0xFF6A3DE8),
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.trending_up,
                        text: 'مستويات متعددة: أرقام ١–٩، مضاعفات العشرة، وأرقام مركبة',
                        color: Color(0xFF6A3DE8),
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.compare_arrows,
                        text: 'أنشطة مقارنة وترتيب وكتابة الأرقام',
                        color: Color(0xFF6A3DE8),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Version and Tech
                _buildSection(
                  title: 'النسخة والتقنيات',
                  icon: Icons.settings_rounded,
                  iconColor: Colors.grey.shade600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Bullet(text: 'إصدار التطبيق: 1.0.7'),
                      SizedBox(height: 8),
                      _Bullet(text: 'إطار العمل: Flutter'),
                      SizedBox(height: 8),
                      _Bullet(text: 'يدعم Android و iOS'),
                      SizedBox(height: 8),
                      _Bullet(text: 'يشمل ميزة تحويل النص إلى كلام بالعربية'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Mission
                _buildSection(
                  title: 'رسالتنا',
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.redAccent,
                  child: const Text(
                    'نؤمن بأن كل طفل يستحق بداية تعليمية قوية. هدفنا تقديم تجربة ممتعة وبسيطة تُعلّم الحروف والأرقام العربية بطريقة تكرّم مجهود المتعلم وتبني ثقته بنفسه 💪❤',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    IconData icon = Icons.star_rounded,
    Color iconColor = AppColors.primary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _FeatureRow({required this.icon, required this.text, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(fontSize: 18, color: AppColors.primary),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.5),
          ),
        ),
      ],
    );
  }
}
