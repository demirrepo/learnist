import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';

enum TopicStatus { mastered, inProgress, locked }

/// One lesson in the 52-lesson pathway.
class Topic {
  const Topic({
    required this.title,
    required this.grammarFocus,
    required this.semester,
    required this.status,
    this.masteryPercent = 0,
  });

  final String title;
  final String grammarFocus;
  final int semester;
  final TopicStatus status;

  /// 0 – 100; ignored when [status] is [TopicStatus.locked].
  final int masteryPercent;

  bool get isLocked => status == TopicStatus.locked;

  String get statusLabel =>
      isLocked ? 'Locked' : '${masteryPercent.clamp(0, 100)}% mastery';
}

/// White roadmap card: status circle on the left; title, grammar focus,
/// mastery and semester pill stacked on the right.
class TopicCard extends StatelessWidget {
  const TopicCard({super.key, required this.topic, this.onTap});

  final Topic topic;

  /// Ignored for locked topics.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    final locked = topic.isLocked;

    return Semantics(
      button: !locked && onTap != null,
      label: '${topic.title}. ${topic.grammarFocus}. '
          '${topic.statusLabel}. Semester ${topic.semester}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: locked ? null : onTap,
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
                _StatusCircle(locked: locked),
                const SizedBox(width: 14),
                Expanded(child: _Details(topic: topic)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: locked ? AppColors.track : AppColors.primarySoft,
      ),
      child: Icon(
        locked ? LucideIcons.lock : LucideIcons.check,
        size: 20,
        color: locked ? AppColors.hint : AppColors.primary,
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final locked = topic.isLocked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topic.title,
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
          topic.grammarFocus,
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
        Row(
          children: [
            Expanded(
              child: Text(
                topic.statusLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: locked ? AppColors.hint : AppColors.success,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SemesterPill(semester: topic.semester),
          ],
        ),
      ],
    );
  }
}

class _SemesterPill extends StatelessWidget {
  const _SemesterPill({required this.semester});

  final int semester;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'Sem $semester',
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
