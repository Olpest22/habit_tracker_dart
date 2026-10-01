import 'package:elementary/elementary.dart';
import 'package:equatable/equatable.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_stats.dart';
import 'package:habit_tracker/features/habits/domain/usecases/calculate_habit_stats.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/presentation/common/day_mark.dart';

/// Данные для экрана подробностей.
class HabitDetailsViewData extends Equatable {
  const HabitDetailsViewData({
    required this.habit,
    required this.stats,
    required this.recentDays,
  });

  final Habit habit;
  final HabitStats stats;

  /// История за последние дни, последний элемент — сегодня.
  final List<DayMark> recentDays;

  DayMark get today => recentDays.last;

  @override
  List<Object?> get props => [habit, stats, recentDays];
}

/// Model экрана подробностей: статистика и отметки за прошлые дни.
class HabitDetailsModel extends ElementaryModel {
  HabitDetailsModel({
    required ToggleHabitCompletion toggleHabitCompletion,
    required CalculateHabitStats calculateHabitStats,
  })  : _toggleHabitCompletion = toggleHabitCompletion,
        _calculateHabitStats = calculateHabitStats;

  /// Сколько последних дней показывать в истории.
  static const historyLength = 30;

  final ToggleHabitCompletion _toggleHabitCompletion;
  final CalculateHabitStats _calculateHabitStats;

  HabitDetailsViewData buildViewData(Habit habit, {required DateTime today}) {
    return HabitDetailsViewData(
      habit: habit,
      stats: _calculateHabitStats(habit, today: today),
      recentDays:
          DayMark.recentDays(habit, today: today, count: historyLength),
    );
  }

  Future<Result<Habit>> toggleDay(Habit habit, DateTime date) {
    return _toggleHabitCompletion(
      ToggleHabitCompletionParams(habit: habit, date: date),
    );
  }
}
