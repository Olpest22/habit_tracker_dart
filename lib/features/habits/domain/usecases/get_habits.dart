import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetHabits implements UseCase<List<Habit>, NoParams> {
  const GetHabits(this._repository);

  final HabitRepository _repository;

  @override
  Future<Result<List<Habit>>> call(NoParams params) => _repository.getHabits();
}
