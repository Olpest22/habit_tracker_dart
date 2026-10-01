import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/usecases/calculate_habit_stats.dart';

import '../fakes.dart';

void main() {
  const calculateStats = CalculateHabitStats();
  final today = DateTime(2026, 10, 10, 15, 30);
  DateTime october(int day) => DateTime.utc(2026, 10, day);

  test('текущая серия включает сегодняшний день', () {
    final habit = buildHabit(
      completedDates: {october(8), october(9), october(10)},
    );
    expect(calculateStats(habit, today: today).currentStreak, 3);
  });

  test('если сегодня ещё не отмечено, серия продолжается со вчерашнего дня', () {
    final habit = buildHabit(completedDates: {october(8), october(9)});
    expect(calculateStats(habit, today: today).currentStreak, 2);
  });

  test('пропущенный вчерашний день обнуляет текущую серию', () {
    final habit = buildHabit(completedDates: {october(7), october(8)});
    expect(calculateStats(habit, today: today).currentStreak, 0);
  });

  test('лучшая серия — самая длинная последовательность дней', () {
    final habit = buildHabit(completedDates: {
      october(1), october(2), october(3), // 3 дня
      october(5), october(6), // 2 дня
      october(9),
    });
    final stats = calculateStats(habit, today: today);
    expect(stats.bestStreak, 3);
    expect(stats.totalCompletions, 6);
  });

  test('процент выполнения считается с даты создания привычки', () {
    // Создана 1 октября, сегодня 10-е: 10 дней, из них 5 выполнено.
    final habit = buildHabit(
      createdAt: DateTime(2026, 10, 1),
      completedDates: {for (var d = 1; d <= 5; d++) october(d)},
    );
    expect(calculateStats(habit, today: today).completionRate, 0.5);
  });

  test('отметки в будущем не учитываются', () {
    final habit = buildHabit(completedDates: {october(11), october(12)});
    final stats = calculateStats(habit, today: today);
    expect(stats.totalCompletions, 0);
    expect(stats.bestStreak, 0);
  });
}
