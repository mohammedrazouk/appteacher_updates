import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ItqanLogo extends StatelessWidget {
  final double size;

  const ItqanLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          'مؤسسة إتقان للتعليم والتنمية',
          style: TextStyle(
            fontSize: size * 0.16,
            fontWeight: FontWeight.bold,
            color: AppColors.brandBlue,
          ),
        ),
      ],
    );
  }
}
