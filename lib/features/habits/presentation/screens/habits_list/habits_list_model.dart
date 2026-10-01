import 'package:elementary/elementary.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/core/usecase/usecase.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/calculate_habit_stats.dart';
import 'package:habit_tracker/features/habits/domain/usecases/get_habits.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/presentation/common/day_mark.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_state.dart';

/// Model (MVVM) экрана списка: связывает WidgetModel с бизнес-логикой.
/// Вызывает use case'ы и готовит данные в удобном для экрана виде.
/// Ничего не знает о виджетах и BuildContext.
class HabitsListModel extends ElementaryModel {
  HabitsListModel({
    required GetHabits getHabits,
    required ToggleHabitCompletion toggleHabitCompletion,
    required CalculateHabitStats calculateHabitStats,
  })  : _getHabits = getHabits,
        _toggleHabitCompletion = toggleHabitCompletion,
        _calculateHabitStats = calculateHabitStats;

  static const _daysInWeek = 7;

  final GetHabits _getHabits;
  final ToggleHabitCompletion _toggleHabitCompletion;
  final CalculateHabitStats _calculateHabitStats;

  Future<Result<List<HabitListItem>>> loadHabits({
    required DateTime today,
  }) async {
    final result = await _getHabits(const NoParams());
    return switch (result) {
      Success(:final data) => Success<List<HabitListItem>>(
          data
              .map((habit) => buildItem(habit, today: today))
              .toList(growable: false),
        ),
      Failed(:final failure) => Failed<List<HabitListItem>>(failure),
    };
  }

  /// Отметить привычку на сегодня или снять отметку.
  Future<Result<HabitListItem>> toggleToday(
    Habit habit, {
    required DateTime today,
  }) async {
    final result = await _toggleHabitCompletion(
      ToggleHabitCompletionParams(habit: habit, date: today),
    );
    return switch (result) {
      Success(:final data) =>
        Success<HabitListItem>(buildItem(data, today: today)),
      Failed(:final failure) => Failed<HabitListItem>(failure),
    };
  }

  HabitListItem buildItem(Habit habit, {required DateTime today}) {
    return HabitListItem(
      habit: habit,
      stats: _calculateHabitStats(habit, today: today),
      lastWeek: DayMark.recentDays(habit, today: today, count: _daysInWeek),
    );
  }
}
