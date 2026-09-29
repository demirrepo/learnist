import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Icon, message and a "Qayta urinish" button for a failed or empty load.
class LoadProblemView extends StatelessWidget {
  const LoadProblemView({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = LucideIcons.wifiOff,
  });

  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: AppColors.hint),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 14.5,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          label: const Text('Qayta urinish'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.deepPurple,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 22),
          ),
        ),
      ],
    );
  }
}
