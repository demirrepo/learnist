import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

// Placeholder content copied from the design mockup until real data exists.
const _learningSpaceItems = [
  LearningSpaceItem(
    icon: LucideIcons.bookOpen,
    title: 'Mavzular',
    subtitle: '52 lessons',
    route: AppRoutes.topics,
  ),
  LearningSpaceItem(
    icon: LucideIcons.bot,
    title: 'AI Lab',
    subtitle: 'Prompt better',
    route: AppRoutes.aiLab,
  ),
  LearningSpaceItem(
    icon: LucideIcons.target,
    title: 'Check-up',
    subtitle: 'CEFR test',
    route: AppRoutes.levelCheck,
  ),
];

List<SnapshotStat> _snapshotStats(UserProgress progress, UserStats stats) => [
  SnapshotStat(
    value: '${stats.lessonsMastered}/${UserProgress.lastLesson}',
    label: 'Lessons mastered',
    icon: LucideIcons.bookOpen,
  ),
  SnapshotStat(
    value: '${progress.currentLesson}',
    label: 'Current lesson',
    icon: LucideIcons.play,
  ),
  SnapshotStat(
    value: progress.cefrLevel ?? 'N/A',
    label: 'CEFR estimate',
    icon: LucideIcons.shieldCheck,
  ),
  SnapshotStat(
    value: '${stats.trackedMistakes}',
    label: 'Tracked mistakes',
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
                  greeting: greetingFor(DateTime.now()),
                  firstName: firstNameFrom(fullName),
                  cefrLevel: progress.cefrLevel,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: HeroBannerCard(
                  masteryPercent: stats.currentLessonMastery,
                  headline:
                      'Your English grows every time you understand a mistake.',
                  subtitle:
                      'Keep the momentum going with your next guided practice.',
                  nextLessonNumber: lesson,
                  onContinue:
                      () => context.push(AppRoutes.lessonDetailFor(lesson)),
                  onOpenAiLab: () => context.go(AppRoutes.aiLab),
                ),
              ),
              const SizedBox(height: 32),
              LearningSpaceSection(
                items: _learningSpaceItems,
                horizontalPadding: _pagePadding,
                onItemTap: (item) => context.go(item.route),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: SnapshotGrid(stats: _snapshotStats(progress, stats)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _pagePadding),
                child: LessonMasteryProgress(
                  lessonLabel: 'Lesson $lesson',
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
String greetingFor(DateTime now) => switch (now.hour) {
  >= 5 && < 12 => 'Good morning',
  >= 12 && < 17 => 'Good afternoon',
  _ => 'Good evening',
};
