import 'package:habit_tracker/core/result/guard_result.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';

/// Реализация репозитория из domain. Переводит модели в сущности,
/// а исключения хранилища — в [Result] с ошибкой.
class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._localDataSource);

  final HabitLocalDataSource _localDataSource;

  @override
  Future<Result<List<Habit>>> getHabits() {
    return guardResult<List<Habit>>(() async {
      final models = await _localDataSource.loadHabits();
      return models.map((model) => model.toEntity()).toList(growable: false);
    });
  }

  @override
  Future<Result<Habit>> saveHabit(Habit habit) {
    return guardResult<Habit>(() async {
      final models = await _localDataSource.loadHabits();
      final updatedModel = HabitModel.fromEntity(habit);
      final index = models.indexWhere((model) => model.id == habit.id);

      if (index == -1) {
        models.add(updatedModel);
      } else {
        models[index] = updatedModel;
      }
      await _localDataSource.saveHabits(models);
      return habit;
    });
  }

  @override
  Future<Result<void>> deleteHabit(String id) {
    return guardResult<void>(() async {
      final models = await _localDataSource.loadHabits()
        ..removeWhere((model) => model.id == id);
      await _localDataSource.saveHabits(models);
    });
  }
}
