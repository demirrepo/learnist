import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/lesson_model.dart';
import '../../theme/app_theme.dart';

/// White roadmap card: lesson number (or a lock) on the left; title, grammar
/// focus, CEFR level and semester stacked on the right.
///
/// Locked cards stay tappable so the screen can explain why they're locked.
class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.lesson,
    required this.locked,
    required this.onTap,
  });

  final Lesson lesson;
  final bool locked;
  final VoidCallback onTap;

  String get displayTitle => '${lesson.lessonNumber}. ${lesson.title}';

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));

    return Semantics(
      button: true,
      label:
          '$displayTitle. ${lesson.grammarFocus}. '
          'CEFR ${lesson.cefrLevel}. Semester ${lesson.semester}'
          '${locked ? '. Qulflangan' : ''}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCircle(number: lesson.lessonNumber, locked: locked),
                const SizedBox(width: 14),
                Expanded(
                  child: _Details(
                    title: displayTitle,
                    lesson: lesson,
                    locked: locked,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({required this.number, required this.locked});

  final int number;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: locked ? AppColors.track : AppColors.primarySoft,
      ),
      child:
          locked
              ? const Icon(LucideIcons.lock, size: 18, color: AppColors.hint)
              : Text(
                '$number',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.title,
    required this.lesson,
    required this.locked,
  });

  final String title;
  final Lesson lesson;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 15.5,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: locked ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lesson.grammarFocus,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: AppColors.hint,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _Pill(
              label: lesson.cefrLevel,
              colors: cefrColors(lesson.cefrLevel),
            ),
            _Pill(
              label: 'Semester ${lesson.semester}',
              colors: (
                background: AppColors.primarySoft,
                foreground: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.colors});

  final String label;
  final PillColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.foreground,
        ),
      ),
    );
  }
}
