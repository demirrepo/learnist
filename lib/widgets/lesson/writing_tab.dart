import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'lesson_common.dart';

// Placeholder content until lessons come from the backend.
const _lenses = [
  (level: 'A1', focus: 'Short, correct sentences with am / is / are.'),
  (level: 'A2', focus: 'Link ideas with and, but and because.'),
  (level: 'B1', focus: 'Add details and reasons in clear paragraphs.'),
  (level: 'B2', focus: 'Vary your vocabulary and sentence structure.'),
];

const _minWords = 80;
const _maxWords = 120;

class WritingTab extends StatefulWidget {
  const WritingTab({super.key});

  @override
  State<WritingTab> createState() => _WritingTabState();
}

class _WritingTabState extends State<WritingTab> {
  int _wordCount = 0;

  void _onChanged(String text) {
    final count = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;
    if (count != _wordCount) setState(() => _wordCount = count);
  }

  @override
  Widget build(BuildContext context) {
    final inRange = _wordCount >= _minWords && _wordCount <= _maxWords;

    return LessonTabBody(
      children: [
        LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LessonPrompt(
                tagIcon: LucideIcons.pencil,
                tag: 'Writing task',
                title: 'An email to your new group',
                body: 'Write a short email to your new English group. '
                    'Introduce yourself, describe your family and say what '
                    'you like about your university. Write $_minWords–'
                    '$_maxWords words.',
              ),
              const SizedBox(height: 18),
              LessonTextField(
                hint: 'Hi everyone, my name is…',
                minLines: 10,
                maxLines: 20,
                onChanged: _onChanged,
              ),
              const SizedBox(height: 8),
              Text(
                '$_wordCount / $_minWords–$_maxWords words',
                textAlign: TextAlign.end,
                style: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: inRange ? AppColors.success : AppColors.hint,
                ),
              ),
              const SizedBox(height: 12),
              LessonActionRow(
                primaryLabel: 'Assess my writing',
                onPrimary: () => showComingSoon(context, 'Writing assessment'),
                onAskAi: () => showComingSoon(context, 'Ask AI'),
              ),
            ],
          ),
        ),
        const _CefrLenses(),
      ],
    );
  }
}

class _CefrLenses extends StatelessWidget {
  const _CefrLenses();

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.layers, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'CEFR lenses',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your writing is assessed through these levels.',
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.hint,
            ),
          ),
          for (final lens in _lenses) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    lens.level,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lens.focus,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
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
