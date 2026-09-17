import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';

const _pagePadding = 24.0;
const _cardGap = 24.0;
const _cardRadius = BorderRadius.all(Radius.circular(16));

// Placeholder content copied from the design mockup until the backend exists.
const _questionCount = 30;
const _estimatedMinutes = 18;
const _daysUntilNextCheck = 10;
const _levelsGained = 2;
const _growthPoints = [
  _GrowthPoint(level: 'B1', month: 'May'),
  _GrowthPoint(level: 'B2', month: 'Jun'),
  _GrowthPoint(level: 'C1', month: 'Jul'),
  _GrowthPoint(level: 'C2', month: 'Aug'),
];

/// Ordered CEFR scale; a level's index is its height on the growth chart.
const _cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

class CheckUpScreen extends StatelessWidget {
  const CheckUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              _CooldownCard(
                daysRemaining: _daysUntilNextCheck,
                // TODO: start the level check once the backend is wired up.
                onRetake: () {},
              ),
              const SizedBox(height: _cardGap),
              const _GrowthChartCard(
                points: _growthPoints,
                levelsGained: _levelsGained,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            'Questions adapt to your answers for a clear, useful estimate.',
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

/// Countdown until the next allowed attempt. The retake button stays
/// disabled until [daysRemaining] reaches zero.
class _CooldownCard extends StatelessWidget {
  const _CooldownCard({required this.daysRemaining, required this.onRetake});

  final int daysRemaining;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final locked = daysRemaining > 0;

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
            locked ? 'Next level check in' : 'Your next level check',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            locked
                ? '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}'
                : 'Ready now',
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
              onPressed: locked ? null : onRetake,
              style: FilledButton.styleFrom(
                disabledBackgroundColor: const Color(0xFFF7F8FA),
                disabledForegroundColor: AppColors.hint,
                side:
                    locked
                        ? const BorderSide(color: AppColors.track)
                        : BorderSide.none,
                elevation: 0,
              ),
              child: Text(locked ? 'Retake unavailable' : 'Start level check'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthPoint {
  const _GrowthPoint({required this.level, required this.month});

  final String level;
  final String month;
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
                      'Your last ${points.length} checks',
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
                        '${points[i].level} · ${points[i].month}',
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
