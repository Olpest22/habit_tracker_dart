import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class ToggleHabitCompletionParams extends Equatable {
  const ToggleHabitCompletionParams({required this.habit, required this.date});

  final Habit habit;
  final DateTime date;

  @override
  List<Object?> get props => [habit, date];
}

/// Отметить день выполненным или снять отметку.
///
/// Бизнес-правило: отмечать можно сегодня и прошлые дни, но не будущие.
class ToggleHabitCompletion
    implements UseCase<Habit, ToggleHabitCompletionParams> {
  ToggleHabitCompletion(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final HabitRepository _repository;
  final DateTime Function() _clock;

  @override
  Future<Result<Habit>> call(ToggleHabitCompletionParams params) async {
    final day = dateOnly(params.date);
    if (day.isAfter(dateOnly(_clock()))) {
      return const Failed(
        ValidationFailure('Нельзя отметить привычку в будущем.'),
      );
    }

    final updatedDates = {...params.habit.completedDates};
    // remove вернёт false, если дня не было в наборе, — тогда добавляем.
    if (!updatedDates.remove(day)) updatedDates.add(day);

    return _repository.saveHabit(
      params.habit.copyWith(completedDates: updatedDates),
    );
  }
}
