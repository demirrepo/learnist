import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'ai_lab_common.dart';

/// Free-text prompt box with a check button. Checking isn't wired to a
/// backend yet, so [onCheck] only reports that.
class PromptCheckerCard extends StatelessWidget {
  const PromptCheckerCard({super.key, required this.onCheck});

  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    const noBorder = OutlineInputBorder(
      borderRadius: aiLabCardRadius,
      borderSide: BorderSide.none,
    );

    return AiLabCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.wand2,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Prompt checker',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            minLines: 5,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            style: GoogleFonts.manrope(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            // Only the focused border comes from the app theme.
            decoration: const InputDecoration(
              hintText: 'Write a prompt...',
              fillColor: AppColors.track,
              border: noBorder,
              enabledBorder: noBorder,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onCheck,
            child: const Text('Check my prompt'),
          ),
        ],
      ),
    );
  }
}
