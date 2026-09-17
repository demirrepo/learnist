import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'ai_lab_common.dart';

/// The same question asked badly and well, one above the other.
class PromptComparisonSection extends StatelessWidget {
  const PromptComparisonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AiLabSectionHeader(
          title: 'Bad prompt → better prompt',
          subtitle: 'Same question, very different answers.',
        ),
        SizedBox(height: 16),
        _PromptExampleCard(
          prompt: 'Why answer B?',
          note:
              'No role, no context, no level. The AI has to guess what '
              'you need, so the answer is vague.',
          icon: LucideIcons.xCircle,
          background: AppColors.dangerSoft,
          foreground: AppColors.dangerDark,
        ),
        SizedBox(height: 12),
        _PromptExampleCard(
          prompt: examplePrompt,
          note:
              'Role + question context + level + format. The AI knows '
              'exactly how to help you.',
          icon: LucideIcons.checkCircle2,
          background: AppColors.successSoft,
          foreground: AppColors.successDark,
        ),
      ],
    );
  }
}

class _PromptExampleCard extends StatelessWidget {
  const _PromptExampleCard({
    required this.prompt,
    required this.note,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String prompt;
  final String note;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: aiLabCardRadius,
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$prompt"',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  note,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: foreground.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
