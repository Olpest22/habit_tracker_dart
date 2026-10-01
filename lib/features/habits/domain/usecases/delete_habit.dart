import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/habit_repository.dart';

class DeleteHabit implements UseCase<void, String> {
  const DeleteHabit(this._repository);

  final HabitRepository _repository;

  @override
  Future<Result<void>> call(String habitId) => _repository.deleteHabit(habitId);
}
