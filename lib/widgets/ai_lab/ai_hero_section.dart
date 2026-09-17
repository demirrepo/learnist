import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'ai_lab_common.dart';

const _promptParts = ['Role', 'Task', 'Level', 'Context', 'Format'];

/// Intro to prompt literacy: headline, the five prompt parts and an
/// example prompt on a dark card.
class AiHeroSection extends StatelessWidget {
  const AiHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PROMPT LITERACY',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ask better questions. Learn more independently.',
          style: GoogleFonts.manrope(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A prompt is the instruction you give an AI. A clear prompt gets '
          'you an answer you can learn from, not just one to copy.',
          style: GoogleFonts.manrope(
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final part in _promptParts) _PartPill(label: part)],
        ),
        const SizedBox(height: 20),
        const _ExamplePromptCard(),
      ],
    );
  }
}

class _PartPill extends StatelessWidget {
  const _PartPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ExamplePromptCard extends StatelessWidget {
  const _ExamplePromptCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.midnightGradient,
        ),
        borderRadius: aiLabCardRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.midnightGradient.first.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'EXAMPLE PROMPT',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: const Color(0xFFA4A9BD),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            examplePrompt,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13.5,
              height: 1.6,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
