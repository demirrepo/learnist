import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../models/lesson_model.dart';
import '../../services/ask_ai_service.dart';
import '../../theme/ai_markdown_style.dart';
import '../../theme/app_theme.dart';

/// The lesson sections that offer Ask AI.
enum AskAiSection {
  grammar('Grammar'),
  writing('Writing');

  const AskAiSection(this.englishName);

  /// Sent to the AI, which works in English whatever the interface language.
  final String englishName;

  String localizedName(AppLocalizations l10n) => switch (this) {
    grammar => l10n.lessonTabGrammar,
    writing => l10n.lessonTabWriting,
  };
}

/// What the student's question is asked about, e.g.
/// "Lesson 49: Download the app | Grammar | Complex clauses & connectors".
/// Shown in the dialog exactly as it is sent.
String askAiContext(Lesson lesson, AskAiSection section) =>
    'Lesson ${lesson.lessonNumber}: ${lesson.title} | '
    '${section.englishName} | ${lesson.grammarFocus}';

Future<void> showAskAiDialog(
  BuildContext context, {
  required Lesson lesson,
  required AskAiSection section,
}) => showDialog<void>(
  context: context,
  barrierColor: Colors.black.withValues(alpha: 0.55),
  builder: (_) => AskAiDialog(lesson: lesson, section: section),
);

/// Asks Learnist AI a free-form question with the lesson attached as
/// context, and shows the answer below the question.
class AskAiDialog extends ConsumerStatefulWidget {
  const AskAiDialog({super.key, required this.lesson, required this.section});

  final Lesson lesson;
  final AskAiSection section;

  @override
  ConsumerState<AskAiDialog> createState() => _AskAiDialogState();
}

class _AskAiDialogState extends ConsumerState<AskAiDialog> {
  final _question = TextEditingController();
  bool _asking = false;
  String? _answer;
  String? _error;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    if (_asking) return;
    final l10n = context.l10n;
    final question = _question.text.trim();
    if (question.isEmpty) {
      setState(() => _error = l10n.askAiEmptyQuestion);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _asking = true;
      _error = null;
    });
    try {
      final answer = await ref
          .read(askAiServiceProvider)
          .ask(question, askAiContext(widget.lesson, widget.section));
      if (!mounted) return;
      setState(() => _answer = answer);
    } catch (error) {
      if (kDebugMode) debugPrint('[AskAI] $error');
      if (!mounted) return;
      setState(() {
        _error = switch (error) {
          AskAiException(failure: AskAiFailure.offline) => l10n.errorOffline,
          AskAiException(failure: AskAiFailure.busy) => l10n.askAiBusy,
          _ => l10n.askAiFailed,
        };
      });
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final answer = _answer;
    final error = _error;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 24),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  eyebrow: l10n.askAiEyebrow,
                  title: l10n.askAiTitle(widget.section.localizedName(l10n)),
                ),
                const SizedBox(height: 16),
                _ContextBanner(
                  label: l10n.askAiContextAttached,
                  context: askAiContext(widget.lesson, widget.section),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey('ask-ai-question'),
                  controller: _question,
                  readOnly: _asking,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 1000,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.manrope(
                    fontSize: 14.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.askAiHint(widget.lesson.lessonNumber),
                    hintMaxLines: 6,
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.hint,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _GradientButton(
                  label: l10n.askAiSubmit,
                  loading: _asking,
                  onPressed: _asking ? null : _ask,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ],
                if (_asking) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.askAiThinking,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ] else if (answer != null) ...[
                  const SizedBox(height: 16),
                  _AnswerBox(answer: answer),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hint,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          color: AppColors.textMuted,
          icon: const Icon(LucideIcons.x, size: 22),
        ),
      ],
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({required this.label, required this.context});

  final String label;
  final String context;

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.paperclip, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label ',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: context),
                ],
              ),
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width purple-to-blue button; shows a spinner while [loading].
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  static const _gradient = LinearGradient(
    colors: [AppColors.deepPurple, Color(0xFF3B82F6)],
  );

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.deepPurple.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const ValueKey('ask-ai-submit'),
            onTap: onPressed,
            borderRadius: radius,
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      LucideIcons.sparkles,
                      size: 20,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('ask-ai-answer'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Learnist AI',
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // The model answers in Markdown. The dialog scrolls, so a long
          // answer stays readable without its own scroll area.
          MarkdownBody(
            data: answer,
            selectable: true,
            styleSheet: aiMarkdownStyleSheet(context),
          ),
        ],
      ),
    );
  }
}
