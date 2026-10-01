import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/create_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/update_habit.dart';

import '../fakes.dart';

void main() {
  late InMemoryHabitRepository repository;
  final now = DateTime(2026, 10, 10, 12);

  setUp(() => repository = InMemoryHabitRepository());

  group('CreateHabit', () {
    test('создаёт привычку с обрезанным названием и датой создания', () async {
      final createHabit = CreateHabit(repository, clock: () => now);

      final result = await createHabit(
        const CreateHabitParams(
          title: '  Читать 20 минут  ',
          emoji: '📚',
          colorValue: 0xFF43A047,
        ),
      );

      final habit = (result as Success<Habit>).data;
      expect(habit.title, 'Читать 20 минут');
      expect(habit.createdAt, now);
      expect(repository.habits, [habit]);
    });

    test('пустое название — ошибка валидации, привычка не сохраняется', () async {
      final createHabit = CreateHabit(repository, clock: () => now);

      final result = await createHabit(
        const CreateHabitParams(title: '   ', emoji: '📚', colorValue: 0),
      );

      expect(result, isA<Failed<Habit>>());
      expect((result as Failed<Habit>).failure, isA<ValidationFailure>());
      expect(repository.habits, isEmpty);
    });
  });

  test('UpdateHabit отклоняет слишком длинное название', () async {
    final result = await UpdateHabit(repository)(
      buildHabit().copyWith(title: 'а' * 41),
    );
    expect((result as Failed<Habit>).failure, isA<ValidationFailure>());
  });

  group('ToggleHabitCompletion', () {
    test('первое нажатие ставит отметку, второе снимает', () async {
      final toggle = ToggleHabitCompletion(repository, clock: () => now);
      final habit = buildHabit();

      final marked = await toggle(
        ToggleHabitCompletionParams(habit: habit, date: now),
      );
      final markedHabit = (marked as Success<Habit>).data;
      expect(markedHabit.isCompletedOn(now), isTrue);

      final unmarked = await toggle(
        ToggleHabitCompletionParams(habit: markedHabit, date: now),
      );
      expect((unmarked as Success<Habit>).data.isCompletedOn(now), isFalse);
    });

    test('нельзя отметить день в будущем', () async {
      final toggle = ToggleHabitCompletion(repository, clock: () => now);

      final result = await toggle(
        ToggleHabitCompletionParams(
          habit: buildHabit(),
          date: now.add(const Duration(days: 1)),
        ),
      );

      expect((result as Failed<Habit>).failure, isA<ValidationFailure>());
    });
  });
}
