import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/checkup.dart';
import '../models/user_progress.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lesson/lesson_quiz.dart';
import '../widgets/load_problem_view.dart';

const _pagePadding = 24.0;
const _cardGap = 24.0;
const _cardRadius = BorderRadius.all(Radius.circular(16));

/// Matches `assets/data/checkup_questions.json`.
const _questionCount = 30;
const _estimatedMinutes = 18;

/// Points on the growth chart; older checks drop off the left.
const _maxChartPoints = 6;

/// Ordered CEFR scale; a level's index is its height on the growth chart.
const _cefrLevels = UserProgress.cefrLevels;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// The CEFR level check-up.
///
/// Available (never taken, or the 10-day cooldown has passed): the
/// 30-question test. On cooldown: the countdown and the growth chart from
/// `checkup_history`. The server re-checks the cooldown on submit.
class CheckUpScreen extends ConsumerWidget {
  const CheckUpScreen({super.key, this.clock = DateTime.now});

  /// Source of "now"; tests pass a fixed time.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            _pagePadding,
            16,
            _pagePadding,
            _pagePadding + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const SizedBox(height: 20),
              const _InfoCard(
                questionCount: _questionCount,
                estimatedMinutes: _estimatedMinutes,
              ),
              const SizedBox(height: _cardGap),
              ...progress.when(
                loading: () => const [_LoadingCard()],
                error:
                    (error, _) => [
                      _ProblemCard(
                        message: checkupErrorMessage(error),
                        onRetry: () => ref.invalidate(userProgressProvider),
                      ),
                    ],
                data:
                    (progress) => switch (CheckupAvailability.at(
                      progress.lastCheckupDate,
                      clock(),
                    )) {
                      CheckupAvailable() => const [_CheckupTest()],
                      CheckupOnCooldown(:final daysRemaining) => [
                        _CooldownCard(daysRemaining: daysRemaining),
                        const SizedBox(height: _cardGap),
                        const _GrowthHistory(),
                      ],
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: Center(
        child: CircularProgressIndicator(color: AppColors.deepPurple),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Center(child: LoadProblemView(message: message, onRetry: onRetry)),
    );
  }
}

/// The 30 questions and the submit button. Answers live here until the
/// server accepts them, so a failed submission keeps them.
class _CheckupTest extends ConsumerStatefulWidget {
  const _CheckupTest();

  @override
  ConsumerState<_CheckupTest> createState() => _CheckupTestState();
}

class _CheckupTestState extends ConsumerState<_CheckupTest> {
  /// Question id → chosen option index.
  final Map<int, int> _answers = {};
  bool _submitting = false;

  /// Shown inline above the submit button: a snackbar would float over the
  /// button, which is the last thing on the page.
  String? _error;

  void _showError(String message) {
    setState(() {
      _error = message;
    });
  }

