import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/itqan_logo.dart';
import '../app_update/widgets/app_update_button.dart';
import '../evaluation/screens/setup_form_screen.dart';
import '../ladders/screens/setup_form_screen.dart' as ladders;
import '../teacher_bag/screens/teacher_bag_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const ItqanLogo(size: 140),
              const SizedBox(height: 40),
              _MenuCard(
                icon: Icons.calculate_outlined,
                title: 'حساب تحقيق الخطة الزمنية',
                subtitle: 'نظام إدارة الحلقات والطلاب',
                onTap: () => Navigator.pushNamed(context, '/classes'),
              ),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.rate_review_outlined,
                title: 'تقييم الصفحة',
                subtitle: 'تقييم الواجب اليومي للطالب',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SetupFormScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.stairs_outlined,
                title: 'سلالم الاختبار',
                subtitle: 'الاختبار التمهيدي للطالب',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ladders.SetupFormScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _MenuCard(
                icon: Icons.work_outline,
                title: 'حقيبة المعلم',
                subtitle: 'دليل معلم الحلقة',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherBagScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const AppUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.brandTeal, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
