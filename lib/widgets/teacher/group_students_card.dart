import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/teacher_dashboard.dart';
import '../../theme/app_theme.dart';
import 'teacher_common.dart';

/// One group: name, class credentials and its students. Wide cards show a
/// table; narrow ones stack a tile per student.
class GroupStudentsCard extends StatelessWidget {
  const GroupStudentsCard({
    super.key,
    required this.group,
    required this.onViewStudent,
  });

  final ClassGroup group;
  final ValueChanged<TeacherStudent> onViewStudent;

  static const _tableWidth = 680.0;

  @override
  Widget build(BuildContext context) {
    return TeacherCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _tableWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GroupHeader(group: group),
              const SizedBox(height: 16),
              if (group.students.isEmpty)
                const TeacherEmptyText('No students connected yet.')
              else if (wide)
                _StudentTable(students: group.students, onView: onViewStudent)
              else
                for (final (i, student) in group.students.indexed) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _StudentTile(
                    student: student,
                    onView: () => onViewStudent(student),
                  ),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final ClassGroup group;

  @override
  Widget build(BuildContext context) {
    final muted = GoogleFonts.manrope(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );
    final bold = muted.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );
    final count = group.students.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: muted,
                  children: [
                    const TextSpan(text: 'Class login: '),
                    TextSpan(text: group.login, style: bold),
                    const TextSpan(text: ' • password: '),
                    TextSpan(text: group.password, style: bold),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.teacherAccentSoft,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            count == 1 ? '1 student' : '$count students',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.teacherAccent,
            ),
          ),
        ),
      ],
    );
  }
}

// Flex weights shared by the header row and every student row.
const _columnFlex = [6, 4, 3, 3];
const _actionWidth = 96.0;

class _StudentTable extends StatelessWidget {
  const _StudentTable({required this.students, required this.onView});

  final List<TeacherStudent> students;
  final ValueChanged<TeacherStudent> onView;

  @override
  Widget build(BuildContext context) {
    final headerStyle = GoogleFonts.manrope(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: AppColors.textMuted,
    );
    const divider = Divider(height: 1, color: AppColors.border);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableRow(
          cells: [
            for (final label in const [
              'TALABA',
              'CURRENT LESSON',
              'MASTERY',
              'CEFR',
            ])
              Text(label, style: headerStyle),
          ],
          action: Text('ACTION', style: headerStyle, textAlign: TextAlign.end),
        ),
        divider,
        for (final student in students) ...[
          _TableRow(
            cells: [
              _NameCell(student: student),
              _BodyText('L${student.currentLesson}'),
              _BodyText('${student.masteryPercent}%'),
              _BodyText(student.cefrLevel ?? '—'),
            ],
            action: Align(
              alignment: Alignment.centerRight,
              child: _ViewButton(onPressed: () => onView(student)),
            ),
          ),
          divider,
        ],
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells, required this.action});

  final List<Widget> cells;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Row(
        children: [
          for (final (i, cell) in cells.indexed)
            Expanded(flex: _columnFlex[i], child: cell),
          SizedBox(width: _actionWidth, child: action),
        ],
      ),
    );
  }
}

/// Phone layout: name and View on top, the table's columns as chips below.
class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.onView});

  final TeacherStudent student;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _NameCell(student: student)),
              _ViewButton(onPressed: onView),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip('Lesson', 'L${student.currentLesson}'),
              _InfoChip('Mastery', '${student.masteryPercent}%'),
              _InfoChip('CEFR', student.cefrLevel ?? '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameCell extends StatelessWidget {
  const _NameCell({required this.student});

  final TeacherStudent student;

  @override
  Widget build(BuildContext context) {
    final username = student.username;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          student.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (username != null)
          Text(
            '@$username',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.manrope(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.teacherAccentSoft,
        foregroundColor: AppColors.teacherAccent,
        minimumSize: const Size(72, 40),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: const Text('View'),
    );
  }
}
