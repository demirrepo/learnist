import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/teacher_dashboard.dart';
import '../services/teacher_service.dart';
import '../theme/app_theme.dart';
import '../widgets/load_problem_view.dart';
import '../widgets/teacher/class_overview_grid.dart';
import '../widgets/teacher/create_group_dialog.dart';
import '../widgets/teacher/group_students_card.dart';
import '../widgets/teacher/student_detail_dialog.dart';
import '../widgets/teacher/teacher_common.dart';
import '../widgets/teacher/workspace_banner.dart';

/// Keeps lines readable on desktop monitors.
const _maxContentWidth = 1100.0;

/// "O'qituvchi paneli": class overview and the teacher's groups with their
/// students, from [teacherDashboardProvider]. Pull down to refresh.
class TeacherPanelScreen extends ConsumerWidget {
  const TeacherPanelScreen({super.key});

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final name = await showCreateGroupDialog(context);
    if (name == null) return;
    ref.invalidate(teacherDashboardProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("«$name» guruhi yaratildi.")));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(teacherDashboardProvider);
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final pagePadding = wide ? 28.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              ref.invalidate(teacherDashboardProvider);
              await ref.read(teacherDashboardProvider.future);
            } catch (error) {
              // The last data stays on screen; say why it didn't update.
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(teacherLoadErrorMessage(error))),
                );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      connectedStudents: dashboard.value?.totalStudents ?? 0,
                      onCreateGroup: () => _createGroup(context, ref),
                    ),
                    const SizedBox(height: 28),
                    // Keeps the last data while a refresh is running.
                    switch (dashboard) {
                      AsyncValue(:final value?) => _DashboardBody(
                        dashboard: value,
                      ),
                      AsyncError(:final error) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: LoadProblemView(
                          message: teacherLoadErrorMessage(error),
                          onRetry:
                              () => ref.invalidate(teacherDashboardProvider),
                        ),
                      ),
                      _ => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    },
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.dashboard});

  final TeacherDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final groups = dashboard.groups;

    String plural(int n, String word) => n == 1 ? '1 $word' : '$n ${word}s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TeacherSectionTitle(
          'Class overview',
          caption:
              '${plural(dashboard.totalGroups, 'group')} • '
              '${plural(dashboard.totalStudents, 'connected student')}',
        ),
        const SizedBox(height: 12),
        ClassOverviewGrid(
          stats: [
            ('Students active', '${dashboard.totalStudents}'),
            ('Average mastery', '${dashboard.averageMastery}%'),
            ('Groups', '${dashboard.totalGroups}'),
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
                  (student) => showStudentDetailDialog(context, student),
            ),
          ],
      ],
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
