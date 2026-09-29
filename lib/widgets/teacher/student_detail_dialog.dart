import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/teacher_dashboard.dart';
import '../../services/teacher_service.dart';
import '../../theme/app_theme.dart';
import 'teacher_common.dart';

Future<void> showStudentDetailDialog(
  BuildContext context,
  TeacherStudent student,
) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.sidebar.withValues(alpha: 0.45),
    builder: (_) => StudentDetailDialog(student: student),
  );
}

/// Centered modal with a student's metrics and the section scores of each
/// lesson, fetched through [studentLessonsProvider] when it opens.
class StudentDetailDialog extends ConsumerWidget {
  const StudentDetailDialog({super.key, required this.student});

  final TeacherStudent student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(studentLessonsProvider(student.id));

    return Dialog(
      backgroundColor: const Color(0xFFF1F2F6),
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(student: student),
                  const SizedBox(height: 16),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: TeacherMetric(
                            label: 'Average mastery',
                            value: '${student.masteryPercent}%',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TeacherMetric(
                            label: 'CEFR',
                            value: student.cefrLevel ?? '—',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const TeacherSectionTitle('Lesson progress'),
                  const SizedBox(height: 12),
                  switch (lessons) {
                    AsyncData(value: final lessons) when lessons.isEmpty =>
                      const TeacherEmptyText('No lessons started yet.'),
                    AsyncData(value: final lessons) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, lesson) in lessons.indexed) ...[
                          if (i > 0) const SizedBox(height: 16),
                          _LessonProgressRow(lesson: lesson),
                        ],
                      ],
                    ),
                    AsyncError(:final error) => _LoadError(
                      message: teacherLoadErrorMessage(error),
                      onRetry:
                          () => ref.invalidate(
                            studentLessonsProvider(student.id),
                          ),
                    ),
                    _ => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  },
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                key: const ValueKey('student-detail-close'),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: const Icon(LucideIcons.x, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.student});

  final TeacherStudent student;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Leaves room for the close button.
      padding: const EdgeInsets.only(right: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STUDENT DETAIL',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.teacherAccent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            student.fullName,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (student.username case final username?) '@$username',
              'current Lesson ${student.currentLesson}',
            ].join(' • '),
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TeacherEmptyText(message),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: const Text('Qayta urinish'),
          style: TextButton.styleFrom(foregroundColor: AppColors.teacherAccent),
        ),
      ],
    );
  }
}

class _LessonProgressRow extends StatelessWidget {
  const _LessonProgressRow({required this.lesson});

  final LessonSkillProgress lesson;

  @override
  Widget build(BuildContext context) {
    final breakdown = [
      for (final (skill, percent) in lesson.skills) '$skill $percent%',
    ].join(' • ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${lesson.lessonNumber}',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.teacherAccent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.isCurrent
                    ? '${lesson.title} • in progress'
                    : lesson.title,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                breakdown,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
