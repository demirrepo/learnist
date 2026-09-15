import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class SnapshotStat {
  const SnapshotStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

/// "Your snapshot" title and a two-column grid of stat cards. Cards in the
/// same row share a height.
class SnapshotGrid extends StatelessWidget {
  const SnapshotGrid({super.key, required this.stats});

  final List<SnapshotStat> stats;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Your snapshot',
          style: GoogleFonts.manrope(
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < stats.length; i += 2) ...[
          if (i > 0) const SizedBox(height: _gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _StatCard(stat: stats[i])),
                const SizedBox(width: _gap),
                Expanded(
                  child: i + 1 < stats.length
                      ? _StatCard(stat: stats[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final SnapshotStat stat;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${stat.label}: ${stat.value}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        // Icon sits beside the value; the label spans the full width below.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    stat.value,
                    style: GoogleFonts.manrope(
                      fontSize: 25,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.track,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(stat.icon, size: 17, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stat.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
