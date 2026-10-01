import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

Future<HabitRepositoryImpl> createRepository(
  Map<String, Object> initialValues,
) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return HabitRepositoryImpl(HabitLocalDataSourceImpl(preferences));
}

void main() {
  test('сохраняет привычку с отметками и читает её обратно', () async {
    final repository = await createRepository({});
    final habit = buildHabit(
      createdAt: DateTime(2026, 10, 1, 8, 30),
      completedDates: {DateTime.utc(2026, 10, 1), DateTime.utc(2026, 10, 3)},
    );

    await repository.saveHabit(habit);
    final result = await repository.getHabits();

    expect((result as Success<List<Habit>>).data, [habit]);
  });

  test('повторное сохранение обновляет привычку, а не добавляет новую', () async {
    final repository = await createRepository({});
    final habit = buildHabit();

    await repository.saveHabit(habit);
    await repository.saveHabit(habit.copyWith(title: 'Пить больше воды'));
    final habits = ((await repository.getHabits()) as Success<List<Habit>>).data;

    expect(habits, hasLength(1));
    expect(habits.single.title, 'Пить больше воды');
  });

  test('удаление привычки', () async {
    final repository = await createRepository({});
    await repository.saveHabit(buildHabit(id: '1'));
    await repository.saveHabit(buildHabit(id: '2'));

    await repository.deleteHabit('1');
    final habits = ((await repository.getHabits()) as Success<List<Habit>>).data;

    expect(habits.map((h) => h.id), ['2']);
  });

  test('повреждённые данные дают StorageFailure, а не падение', () async {
    final repository = await createRepository({'habits_v1': 'не JSON'});

    final result = await repository.getHabits();

    expect((result as Failed<List<Habit>>).failure, isA<StorageFailure>());
  });
}
