import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../models/user_progress.dart';
import '../models/user_stats.dart';
import '../router.dart';
import '../services/progress_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/home/hero_banner_card.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/learning_space_section.dart';
import '../widgets/home/lesson_mastery_progress.dart';
import '../widgets/home/snapshot_grid.dart';

const _pagePadding = 20.0;

List<LearningSpaceItem> _learningSpaceItems(AppLocalizations l10n) => [
  LearningSpaceItem(
    icon: LucideIcons.bookOpen,
    title: l10n.navTopics,
    subtitle: l10n.homeLessonCount(UserProgress.lastLesson),
    route: AppRoutes.topics,
  ),
  LearningSpaceItem(
    icon: LucideIcons.bot,
    title: l10n.navAiLab,
    subtitle: l10n.homePromptBetter,
    route: AppRoutes.aiLab,
  ),
  LearningSpaceItem(
    icon: LucideIcons.target,
    title: l10n.navCheckup,
    subtitle: l10n.homeCefrTest,
    route: AppRoutes.levelCheck,
  ),
];

List<SnapshotStat> _snapshotStats(
  AppLocalizations l10n,
  UserProgress progress,
  UserStats stats,
) => [
  SnapshotStat(
    value: '${stats.lessonsMastered}/${UserProgress.lastLesson}',
    label: l10n.statLessonsMastered,
    icon: LucideIcons.bookOpen,
  ),
  SnapshotStat(
    value: '${progress.currentLesson}',
    label: l10n.statCurrentLesson,
    icon: LucideIcons.play,
  ),
  SnapshotStat(
    value: progress.cefrLevel ?? l10n.notAvailable,
    label: l10n.statCefrEstimate,
    icon: LucideIcons.shieldCheck,
  ),
  SnapshotStat(
    value: '${stats.trackedMistakes}',
    label: l10n.statTrackedMistakes,
    icon: LucideIcons.rotateCcw,
  ),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullName = ref.watch(supabaseServiceProvider).currentUserFullName;
    // Defaults while loading or if the fetch fails; Home never blocks on it.
    final progress =
        ref.watch(userProgressProvider).value ?? const UserProgress();
    final stats = ref.watch(userStatsProvider).value ?? const UserStats();
    final lesson = progress.currentLesson;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: HomeHeader(
                  greeting: greetingFor(DateTime.now(), l10n),
                  firstName: firstNameFrom(fullName),
                  cefrLevel: progress.cefrLevel,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: HeroBannerCard(
                  masteryPercent: stats.currentLessonMastery,
                  headline: l10n.homeHeadline,
                  subtitle: l10n.homeSubtitle,
                  nextLessonNumber: lesson,
                  onContinue:
                      () => context.push(AppRoutes.lessonDetailFor(lesson)),
                  onOpenAiLab: () => context.go(AppRoutes.aiLab),
                ),
              ),
              const SizedBox(height: 32),
              LearningSpaceSection(
                items: _learningSpaceItems(l10n),
                horizontalPadding: _pagePadding,
                onItemTap: (item) => context.go(item.route),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: SnapshotGrid(
                  stats: _snapshotStats(l10n, progress, stats),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: LessonMasteryProgress(
                  lessonLabel: l10n.lessonLabel(lesson),
                  progress: stats.currentLessonMastery / 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// First word of the sign-up `full_name`, or "Demir" when it's missing.
@visibleForTesting
String firstNameFrom(String? fullName) {
  final trimmed = fullName?.trim() ?? '';
  if (trimmed.isEmpty) return 'Demir';
  return trimmed.split(RegExp(r'\s+')).first;
}

@visibleForTesting
String greetingFor(DateTime now, AppLocalizations l10n) => switch (now.hour) {
  >= 5 && < 12 => l10n.greetingMorning,
  >= 12 && < 17 => l10n.greetingAfternoon,
  _ => l10n.greetingEvening,
};
