import 'package:equatable/equatable.dart';
import 'package:habit_tracker/core/utils/date_utils.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';

/// Один день в истории привычки для отображения на экране.
class DayMark extends Equatable {
  const DayMark({
    required this.date,
    required this.isCompleted,
    required this.isToday,
  });

  final DateTime date;
  final bool isCompleted;
  final bool isToday;

  /// Последние [count] дней, заканчивая сегодняшним (от старых к новым).
  static List<DayMark> recentDays(
    Habit habit, {
    required DateTime today,
    required int count,
  }) {
    final todayDate = dateOnly(today);
    return List.generate(
      count,
      (index) {
        final date = todayDate.subtract(Duration(days: count - 1 - index));
        return DayMark(
          date: date,
          isCompleted: habit.isCompletedOn(date),
          isToday: index == count - 1,
        );
      },
      growable: false,
    );
  }

  @override
  List<Object?> get props => [date, isCompleted, isToday];
}
