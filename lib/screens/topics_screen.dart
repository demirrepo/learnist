import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../router.dart';
import '../theme/app_theme.dart';
import '../widgets/topics/topic_card.dart';

const _pagePadding = 20.0;

// Placeholder content until lessons come from the backend. Lesson 1 matches
// the web platform; lessons 2–6 are stand-ins to show every card state.
const _topics = [
  Topic(
    title: 'Lesson 1. Hello, everybody!',
    grammarFocus: 'Subject pronouns + am / is / are',
    semester: 1,
    status: TopicStatus.mastered,
    masteryPercent: 100,
  ),
  Topic(
    title: 'Lesson 2. Where are you from?',
    grammarFocus: 'Questions and negatives with to be',
    semester: 1,
    status: TopicStatus.inProgress,
    masteryPercent: 85,
  ),
  Topic(
    title: 'Lesson 3. My family and friends',
    grammarFocus: 'Possessive adjectives + possessive ’s',
    semester: 1,
    status: TopicStatus.locked,
  ),
  Topic(
    title: 'Lesson 4. A day in my life',
    grammarFocus: 'Present Simple: positive and negative',
    semester: 1,
    status: TopicStatus.locked,
  ),
  Topic(
    title: 'Lesson 5. Do you like it?',
    grammarFocus: 'Present Simple questions + short answers',
    semester: 1,
    status: TopicStatus.locked,
  ),
  Topic(
    title: 'Lesson 6. There is a café near here',
    grammarFocus: 'There is / there are + some / any',
    semester: 1,
    status: TopicStatus.locked,
  ),
];

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  String _query = '';

  List<Topic> get _visibleTopics {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _topics;
    return [
      for (final topic in _topics)
        if (topic.title.toLowerCase().contains(query) ||
            topic.grammarFocus.toLowerCase().contains(query))
          topic,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final topics = _visibleTopics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    onSearchChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
              if (topics.isEmpty)
                const SliverToBoxAdapter(child: _EmptyResults())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    _pagePadding,
                    0,
                    _pagePadding,
                    32,
                  ),
                  sliver: SliverList.separated(
                    itemCount: topics.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => TopicCard(
                      topic: topics[index],
                      // Every unlocked card opens the static Lesson 1
                      // screen until lessons come from the backend.
                      onTap: () => context.go(AppRoutes.lesson),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
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
          'MAVZULAR',
          style: GoogleFonts.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '52-lesson pathway',
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
          'Semester 1: Lessons 1-30 • Semester 2: Lessons 31-52',
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
          decoration: const InputDecoration(
            hintText: 'Search lessons',
            prefixIcon: Icon(LucideIcons.search, size: 20),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
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
        'No lessons match your search.',
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
