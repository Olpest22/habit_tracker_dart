import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import '../rules/habit_rules.dart';

class CreateHabitParams extends Equatable {
  const CreateHabitParams({
    required this.title,
    required this.emoji,
    required this.colorValue,
  });

  final String title;
  final String emoji;
  final int colorValue;

  @override
  List<Object?> get props => [title, emoji, colorValue];
}

/// Создать привычку: проверить название, присвоить id и дату создания.
class CreateHabit implements UseCase<Habit, CreateHabitParams> {
  CreateHabit(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final HabitRepository _repository;

  /// Источник текущего времени; в тестах подменяется фиксированной датой.
  final DateTime Function() _clock;

  @override
  Future<Result<Habit>> call(CreateHabitParams params) async {
    final titleError = HabitRules.validateTitle(params.title);
    if (titleError != null) return Failed(ValidationFailure(titleError));

    final now = _clock();
    final habit = Habit(
      id: now.microsecondsSinceEpoch.toString(),
      title: params.title.trim(),
      emoji: params.emoji,
      colorValue: params.colorValue,
      createdAt: now,
    );
    return _repository.saveHabit(habit);
  }
}
