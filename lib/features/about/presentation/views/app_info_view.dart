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
            colors: [AppColors.primary.withOpacity(0.08), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // App Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 72,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'تطبيق تعلم الحروف العربية',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تطبيق تفاعلي ممتع لتعلم الحروف العربية للأطفال والمبتدئين،'
                        ' مع أنشطة وتمارين صوتية وبصرية وتقدم تدريجي.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Key Features
                _buildSection(
                  title: 'الميزات الرئيسية',
                  child: Column(
                    children: const [
                      _FeatureRow(
                        icon: Icons.record_voice_over,
                        text: 'نطق الحروف والكلمات بالصوت',
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.draw_rounded,
                        text: 'تتبع الحروف ورسمها تلقائياً',
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.quiz_outlined,
                        text: 'اختبارات مراجعة بعد كل مجموعة',
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.lock_open,
                        text: 'نظام فتح تدريجي للحروف',
                      ),
                      SizedBox(height: 10),
                      _FeatureRow(
                        icon: Icons.bar_chart_rounded,
                        text: 'شريط تقدم يعكس إنجازك',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Version and Tech
                _buildSection(
                  title: 'النسخة والتقنيات',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _Bullet(text: 'إصدار التطبيق: 1.0.0'),
                      SizedBox(height: 8),
                      _Bullet(text: 'إطار العمل: Flutter'),
                      SizedBox(height: 8),
                      _Bullet(text: 'دعم Android و iOS'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Mission
                _buildSection(
                  title: 'رسالتنا',
                  child: const Text(
                    'هدفنا تسهيل تعلم اللغة العربية بطريقة تفاعلية مبسطة تناسب الأطفال والمبتدئين،'
                    ' مع التركيز على المرح والتدرج وتحقيق الإنجاز.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
              const Icon(Icons.star_rounded, color: AppColors.primary),
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
      children: [
        const Text(
          '• ',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
