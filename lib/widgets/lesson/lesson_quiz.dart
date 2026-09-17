import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../theme/app_theme.dart';
import 'lesson_common.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}

/// Multiple-choice quiz for the Reading and Listening tabs.
///
/// Checking results only reports the aggregate score. Options are never
/// marked right or wrong, so learners can't copy answers on a retry.
class LessonQuiz extends StatefulWidget {
  const LessonQuiz({super.key, required this.questions});

  final List<QuizQuestion> questions;

  @override
  State<LessonQuiz> createState() => _LessonQuizState();
}

class _LessonQuizState extends State<LessonQuiz> {
  final Map<int, int> _answers = {};

  void _checkResults() {
    final total = widget.questions.length;

    if (_answers.length < total) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Answer all $total questions to check your results.'),
          ),
        );
      return;
    }

    var correct = 0;
    for (var i = 0; i < total; i++) {
      if (_answers[i] == widget.questions[i].correctIndex) correct++;
    }

    showDialog<void>(
      context: context,
      builder: (context) => _ScoreDialog(correct: correct, total: total),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < questions.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _QuestionCard(
            number: i + 1,
            question: questions[i],
            selectedIndex: _answers[i],
            onSelected: (option) => setState(() => _answers[i] = option),
          ),
        ],
        const SizedBox(height: 16),
        LessonPrimaryButton(
          label: 'Natijani tekshirish',
          icon: LucideIcons.checkCircle,
          onPressed: _checkResults,
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int number;
  final QuizQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LessonCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$number. ${question.prompt}',
            style: GoogleFonts.manrope(
              fontSize: 15.5,
              height: 1.4,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < question.options.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _OptionTile(
              label: question.options[i],
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

/// Selection is the only visual state; there is deliberately no
/// correct/incorrect styling.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.background,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _RadioDot(selected: selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.hint,
          width: selected ? 6 : 1.5,
        ),
      ),
    );
  }
}

class _ScoreDialog extends StatelessWidget {
  const _ScoreDialog({required this.correct, required this.total});

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: lessonCardRadius),
      icon: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primarySoft,
        ),
        child: const Icon(
          LucideIcons.clipboardCheck,
          color: AppColors.primary,
          size: 26,
        ),
      ),
      title: Text(
        '$correct/$total correct',
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Review the text and try again to improve your score.',
        textAlign: TextAlign.center,
        style: lessonBodyStyle,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
