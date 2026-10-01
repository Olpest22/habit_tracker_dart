import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/domain/usecases/calculate_habit_stats.dart';
import 'package:habit_tracker/features/habits/domain/usecases/get_habits.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_model.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_state.dart';

import '../fakes.dart';

void main() {
  final today = DateTime(2026, 10, 10, 9);
  late InMemoryHabitRepository repository;
  late HabitsListModel model;

  setUp(() {
    repository = InMemoryHabitRepository();
    model = HabitsListModel(
      getHabits: GetHabits(repository),
      toggleHabitCompletion: ToggleHabitCompletion(repository, clock: () => today),
      calculateHabitStats: const CalculateHabitStats(),
    );
  });

  test('готовит карточки с неделей отметок и статистикой', () async {
    repository.habits.add(buildHabit(completedDates: {DateTime.utc(2026, 10, 9)}));

    final result = await model.loadHabits(today: today);
    final item = (result as Success<List<HabitListItem>>).data.single;

    expect(item.lastWeek, hasLength(7));
    expect(item.lastWeek.last.isToday, isTrue);
    expect(item.isCompletedToday, isFalse);
    expect(item.stats.currentStreak, 1);
  });

  test('отметка на сегодня обновляет карточку и серию', () async {
    final habit = buildHabit(completedDates: {DateTime.utc(2026, 10, 9)});
    repository.habits.add(habit);

    final result = await model.toggleToday(habit, today: today);
    final item = (result as Success<HabitListItem>).data;

    expect(item.isCompletedToday, isTrue);
    expect(item.stats.currentStreak, 2);
  });
}
