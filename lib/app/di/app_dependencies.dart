import 'package:flutter/widgets.dart';
import 'package:habit_tracker/features/habits/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/habits/domain/usecases/calculate_habit_stats.dart';
import 'package:habit_tracker/features/habits/domain/usecases/create_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit.dart';
import 'package:habit_tracker/features/habits/domain/usecases/get_habits.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/domain/usecases/update_habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Корень композиции: единственное место, где создаются реализации
/// и связываются слои. Остальной код получает готовые use case'ы.
class AppDependencies {
  AppDependencies._({
    required this.getHabits,
    required this.createHabit,
    required this.updateHabit,
    required this.deleteHabit,
    required this.toggleHabitCompletion,
    required this.calculateHabitStats,
  });

  static Future<AppDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();
    final repository = HabitRepositoryImpl(
      HabitLocalDataSourceImpl(preferences),
    );

    return AppDependencies._(
      getHabits: GetHabits(repository),
      createHabit: CreateHabit(repository),
      updateHabit: UpdateHabit(repository),
      deleteHabit: DeleteHabit(repository),
      toggleHabitCompletion: ToggleHabitCompletion(repository),
      calculateHabitStats: const CalculateHabitStats(),
    );
  }

  final GetHabits getHabits;
  final CreateHabit createHabit;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;
  final ToggleHabitCompletion toggleHabitCompletion;
  final CalculateHabitStats calculateHabitStats;
}

/// Передаёт зависимости вниз по дереву. Фабрики WidgetModel берут
/// отсюда use case'ы и создают ElementaryModel для своего экрана.
class DependenciesScope extends InheritedWidget {
  const DependenciesScope({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependencies dependencies;

  /// getInheritedWidgetOfExactType не подписывает на обновления:
  /// зависимости не меняются за время работы приложения.
  static AppDependencies of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DependenciesScope>();
    if (scope == null) {
      throw StateError('DependenciesScope не найден в дереве виджетов');
    }
    return scope.dependencies;
  }

  @override
  bool updateShouldNotify(DependenciesScope oldWidget) => false;
}
