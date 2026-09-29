import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../models/lesson_model.dart';
import '../models/user_progress.dart';
import '../router.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/load_problem_view.dart';
import '../widgets/topics/topic_card.dart';

const _pagePadding = 20.0;

/// The live 52-lesson pathway from the Supabase `lessons` table.
class TopicsScreen extends ConsumerStatefulWidget {
  const TopicsScreen({super.key});

  @override
  ConsumerState<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends ConsumerState<TopicsScreen> {
  // Created once and replaced only on retry, so rebuilds (e.g. typing in
  // the search field) don't refetch.
  late Future<List<Lesson>> _lessonsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _fetch();
  }

  Future<List<Lesson>> _fetch() =>
      ref.read(lessonServiceProvider).getAllLessons();

  void _retry() {
    // Block body: setState must not return the Future.
    setState(() {
      _lessonsFuture = _fetch();
    });
  }

  List<Lesson> _filter(List<Lesson> lessons) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return lessons;
    return [
      for (final lesson in lessons)
        if ('${lesson.lessonNumber}. ${lesson.title}'.toLowerCase().contains(
              query,
            ) ||
            lesson.grammarFocus.toLowerCase().contains(query))
          lesson,
    ];
  }

  void _openLesson(Lesson lesson, {required bool locked}) {
    if (locked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.lock, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(context.l10n.topicLockedMessage)),
              ],
            ),
          ),
        );
      return;
    }
    context.push(AppRoutes.lessonDetailFor(lesson.lessonNumber));
  }

  @override
  Widget build(BuildContext context) {
    // Teachers bypass every unlock prerequisite.
    final isTeacher = ref.watch(supabaseServiceProvider).isTeacher;
    // Students can open every lesson up to `current_lesson`.
    final currentLesson =
        ref.watch(userProgressProvider).value?.currentLesson ??
        UserProgress.firstLesson;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: FutureBuilder<List<Lesson>>(
            future: _lessonsFuture,
            builder: (context, snapshot) {
              return CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      _pagePadding,
                      16,
                      _pagePadding,
                      20,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _Header(
                        onSearchChanged:
                            (value) => setState(() => _query = value),
                      ),
                    ),
                  ),
                  ..._buildBody(
                    snapshot,
                    isTeacher: isTeacher,
                    currentLesson: currentLesson,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(
    AsyncSnapshot<List<Lesson>> snapshot, {
    required bool isTeacher,
    required int currentLesson,
  }) {
    // Checked first so a retry shows the spinner, not the previous error.
    if (snapshot.connectionState != ConnectionState.done) {
      return const [
        _CenteredSliver(
          child: CircularProgressIndicator(color: AppColors.deepPurple),
        ),
      ];
    }
    if (snapshot.hasError) {
      return [
        _CenteredSliver(
          child: LoadProblemView(
            icon: LucideIcons.wifiOff,
            message: lessonLoadErrorMessage(snapshot.error!),
            onRetry: _retry,
          ),
        ),
      ];
    }

    final all = snapshot.data ?? const <Lesson>[];
    if (all.isEmpty) {
      // Also what RLS returns when the session has expired.
      return [
        _CenteredSliver(
          child: LoadProblemView(
            icon: LucideIcons.bookOpen,
            message: context.l10n.topicsEmpty,
            onRetry: _retry,
          ),
        ),
      ];
    }

    final lessons = _filter(all);
    if (lessons.isEmpty) {
      return const [SliverToBoxAdapter(child: _EmptyResults())];
    }

    final items = _withSemesterHeaders(lessons);
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(_pagePadding, 0, _pagePadding, 32),
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            if (item case _SemesterHeader(:final semester)) {
              return _SemesterTitle(semester: semester, first: index == 0);
            }
            final lesson = (item as _LessonItem).lesson;
            final locked = !isTeacher && lesson.lessonNumber > currentLesson;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TopicCard(
                lesson: lesson,
                locked: locked,
                onTap: () => _openLesson(lesson, locked: locked),
              ),
            );
          },
        ),
      ),
    ];
  }
}

sealed class _ListItem {
  const _ListItem();
}

class _SemesterHeader extends _ListItem {
  const _SemesterHeader(this.semester);

  final int semester;
}

class _LessonItem extends _ListItem {
  const _LessonItem(this.lesson);

  final Lesson lesson;
}

/// Inserts a header wherever the semester changes; lessons arrive ordered.
List<_ListItem> _withSemesterHeaders(List<Lesson> lessons) {
  final items = <_ListItem>[];
  int? semester;
  for (final lesson in lessons) {
    if (lesson.semester != semester) {
      semester = lesson.semester;
      items.add(_SemesterHeader(lesson.semester));
    }
    items.add(_LessonItem(lesson));
  }
  return items;
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchChanged});

  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.topicsEyebrow,
          style: GoogleFonts.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.topicsTitle,
          style: GoogleFonts.manrope(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.topicsSemesters,
          style: GoogleFonts.manrope(
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: context.l10n.topicsSearchHint,
            prefixIcon: Icon(LucideIcons.search, size: 20),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _SemesterTitle extends StatelessWidget {
  const _SemesterTitle({required this.semester, required this.first});

  final int semester;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 12, bottom: 12),
      child: Text(
        context.l10n.semesterLabel(semester),
        style: GoogleFonts.manrope(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Fills the rest of the viewport and centers [child] in it.
class _CenteredSliver extends StatelessWidget {
  const _CenteredSliver({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
          child: child,
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Text(
        context.l10n.topicsNoMatch,
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.hint,
        ),
      ),
    );
  }
}
