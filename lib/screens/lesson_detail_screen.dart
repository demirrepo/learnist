import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/lesson/grammar_tab.dart';
import '../widgets/lesson/listening_tab.dart';
import '../widgets/lesson/reading_tab.dart';
import '../widgets/lesson/speaking_tab.dart';
import '../widgets/lesson/writing_tab.dart';

const _tabs = [
  'Grammatika',
  "O'qish",
  'Tinglab tushunish',
  'Yozish',
  'Gapirish',
];

/// One lesson split into five skill tabs. Content is static placeholder
/// data for Lesson 1 until lessons come from the backend.
class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({
    super.key,
    this.title = 'Lesson 1: Hello, everybody!',
    this.cefrLevel = 'A1',
  });

  final String title;
  final String cefrLevel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: AppColors.textPrimary,
          titleSpacing: 0,
          title: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CefrPill(level: cefrLevel),
              const SizedBox(width: 16),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: _LessonTabBar(),
          ),
        ),
        body: const TabBarView(
          children: [
            GrammarTab(),
            ReadingTab(),
            ListeningTab(),
            WritingTab(),
            SpeakingTab(),
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
