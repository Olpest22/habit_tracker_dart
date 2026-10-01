import 'package:habit_tracker/features/habits/domain/entities/habit.dart';

/// Результат, который редактор возвращает через Navigator.pop.
sealed class HabitEditorResult {
  const HabitEditorResult();
}

final class HabitSaved extends HabitEditorResult {
  const HabitSaved(this.habit);

  final Habit habit;
}

final class HabitDeleted extends HabitEditorResult {
  const HabitDeleted();
}