  Future<void> _submit(List<CheckupQuestion> questions) async {
    if (_answers.length < questions.length) {
      _showError('Barcha ${questions.length} ta savolga javob bering.');
      return;
    }
    if (await _confirmSubmit(context) != true || !mounted) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(progressServiceProvider)
          .submitCheckup(Map.of(_answers));
      if (!mounted) return;
      // Show the result, then refetch: the screen switches to the cooldown
      // state and the chart gains the new point behind the dialog.
      showDialog<void>(
        context: context,
        builder: (_) => _ResultDialog(result: result),
      );
      _refreshProgress();
    } on CheckupCooldownException catch (error) {
      // Another device already submitted this cycle; the server knows best.
      // The form is replaced by the cooldown card, so no inline message.
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(checkupErrorMessage(error))));
      _refreshProgress();
    } catch (error) {
      if (!mounted) return;
      _showError(checkupErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _refreshProgress() {
    ref.invalidate(userProgressProvider);
    ref.invalidate(checkupHistoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(checkupQuestionsProvider);

    return questions.when(
      loading: () => const _LoadingCard(),
      error:
          (error, _) => _ProblemCard(
            message: checkupErrorMessage(error),
            onRetry: () => ref.invalidate(checkupQuestionsProvider),
          ),
      data: (questions) {
        if (questions.isEmpty) {
          return _ProblemCard(
            message: "Savollar hali qo'shilmagan.",
            onRetry: () => ref.invalidate(checkupQuestionsProvider),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AnsweredCounter(
              answered: _answers.length,
              total: questions.length,
            ),
            const SizedBox(height: 12),
            for (final (i, question) in questions.indexed) ...[
              if (i > 0) const SizedBox(height: 12),
              QuizQuestionCard(
                number: i + 1,
                prompt: question.question,
                options: question.options,
                selectedIndex: _answers[question.id],
                onSelected:
                    _submitting
                        ? (_) {}
                        : (option) => setState(() {
                          _answers[question.id] = option;
                          _error = null;
                        }),
              ),
            ],
            const SizedBox(height: _cardGap),
            if (_error case final error?) ...[
              _InlineError(message: error),
              const SizedBox(height: 12),
            ],
            _SubmitButton(
              submitting: _submitting,
              onPressed: () => _submit(questions),
            ),
          ],
        );
      },
    );
  }
}

Future<bool?> _confirmSubmit(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
          title: Text(
            'Natijani yuborasizmi?',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            "Yuborgach, keyingi tekshiruv ${checkupCooldown.inDays} kundan "
            "so'ng ochiladi.",
            style: GoogleFonts.manrope(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              key: const ValueKey('checkup-confirm-submit'),
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deepPurple,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Yuborish'),
            ),
          ],
        ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.dangerDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnsweredCounter extends StatelessWidget {
  const _AnsweredCounter({required this.answered, required this.total});

  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Javoblar',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Text(
                '$answered / $total',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : answered / total,
              minHeight: 6,
              backgroundColor: AppColors.track,
              color: AppColors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.submitting, required this.onPressed});

  final bool submitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton(
        key: const ValueKey('checkup-submit'),
        onPressed: submitting ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.deepPurple,
          disabledBackgroundColor: AppColors.deepPurple.withValues(alpha: 0.6),
        ),
        child:
            submitting
                ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                : const Text('Submit check-up'),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({required this.result});

  final CheckupResult result;

  @override
  Widget build(BuildContext context) {
    final colors = cefrColors(result.cefrLevel);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: _cardRadius),
      icon: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
        ),
        child: Text(
          result.cefrLevel,
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.foreground,
          ),
        ),
      ),
      title: Text(
        'Your level: ${result.cefrLevel}',
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        '${result.score}/${result.total} correct. Your next level check '
        'opens in ${checkupCooldown.inDays} days.',
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.deepPurple),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

/// Growth chart from `checkup_history`, or its empty state.
class _GrowthHistory extends ConsumerWidget {
  const _GrowthHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(checkupHistoryProvider)
        .when(
          loading: () => const _LoadingCard(),
          error:
              (error, _) => _ProblemCard(
                message: checkupErrorMessage(error),
                onRetry: () => ref.invalidate(checkupHistoryProvider),
              ),
          data: (history) {
            if (history.isEmpty) return const _GrowthEmptyCard();
            final recent =
                history.length > _maxChartPoints
                    ? history.sublist(history.length - _maxChartPoints)
                    : history;
            final gained =
                _cefrLevels.indexOf(recent.last.cefrLevel) -
                _cefrLevels.indexOf(recent.first.cefrLevel);
            return _GrowthChartCard(
              points: [
                for (final entry in recent)
                  _GrowthPoint(
                    level: entry.cefrLevel,
                    label: _dateLabel(entry.takenAt),
                  ),
              ],
              levelsGained: gained,
            );
          },
        );
  }
}

String _dateLabel(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]}';
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR TRUE LEVEL',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Daraja Tekshiruvi',
          style: GoogleFonts.manrope(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// White card with a hairline border and a barely-there shadow.
class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: _cardRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

/// Dark banner describing the adaptive test.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.questionCount,
    required this.estimatedMinutes,
  });

  final int questionCount;
  final int estimatedMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.midnightGradient,
        ),
        borderRadius: _cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.midnightGradient.first.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.shieldCheck,
                  size: 26,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _Pill(
                label: '≈ $estimatedMinutes min',
                background: Colors.white.withValues(alpha: 0.12),
                foreground: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            '$questionCount questions from A1 to C2',
            style: GoogleFonts.manrope(
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your level is the highest one you pass in order, from A1 up.',
            style: GoogleFonts.manrope(
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA4A9BD),
            ),
          ),
        ],
      ),
    );
  }
}

