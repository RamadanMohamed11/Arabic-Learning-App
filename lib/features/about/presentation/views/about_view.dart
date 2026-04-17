import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';

class TeamMember {
  final String name;
  final String role;
  final String roleEn;
  final String description;
  final IconData icon;
  final String? imagePath;

  const TeamMember({
    required this.name,
    required this.role,
    required this.roleEn,
    required this.description,
    required this.icon,
    this.imagePath,
  });
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const List<TeamMember> _teamMembers = [
    TeamMember(
      name: 'أسماء فرغلي عبد المنعم',
      role: 'مسؤولة قسم الرياضيات',
      roleEn: 'Math Subject Lead',
      description:
          'كتابة المحتوى التعليمي وإعداد وتجميع التمارين الخاصة بقسم الرياضيات.',
      icon: Icons.calculate,
      imagePath: 'assets/images/team/أسماء.jpg',
    ),
    TeamMember(
      name: 'أمنية أشرف عبد الفتاح',
      role: 'كاتب تجربة المستخدم',
      roleEn: 'UX Writer',
      description:
          'كتابة وتنظيم تجربة المستخدم داخل التطبيق، من اختبار تحديد المستوى إلى عرض النتائج والمستويات والمحتوى الداخلي، وصولًا إلى صفحة شهادة النجاح.',
      icon: Icons.psychology,
      imagePath: 'assets/images/team/أمنية.jpg',
    ),
    TeamMember(
      name: 'برسيس بهيج',
      role: 'كاتب المحتوى',
      roleEn: 'Content Writer',
      description:
          'كتابة وتصميم المحتوى التعليمي الخاص بالمستوى الاول داخل التطبيق، بما يشمل الأنشطة التفاعلية وما يتعلمه الطالب داخل المستوى بالكامل.',
      icon: Icons.menu_book,
      imagePath: 'assets/images/team/برسيس.jpg',
    ),
    TeamMember(
      name: 'حسين طارق دسوقي',
      role: 'مجمع الأنشطة',
      roleEn: 'Activity Collector',
      description:
          'جمع وتصنيف الأنشطة المختلفة داخل التطبيق وتنظيمها بطريقة تساعد المستخدم على التنقل والتعلم بسهولة.',
      icon: Icons.folder_special,
      imagePath: 'assets/images/team/حسين.jpg',
    ),
    TeamMember(
      name: 'دينا صبري',
      role: 'مصمم الهوية البصرية',
      roleEn: 'Visual Identity Designer',
      description:
          'تنسيق الألوان الأساسية داخل واجهة التطبيق، بالإضافة إلى تصميم شعار التطبيق (اللوجو) بما يحقق هوية بصرية موحدة وجذّابة.',
      icon: Icons.palette,
      imagePath: 'assets/images/team/دينا.jpg',
    ),
    TeamMember(
      name: 'مريم عاطف شكري شاكر',
      role: 'مصمم المحتوى',
      roleEn: 'Content Designer',
      description:
          'تصميم ورسم الحروف والأرقام بالطريقة المناسبة التي تساعد المستخدم على تعلمها وممارستها.',
      icon: Icons.brush,
      imagePath: 'assets/images/team/مريم.jpg',
    ),
    TeamMember(
      name: 'منن هشام حمزة',
      role: 'مصمم محتوى',
      roleEn: 'Content Designer',
      description:
          'تصميم ورسم الحروف ومواضيع الحروف بالطريقة المناسبة التي تساعد المستخدم على تعلم الحروف وممارستها.',
      icon: Icons.draw,
      imagePath: 'assets/images/team/منن.jpg',
    ),
    TeamMember(
      name: 'مي سيد',
      role: 'مصمم شعار التطبيق',
      roleEn: 'App Logo Designer',
      description:
          'تصميم شعار التطبيق (اللوجو) بالشكل المناسب لفكرة المشروع، بما يعبر عن هدف التطبيق ويعزز الهوية البصرية الخاصة به.',
      icon: Icons.auto_awesome,
      imagePath: 'assets/images/team/مي.jpg',
    ),
    TeamMember(
      name: 'هبة شاكر',
      role: 'مصمم محتوى الاختبارات',
      roleEn: 'Test Content Creator',
      description:
          'تصميم محتوى الاختبارات داخل التطبيق وإنشاء بنك الأسئلة لتقييم مستوى الطالب وتحديد تقدمه داخل المستويات المختلفة.',
      icon: Icons.quiz,
      imagePath: 'assets/images/team/هبة.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'فريق العمل',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Center(
                child: const Text(
                  'طلاب كلية تربية قسم STEM \n جامعة أسيوط الفرقة الثالثة\nجروب (5)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Team Members List
              ...List.generate(_teamMembers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildTeamMemberCard(_teamMembers[index]),
                );
              }),

              const SizedBox(height: 20),

              // Footer
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.favorite, color: AppColors.primary, size: 32),
                      const SizedBox(height: 12),
                      const Text(
                        'صُنع بحب لتعليم الأطفال ومحو الأمية',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(TeamMember member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar - Image or Icon (full height)
            Container(
              width: 90,
              decoration: BoxDecoration(
                gradient: member.imagePath == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.cream,
                          AppColors.mintGreen.withValues(alpha: 0.3),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: member.imagePath != null
                  ? Image.asset(
                      member.imagePath!,
                      fit: BoxFit.cover,
                      width: 90,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.cream,
                                AppColors.mintGreen.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              member.icon,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        member.icon,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.role} | ${member.roleEn}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
