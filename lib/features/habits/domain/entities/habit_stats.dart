import 'package:equatable/equatable.dart';

/// Статистика выполнения привычки.
class HabitStats extends Equatable {
  const HabitStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompletions,
    required this.completionRate,
  });

  /// Сколько дней подряд привычка выполняется сейчас.
  final int currentStreak;

  /// Самая длинная серия за всё время.
  final int bestStreak;
  final int totalCompletions;

  /// Доля выполненных дней за последний период (от 0 до 1).
  final double completionRate;

  @override
  List<Object?> get props =>
      [currentStreak, bestStreak, totalCompletions, completionRate];
}
