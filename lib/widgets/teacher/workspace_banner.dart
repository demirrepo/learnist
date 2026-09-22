import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';

/// Dark "TEACHER WORKSPACE" banner with the create-group action and the
/// connected-students counter. The counter sits on the right when there is
/// room and drops below the text on phones.
class TeacherWorkspaceBanner extends StatelessWidget {
  const TeacherWorkspaceBanner({
    super.key,
    required this.connectedStudents,
    required this.onCreateGroup,
  });

  final int connectedStudents;
  final VoidCallback onCreateGroup;

  static const _sideBySideWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121829), Color(0xFF1E2358), Color(0xFF3D2FA8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.sidebar.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _sideBySideWidth;
          final counter = _StudentsCounter(count: connectedStudents);
          final text = _BannerText(wide: wide, onCreateGroup: onCreateGroup);

          return Padding(
            padding: EdgeInsets.all(wide ? 28 : 20),
            child:
                wide
                    ? Row(
                      children: [
                        Expanded(child: text),
                        const SizedBox(width: 32),
                        SizedBox(width: 150, child: counter),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [text, const SizedBox(height: 16), counter],
                    ),
          );
        },
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  const _BannerText({required this.wide, required this.onCreateGroup});

  final bool wide;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEACHER WORKSPACE',
          style: GoogleFonts.manrope(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: const Color(0xFF7DD3FC),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'See who is learning — and where they struggle.',
          style: GoogleFonts.manrope(
            fontSize: wide ? 34 : 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Create classes, connect students through a class login/password, '
          'and monitor lesson progress, CEFR history and recurring error '
          'categories.',
          style: GoogleFonts.manrope(
            fontSize: 14,
            height: 1.55,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFC7CBE0),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const ValueKey('teacher-create-group'),
          onPressed: onCreateGroup,
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Create group'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.teacherAccent,
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.manrope(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentsCounter extends StatelessWidget {
  const _StudentsCounter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count connected students',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.manrope(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'CONNECTED STUDENTS',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: const Color(0xFFC7CBE0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
