import 'package:elementary/elementary.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/create_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/update_habit.dart';

/// Model экрана редактирования: создание, изменение и удаление привычки.
class HabitEditorModel extends ElementaryModel {
  HabitEditorModel({
    required CreateHabit createHabit,
    required UpdateHabit updateHabit,
    required DeleteHabit deleteHabit,
  })  : _createHabit = createHabit,
        _updateHabit = updateHabit,
        _deleteHabit = deleteHabit;

  final CreateHabit _createHabit;
  final UpdateHabit _updateHabit;
  final DeleteHabit _deleteHabit;

  /// Если [original] равен null — создаёт новую привычку,
  /// иначе сохраняет изменения существующей.
  Future<Result<Habit>> saveHabit({
    required Habit? original,
    required String title,
    required String emoji,
    required int colorValue,
  }) {
    if (original == null) {
      return _createHabit(
        CreateHabitParams(title: title, emoji: emoji, colorValue: colorValue),
      );
    }
    return _updateHabit(
      original.copyWith(title: title, emoji: emoji, colorValue: colorValue),
    );
  }

  Future<Result<void>> deleteHabit(Habit habit) => _deleteHabit(habit.id);
}
