import 'dart:math' as math;

import '../../../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../entities/habit_stats.dart';

/// Подсчёт статистики привычки. Чистая синхронная функция без
/// обращения к хранилищу, поэтому легко покрывается тестами.
class CalculateHabitStats {
  const CalculateHabitStats();

  /// Период для процента выполнения, дней.
  static const statsPeriodDays = 30;

  HabitStats call(Habit habit, {required DateTime today}) {
    final todayDate = dateOnly(today);
    final completed =
        habit.completedDates.where((day) => !day.isAfter(todayDate)).toSet();

    return HabitStats(
      currentStreak: _currentStreak(completed, todayDate),
      bestStreak: _bestStreak(completed),
      totalCompletions: completed.length,
      completionRate: _completionRate(habit, completed, todayDate),
    );
  }

  /// Серия не прерывается, пока не закончился сегодняшний день:
  /// если сегодня ещё не отмечено, считаем от вчерашнего дня.
  int _currentStreak(Set<DateTime> completed, DateTime today) {
    var day = completed.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (completed.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _bestStreak(Set<DateTime> completed) {
    if (completed.isEmpty) return 0;

    final sortedDays = completed.toList()..sort();
    var best = 1;
    var current = 1;
    for (var i = 1; i < sortedDays.length; i++) {
      final isNextDay = daysBetween(sortedDays[i - 1], sortedDays[i]) == 1;
      current = isNextDay ? current + 1 : 1;
      best = math.max(best, current);
    }
    return best;
  }

  /// Процент за последние [statsPeriodDays] дней, но не раньше начала
  /// отслеживания (даты создания или первой отметки, если её поставили задним числом).
  double _completionRate(
    Habit habit,
    Set<DateTime> completed,
    DateTime today,
  ) {
    var firstTrackedDay = dateOnly(habit.createdAt);
    for (final day in completed) {
      if (day.isBefore(firstTrackedDay)) firstTrackedDay = day;
    }

    final trackedDays = daysBetween(firstTrackedDay, today) + 1;
    final periodDays = math.min(math.max(trackedDays, 1), statsPeriodDays);
    final periodStart = today.subtract(Duration(days: periodDays - 1));
    final completedInPeriod =
        completed.where((day) => !day.isBefore(periodStart)).length;

    return completedInPeriod / periodDays;
  }
}
