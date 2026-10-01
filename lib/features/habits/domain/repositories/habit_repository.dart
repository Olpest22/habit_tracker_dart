import '../../../../core/result/result.dart';
import '../entities/habit.dart';

/// Контракт хранилища привычек. Определён в domain,
/// реализован в data (принцип инверсии зависимостей).
abstract interface class HabitRepository {
  Future<Result<List<Habit>>> getHabits();

  /// Создаёт новую привычку или обновляет существующую (по id).
  Future<Result<Habit>> saveHabit(Habit habit);

  Future<Result<void>> deleteHabit(String id);
}
