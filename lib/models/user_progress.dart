/// A row of `public.user_progress`: `cefr_level`, `current_lesson` and
/// `last_checkup_date`.
///
/// New users have no row until their first check-up, so parsing never
/// throws: a missing row or malformed values fall back to "no level",
/// lesson 1 and "never checked".
class UserProgress {
  const UserProgress({
    this.cefrLevel,
    this.currentLesson = firstLesson,
    this.lastCheckupDate,
  });

  factory UserProgress.fromJson(Map<String, dynamic>? row) {
    final data = row ?? const {};
    return UserProgress(
      cefrLevel: _parseLevel(data['cefr_level']),
      currentLesson: _parseLesson(data['current_lesson']),
      lastCheckupDate: _parseDate(data['last_checkup_date']),
    );
  }

  static const cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const firstLesson = 1;
  static const lastLesson = 52;

  /// One of [cefrLevels], or null before the first check-up.
  final String? cefrLevel;

  /// The lesson the student is working on, 1 – 52.
  final int currentLesson;

  /// When the last level check-up finished, or null if never.
  final DateTime? lastCheckupDate;

  static String? _parseLevel(Object? value) {
    if (value is! String) return null;
    final level = value.trim().toUpperCase();
    return cefrLevels.contains(level) ? level : null;
  }

  static int _parseLesson(Object? value) {
    final lesson = switch (value) {
      int v => v,
      num v when v == v.roundToDouble() => v.toInt(),
      String v => int.tryParse(v.trim()),
      _ => null,
    };
    return (lesson ?? firstLesson).clamp(firstLesson, lastLesson);
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value.trim()) : null;
}

/// Minimum time between two level check-ups.
const checkupCooldown = Duration(days: 10);

/// Whether a check-up can start at [now], and if not, how long to wait.
sealed class CheckupAvailability {
  const CheckupAvailability();

  factory CheckupAvailability.at(DateTime? lastCheckup, DateTime now) {
    if (lastCheckup == null) return const CheckupAvailable(firstTime: true);

    final nextAllowed = lastCheckup.add(checkupCooldown);
    if (!now.isBefore(nextAllowed)) {
      return const CheckupAvailable(firstTime: false);
    }
    // Round partial days up: 3.2 days left reads as "4 days". A date in the
    // future (clock skew) never shows more than the full cooldown.
    final hoursLeft = nextAllowed.difference(now).inHours;
    final days = (hoursLeft / 24).ceil().clamp(1, checkupCooldown.inDays);
    return CheckupOnCooldown(daysRemaining: days);
  }
}

class CheckupAvailable extends CheckupAvailability {
  const CheckupAvailable({required this.firstTime});

  /// No check-up has ever been taken.
  final bool firstTime;
}

class CheckupOnCooldown extends CheckupAvailability {
  const CheckupOnCooldown({required this.daysRemaining});

  /// Whole days until the next check-up, at least 1.
  final int daysRemaining;
}
