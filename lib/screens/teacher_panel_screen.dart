import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../widgets/teacher/class_overview_grid.dart';
import '../widgets/teacher/group_students_card.dart';
import '../widgets/teacher/student_detail_dialog.dart';
import '../widgets/teacher/teacher_common.dart';
import '../widgets/teacher/teacher_data.dart';
import '../widgets/teacher/workspace_banner.dart';

/// Keeps lines readable on desktop monitors.
const _maxContentWidth = 1100.0;

/// "O'qituvchi paneli": class overview, groups with their students and the
/// most common weaknesses across the teacher's classes.
class TeacherPanelScreen extends StatelessWidget {
  const TeacherPanelScreen({super.key, this.groups = sampleClassGroups});

  final List<ClassGroup> groups;

  List<TeacherStudent> get _students => [
    for (final group in groups) ...group.students,
  ];

  /// Distinct top weaknesses, most frequent first.
  List<(String, int)> get _commonWeaknesses {
    final counts = <String, int>{};
    for (final student in _students) {
      final weakness = student.topWeakness;
      if (weakness != null) counts[weakness] = (counts[weakness] ?? 0) + 1;
    }
    return [for (final e in counts.entries) (e.key, e.value)]
      ..sort((a, b) => b.$2.compareTo(a.$2));
  }

  void _createGroup(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text("Guruh yaratish tez orada qo'shiladi.")),
      );
  }

  @override
  Widget build(BuildContext context) {
    final students = _students;
    final weaknesses = _commonWeaknesses;
    final averageMastery =
        students.isEmpty
            ? 0
            : (students.fold(0, (sum, s) => sum + s.masteryPercent) /
                    students.length)
                .round();
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final pagePadding = wide ? 28.0 : 20.0;

    String plural(int n, String word) => n == 1 ? '1 $word' : '$n ${word}s';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pagePadding, 16, pagePadding, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: 20),
                  TeacherWorkspaceBanner(
                    connectedStudents: students.length,
                    onCreateGroup: () => _createGroup(context),
                  ),
                  const SizedBox(height: 28),
                  TeacherSectionTitle(
                    'Class overview',
                    caption:
                        '${plural(groups.length, 'group')} • '
                        '${plural(students.length, 'connected student')}',
                  ),
                  const SizedBox(height: 12),
                  ClassOverviewGrid(
                    stats: [
                      ('Students active', '${students.length}'),
                      ('Average mastery', '$averageMastery%'),
                      ('Groups', '${groups.length}'),
                      ('Common issues', '${weaknesses.length}'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const TeacherSectionTitle('Groups & students'),
                  const SizedBox(height: 12),
                  if (groups.isEmpty)
                    const TeacherCard(
                      child: TeacherEmptyText(
                        'No groups yet. Create one to connect students.',
                      ),
                    )
                  else
                    for (final (i, group) in groups.indexed) ...[
                      if (i > 0) const SizedBox(height: 12),
                      GroupStudentsCard(
                        group: group,
                        onViewStudent:
                            (student) =>
                                showStudentDetailDialog(context, student),
                      ),
                    ],
                  const SizedBox(height: 28),
                  const TeacherSectionTitle('Most common weaknesses'),
                  const SizedBox(height: 12),
                  _WeaknessesCard(weaknesses: weaknesses),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLASS ANALYTICS',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "O'qituvchi paneli",
          style: GoogleFonts.manrope(
            fontSize: 26,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _WeaknessesCard extends StatelessWidget {
  const _WeaknessesCard({required this.weaknesses});

  final List<(String, int)> weaknesses;

  @override
  Widget build(BuildContext context) {
    if (weaknesses.isEmpty) {
      return const TeacherCard(child: TeacherEmptyText('No error data yet.'));
    }

    return TeacherCard(
      child: Column(
        children: [
          for (final (i, (weakness, count)) in weaknesses.indexed) ...[
            if (i > 0) const Divider(height: 20, color: AppColors.border),
            Row(
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    weakness,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  count == 1 ? '1 student' : '$count students',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
