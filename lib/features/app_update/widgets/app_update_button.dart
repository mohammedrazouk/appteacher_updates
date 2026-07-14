import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../screens/app_update_screen.dart';

class AppUpdateButton extends StatelessWidget {
  const AppUpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppUpdateScreen()),
          ),
          icon: const Icon(Icons.update, size: 20),
          label: const Text('تحديث البرنامج'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brandBlue,
            side: const BorderSide(color: AppColors.brandBlue),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}
