import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';

/// Dark "Today's focus" banner with the next-lesson and AI Lab actions.
class HeroBannerCard extends StatelessWidget {
  const HeroBannerCard({
    super.key,
    required this.masteryPercent,
    required this.headline,
    required this.subtitle,
    required this.nextLessonNumber,
    required this.onContinue,
    required this.onOpenAiLab,
  });

  final int masteryPercent;
  final String headline;
  final String subtitle;
  final int nextLessonNumber;
  final VoidCallback onContinue;
  final VoidCallback onOpenAiLab;

  static const _buttonHeight = 52.0;

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.midnightGradient.first.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _FocusChip(),
              const Spacer(),
              _MasteryChip(percent: masteryPercent),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            headline,
            style: GoogleFonts.manrope(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontSize: 14.5,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA4A9BD),
            ),
          ),
          const SizedBox(height: 22),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FilledButton(
              key: const ValueKey('home-continue-lesson'),
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(_buttonHeight),
                textStyle: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Continue Lesson $nextLessonNumber'),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.arrowRight, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            key: const ValueKey('home-open-ai-lab'),
            onPressed: onOpenAiLab,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(_buttonHeight),
              shape: const StadiumBorder(),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
              textStyle: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.sparkles, size: 18),
                SizedBox(width: 8),
                Text('Open AI Lab'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: const StadiumBorder(),
      ),
      child: Text(
        "TODAY'S FOCUS",
        style: GoogleFonts.manrope(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MasteryChip extends StatelessWidget {
  const _MasteryChip({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    const foreground = Color(0xFF052E22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const ShapeDecoration(
        color: AppColors.success,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percent% mastery',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(LucideIcons.trophy, size: 14, color: foreground),
        ],
      ),
    );
  }
}
