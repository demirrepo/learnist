import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/gemini_service.dart';
import '../../services/progress_service.dart';
import '../../theme/app_theme.dart';
import 'lesson_common.dart';
import 'section_score.dart';

const _emptyAnswerMessage = 'Avval javobingizni yozing.';
const _evaluationErrorMessage =
    "Baholashda xatolik yuz berdi. Iltimos qayta urinib ko'ring.";

/// Answer field, grading button and result for a Gemini-graded task.
///
/// On tap it sends the answer to [evaluate], saves the score as the
/// lesson's [section] score and shows "Mastery reached: X%" with the
/// feedback. Kept alive, so the answer and result survive scrolling away
/// and switching tabs.
class AiGradedTask extends ConsumerStatefulWidget {
  const AiGradedTask({
    super.key,
    required this.lessonNumber,
    required this.section,
    required this.buttonLabel,
    required this.hint,
    required this.evaluate,
    this.minLines = 4,
    this.maxLines = 8,
    this.fieldFooter,
    this.onAskAi,
  });

  final int lessonNumber;

  /// One of [lessonSections].
  final String section;
  final String buttonLabel;
  final String hint;
  final Future<AiEvaluation> Function(GeminiService gemini, String answer)
  evaluate;
  final int minLines;
  final int maxLines;

  /// Built under the field from the current answer, e.g. a word count.
  final Widget Function(String answer)? fieldFooter;

  /// Adds an "Ask AI" button beside the grading button.
  final VoidCallback? onAskAi;

  @override
  ConsumerState<AiGradedTask> createState() => _AiGradedTaskState();
}

class _AiGradedTaskState extends ConsumerState<AiGradedTask>
    with AutomaticKeepAliveClientMixin {
  final _answer = TextEditingController();
  bool _evaluating = false;
  AiEvaluation? _result;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _grade() async {
    if (_evaluating) return;
    final messenger = ScaffoldMessenger.of(context);
    final text = _answer.text;
    if (text.trim().isEmpty) {
      showLessonError(messenger, _emptyAnswerMessage);
      return;
    }

    // Read before the awaits: the student may leave the lesson meanwhile,
    // and the score must still be saved.
    final gemini = ref.read(geminiServiceProvider);
    final progress = ref.read(progressServiceProvider);
    final section = widget.section;
    final lessonNumber = widget.lessonNumber;
    FocusScope.of(context).unfocus();
    setState(() => _evaluating = true);

    final AiEvaluation result;
    try {
      result = await widget.evaluate(gemini, text);
    } catch (error) {
      if (kDebugMode) debugPrint('[Lesson] grading $section failed: $error');
      if (mounted) setState(() => _evaluating = false);
      showLessonError(messenger, _evaluationErrorMessage);
      return;
    }

    await saveSectionScoreOrWarn(
      progress: progress,
      messenger: messenger,
      lessonNumber: lessonNumber,
      section: section,
      score: result.score,
    );

    if (!mounted) return;
    setState(() {
      _evaluating = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final footer = widget.fieldFooter;
    final onAskAi = widget.onAskAi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LessonTextField(
          key: ValueKey('${widget.section}-answer'),
          hint: widget.hint,
          controller: _answer,
          readOnly: _evaluating,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
        ),
        if (footer != null) ...[
          const SizedBox(height: 8),
          ValueListenableBuilder(
            valueListenable: _answer,
            builder: (context, value, _) => footer(value.text),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 16),
        if (onAskAi != null)
          LessonActionRow(
            primaryLabel: widget.buttonLabel,
            onPrimary: _grade,
            primaryLoading: _evaluating,
            onAskAi: onAskAi,
          )
        else
          LessonPrimaryButton(
            label: widget.buttonLabel,
            onPressed: _grade,
            loading: _evaluating,
          ),
        if (_result case final result?) ...[
          const SizedBox(height: 18),
          _EvaluationResult(
            key: ValueKey('${widget.section}-result'),
            result: result,
          ),
        ],
      ],
    );
  }
}

/// "Mastery reached: X%" and Gemini's feedback. Green once the score
/// reaches the 80% the next lesson needs.
class _EvaluationResult extends StatelessWidget {
  const _EvaluationResult({super.key, required this.result});

  final AiEvaluation result;

  @override
  Widget build(BuildContext context) {
    final passed = result.score >= InsufficientScoreException.minAverage;
    final background = passed ? AppColors.successSoft : AppColors.primarySoft;
    final accent = passed ? AppColors.successDark : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: lessonCardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.award, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mastery reached: ${result.score}%',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.feedback,
            style: lessonBodyStyle.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
