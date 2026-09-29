import 'package:flutter/material.dart';

import 'teacher_common.dart';

/// Stat cards in one row when there is room, otherwise two per row; a
/// card left alone in the last row takes the full width.
class ClassOverviewGrid extends StatelessWidget {
  const ClassOverviewGrid({super.key, required this.stats});

  /// `(label, value)` pairs.
  final List<(String, String)> stats;

  static const _gap = 12.0;
  static const _singleRowWidth = 640.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow =
            constraints.maxWidth >= _singleRowWidth ? stats.length : 2;

        return Column(
          children: [
            for (var start = 0; start < stats.length; start += perRow) ...[
              if (start > 0) const SizedBox(height: _gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var i = start;
                      i < start + perRow && i < stats.length;
                      i++
                    ) ...[
                      if (i > start) const SizedBox(width: _gap),
                      Expanded(
                        child: TeacherMetric(
                          label: stats[i].$1,
                          value: stats[i].$2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
