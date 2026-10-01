import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import '../rules/habit_rules.dart';

/// Изменить название, иконку или цвет привычки.
class UpdateHabit implements UseCase<Habit, Habit> {
  const UpdateHabit(this._repository);

  final HabitRepository _repository;

  @override
  Future<Result<Habit>> call(Habit habit) async {
    final titleError = HabitRules.validateTitle(habit.title);
    if (titleError != null) return Failed(ValidationFailure(titleError));

    return _repository.saveHabit(habit.copyWith(title: habit.title.trim()));
  }
}
