import 'package:equatable/equatable.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_stats.dart';
import 'package:habit_tracker/features/habits/presentation/common/day_mark.dart';

/// Привычка, подготовленная для показа в списке.
class HabitListItem extends Equatable {
  const HabitListItem({
    required this.habit,
    required this.stats,
    required this.lastWeek,
  });

  final Habit habit;
  final HabitStats stats;

  /// Последние 7 дней, последний элемент — сегодня.
  final List<DayMark> lastWeek;

  bool get isCompletedToday => lastWeek.last.isCompleted;

  @override
  List<Object?> get props => [habit, stats, lastWeek];
}

/// Состояние экрана списка. Sealed-класс: View обязан обработать все варианты.
sealed class HabitsListState extends Equatable {
  const HabitsListState();

  @override
  List<Object?> get props => [];
}

final class HabitsListLoading extends HabitsListState {
  const HabitsListLoading();
}

final class HabitsListError extends HabitsListState {
  const HabitsListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class HabitsListData extends HabitsListState {
  const HabitsListData(this.items);

  final List<HabitListItem> items;

  int get completedTodayCount =>
      items.where((item) => item.isCompletedToday).length;

  @override
  List<Object?> get props => [items];
}