/// Countdown until the next allowed attempt; the retake button is disabled
/// for the whole cooldown.
class _CooldownCard extends StatelessWidget {
  const _CooldownCard({required this.daysRemaining});

  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.clock,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Next level check in',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}',
            style: GoogleFonts.manrope(
              fontSize: 46,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A cooldown protects your result from short-term practice effects.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                disabledBackgroundColor: const Color(0xFFF7F8FA),
                disabledForegroundColor: AppColors.hint,
                side: const BorderSide(color: AppColors.track),
                elevation: 0,
              ),
              child: const Text('Retake unavailable'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthPoint {
  const _GrowthPoint({required this.level, required this.label});

  final String level;

  /// Date shown under the point, e.g. "22 Sep".
  final String label;
}

/// CEFR level history drawn as a smooth rising line.
class _GrowthChartCard extends StatelessWidget {
  const _GrowthChartCard({required this.points, required this.levelsGained});

  final List<_GrowthPoint> points;
  final int levelsGained;

  @override
  Widget build(BuildContext context) {
    final gained = levelsGained;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CEFR growth',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      points.length == 1
                          ? 'Your last check'
                          : 'Your last ${points.length} checks',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (gained > 0)
                _Pill(
                  label: '+$gained ${gained == 1 ? 'level' : 'levels'}',
                  background: AppColors.successSoft,
                  foreground: AppColors.successDark,
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _GrowthChartPainter(
                levels: [
                  for (final point in points) _cefrLevels.indexOf(point.level),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < points.length; i++)
                Expanded(
                  // Hug the card edges at both ends, center the rest.
                  child: Align(
                    alignment:
                        i == 0
                            ? Alignment.centerLeft
                            : i == points.length - 1
                            ? Alignment.centerRight
                            : Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${points[i].level} · ${points[i].label}',
                        maxLines: 1,
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown until there is a result to plot.
class _GrowthEmptyCard extends StatelessWidget {
  const _GrowthEmptyCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.track,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.lineChart,
              size: 26,
              color: AppColors.hint,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CEFR growth',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Testni yechgach o'sish grafigi paydo bo'ladi",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  _GrowthChartPainter({required this.levels});

  /// Index of each check's level in [_cefrLevels], oldest first.
  final List<int> levels;

  static const _gridLines = 3;
  static const _dotRadius = 8.0;
  static const _inset = 44.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    // Grid sits in the lower part; the latest point may rise above it.
    final gridTop = size.height * 0.35;
    final gridBottom = size.height - _dotRadius;
    final gridPaint =
        Paint()
          ..color = AppColors.track
          ..strokeWidth = 1.5;
    for (var i = 0; i < _gridLines; i++) {
      final y = gridTop + (gridBottom - gridTop) * i / (_gridLines - 1);
      canvas.drawLine(
        Offset(_inset, y),
        Offset(size.width - _inset, y),
        gridPaint,
      );
    }

    final minLevel = levels.reduce((a, b) => a < b ? a : b);
    final maxLevel = levels.reduce((a, b) => a > b ? a : b);
    final span = (maxLevel - minLevel).clamp(1, _cefrLevels.length);
    final plotTop = _dotRadius + 16;
    final left = _dotRadius + 16;
    final right = size.width - _dotRadius - 16;

    final offsets = [
      for (var i = 0; i < levels.length; i++)
        Offset(
          levels.length == 1
              ? size.width / 2
              : left + (right - left) * i / (levels.length - 1),
          gridBottom - (gridBottom - plotTop) * (levels[i] - minLevel) / span,
        ),
    ];

    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      final prev = offsets[i - 1];
      final curr = offsets[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    final dotPaint = Paint()..color = AppColors.primary;
    for (final offset in offsets) {
      canvas.drawCircle(offset, _dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GrowthChartPainter oldDelegate) =>
      !listEquals(oldDelegate.levels, levels);
}
