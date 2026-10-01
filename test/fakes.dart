import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';

/// Репозиторий в памяти для тестов domain и presentation.
class InMemoryHabitRepository implements HabitRepository {
  final List<Habit> habits = [];

  @override
  Future<Result<List<Habit>>> getHabits() async =>
      Success<List<Habit>>(List.of(habits));

  @override
  Future<Result<Habit>> saveHabit(Habit habit) async {
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) {
      habits.add(habit);
    } else {
      habits[index] = habit;
    }
    return Success<Habit>(habit);
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    habits.removeWhere((h) => h.id == id);
    return const Success<void>(null);
  }
}

Habit buildHabit({
  String id = '1',
  Set<DateTime> completedDates = const <DateTime>{},
  DateTime? createdAt,
}) {
  return Habit(
    id: id,
    title: 'Пить воду',
    emoji: '💧',
    colorValue: 0xFF1E88E5,
    createdAt: createdAt ?? DateTime(2026, 9, 1),
    completedDates: completedDates,
  );
}
