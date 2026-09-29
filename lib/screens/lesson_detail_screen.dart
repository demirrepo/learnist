import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/lesson_model.dart';
import '../services/lesson_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lesson/grammar_tab.dart';
import '../widgets/lesson/listening_tab.dart';
import '../widgets/lesson/reading_tab.dart';
import '../widgets/lesson/speaking_tab.dart';
import '../widgets/lesson/writing_tab.dart';
import '../widgets/load_problem_view.dart';

const _tabs = [
  'Grammatika',
  "O'qish",
  'Tinglab tushunish',
  'Yozish',
  'Gapirish',
];

/// One live lesson from the `lessons` table, split into five skill tabs.
class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  /// `lesson_number` of the lesson to show, from `/lesson-detail/:id`.
  final int lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  late Future<Lesson> _lessonFuture;

  @override
  void initState() {
    super.initState();
    _lessonFuture = _fetch();
  }

  @override
  void didUpdateWidget(LessonDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId) _lessonFuture = _fetch();
  }

  Future<Lesson> _fetch() =>
      ref.read(lessonServiceProvider).getLessonByNumber(widget.lessonId);

  void _retry() {
    // Block body: setState must not return the Future.
    setState(() {
      _lessonFuture = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Lesson>(
      future: _lessonFuture,
      builder: (context, snapshot) {
        // Checked first so a retry shows the spinner, not the old error.
        if (snapshot.connectionState != ConnectionState.done) {
          return _StatusScaffold(
            title: 'Lesson ${widget.lessonId}',
            child: const CircularProgressIndicator(color: AppColors.deepPurple),
          );
        }
        if (snapshot.hasError) {
          return _StatusScaffold(
            title: 'Lesson ${widget.lessonId}',
            child: LoadProblemView(
              message: lessonLoadErrorMessage(snapshot.error!),
              onRetry: _retry,
            ),
          );
        }
        return _LessonView(lesson: snapshot.requireData);
      },
    );
  }
}

AppBar _lessonAppBar({required Widget title, PreferredSizeWidget? bottom}) {
  return AppBar(
    backgroundColor: AppColors.background,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    foregroundColor: AppColors.textPrimary,
    titleSpacing: 0,
    title: title,
    bottom: bottom,
  );
}

TextStyle get _titleStyle => GoogleFonts.manrope(
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: AppColors.textPrimary,
);

/// Loading and error states keep the app bar so Back always works.
class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _lessonAppBar(title: Text(title, style: _titleStyle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
          child: child,
        ),
      ),
    );
  }
}

class _LessonView extends StatelessWidget {
  const _LessonView({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _lessonAppBar(
          title: Row(
            children: [
              Flexible(
                child: Text(
                  'Lesson ${lesson.lessonNumber}: ${lesson.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _titleStyle,
                ),
              ),
              const SizedBox(width: 10),
              _CefrPill(level: lesson.cefrLevel),
              const SizedBox(width: 16),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: _LessonTabBar(),
          ),
        ),
        body: TabBarView(
          children: [
            GrammarTab(lesson: lesson),
            ReadingTab(lesson: lesson),
            ListeningTab(lesson: lesson),
            WritingTab(lesson: lesson),
            SpeakingTab(lesson: lesson),
          ],
        ),
      ),
    );
  }
}

class _CefrPill extends StatelessWidget {
  const _CefrPill({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'CEFR level $level',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          level,
          style: GoogleFonts.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Scrollable row of pill tabs; the selected tab is filled purple.
class _LessonTabBar extends StatelessWidget {
  const _LessonTabBar();

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(99));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: radius,
        ),
        splashBorderRadius: radius,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          for (final label in _tabs)
            Tab(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(label),
              ),
            ),
        ],
      ),
    );
  }
}
