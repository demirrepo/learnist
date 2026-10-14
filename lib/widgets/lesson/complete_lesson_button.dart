import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../router.dart';
import '../../services/progress_service.dart';
import '../../theme/app_theme.dart';

/// "Darsni yakunlash": unlocks the next lesson through `complete_lesson`,
/// then returns to the topics list. Failures, including a section average
/// under 80%, show in a red snackbar and leave the student on the lesson.
///
/// Only shown on the student's current lesson; see [SpeakingTab].
class CompleteLessonButton extends ConsumerStatefulWidget {
  const CompleteLessonButton({super.key, required this.lessonNumber});

  final int lessonNumber;

  @override
  ConsumerState<CompleteLessonButton> createState() =>
      _CompleteLessonButtonState();
}

class _CompleteLessonButtonState extends ConsumerState<CompleteLessonButton> {
  bool _saving = false;

  Future<void> _complete() async {
    if (_saving) return;
    // Taken before the await: the student may leave the lesson meanwhile,
    // and the progress refresh and snackbar must still happen.
    final container = ProviderScope.containerOf(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _saving = true);

    try {
      await ref
          .read(progressServiceProvider)
          .completeLesson(widget.lessonNumber);
    } catch (error) {
      if (mounted) setState(() => _saving = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            key: const ValueKey('complete-lesson-error'),
            backgroundColor: AppColors.danger,
            // Long enough to read the insufficient-score advice.
            duration: const Duration(seconds: 6),
            content: Text(lessonCompletionErrorMessage(error, l10n)),
          ),
        );
      return;
    }

    container.invalidate(userProgressProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.partyPopper,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.lessonUnlocked)),
            ],
          ),
        ),
      );
    if (mounted) context.go(AppRoutes.topics);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const ValueKey('complete-lesson'),
      onPressed: _saving ? null : _complete,
      icon:
          _saving
              ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
              : const Icon(LucideIcons.checkCircle2, size: 20),
      label: Text(
        context.l10n.lessonFinish,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
