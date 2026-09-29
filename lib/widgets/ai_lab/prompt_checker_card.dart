import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/openai_service.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';
import 'ai_lab_common.dart';

/// Free-text prompt box with a check button. Sends the prompt to the AI and
/// shows the feedback inline.
class PromptCheckerCard extends ConsumerStatefulWidget {
  const PromptCheckerCard({super.key});

  @override
  ConsumerState<PromptCheckerCard> createState() => _PromptCheckerCardState();
}

class _PromptCheckerCardState extends ConsumerState<PromptCheckerCard> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _aiFeedback;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_isLoading) return;
    final ai = ref.read(openaiServiceProvider);
    final unexpected = context.l10n.promptCheckerUnexpected;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _aiFeedback = null;
    });

    String? feedback;
    String? error;
    try {
      feedback = await ai.evaluatePrompt(_controller.text);
    } on OpenAIException catch (e) {
      error = e.message;
    } catch (_) {
      error = unexpected;
    }

    // The card can be disposed while the request is in flight.
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _aiFeedback = feedback;
    });

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const noBorder = OutlineInputBorder(
      borderRadius: aiLabCardRadius,
      borderSide: BorderSide.none,
    );
    final feedback = _aiFeedback;

    return AiLabCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.wand2,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.promptCheckerTitle,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_isLoading,
            minLines: 5,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: GoogleFonts.manrope(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            // Only the focused border comes from the app theme.
            decoration: InputDecoration(
              hintText: context.l10n.promptCheckerHint,
              fillColor: AppColors.track,
              border: noBorder,
              enabledBorder: noBorder,
              disabledBorder: noBorder,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isLoading ? null : _check,
            child: Text(context.l10n.promptCheckerButton),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 20),
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ] else if (feedback != null) ...[
            const SizedBox(height: 16),
            _FeedbackBox(feedback: feedback),
          ],
        ],
      ),
    );
  }
}

/// Soft purple panel holding the model's feedback.
class _FeedbackBox extends StatelessWidget {
  const _FeedbackBox({required this.feedback});

  final String feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: aiLabCardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                context.l10n.promptCheckerFeedback,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // The model answers in Markdown, so bold/lists/headings are rendered
          // rather than shown as raw asterisks. MarkdownBody (not Markdown)
          // because this sits inside an unbounded Column.
          MarkdownBody(
            data: feedback,
            selectable: true,
            styleSheet: _feedbackStyleSheet(context),
          ),
        ],
      ),
    );
  }

  /// Maps Markdown tags onto the app's type scale.
  ///
  /// `google_fonts` bakes the weight into the registered font family, so an
  /// inherited `fontWeight` alone would not pick up the bold face: `strong`
  /// and the headings need their own full `GoogleFonts.manrope` style.
  MarkdownStyleSheet _feedbackStyleSheet(BuildContext context) {
    final body = GoogleFonts.manrope(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
    final bold = GoogleFonts.manrope(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );

    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: body,
      strong: bold,
      em: body.copyWith(fontStyle: FontStyle.italic),
      listBullet: body,
      a: body.copyWith(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
      ),
      // The model rarely emits headings under a 4-sentence cap, but size them
      // down when it does so they don't tower over the card.
      h1: bold.copyWith(fontSize: 17),
      h2: bold.copyWith(fontSize: 16),
      h3: bold.copyWith(fontSize: 15),
      h4: bold,
      h5: bold,
      h6: bold,
      code: GoogleFonts.robotoMono(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      blockSpacing: 10,
      // The panel already pads the content; drop the theme's outer margins.
      h1Padding: EdgeInsets.zero,
      h2Padding: EdgeInsets.zero,
      h3Padding: EdgeInsets.zero,
      pPadding: EdgeInsets.zero,
    );
  }
}
