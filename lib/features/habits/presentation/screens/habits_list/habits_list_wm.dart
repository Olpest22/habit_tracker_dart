import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/app/di/app_dependencies.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/core/utils/formatters.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_details/habit_details_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_editor/habit_editor_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_model.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_state.dart';

/// Фабрика WidgetModel: собирает Model из зависимостей приложения.
HabitsListWidgetModel habitsListWidgetModelFactory(BuildContext context) {
  final dependencies = DependenciesScope.of(context);
  return HabitsListWidgetModel(
    HabitsListModel(
      getHabits: dependencies.getHabits,
      toggleHabitCompletion: dependencies.toggleHabitCompletion,
      calculateHabitStats: dependencies.calculateHabitStats,
    ),
  );
}

/// Контракт между View и ViewModel: всё, что экран может показать
/// и все действия пользователя, которые он передаёт.
abstract interface class IHabitsListWidgetModel implements IWidgetModel {
  ValueListenable<HabitsListState> get state;

  /// «Четверг, 1 октября»
  String get todayLabel;

  void onAddHabitPressed();

  void onHabitPressed(HabitListItem item);

  void onToggleTodayPressed(HabitListItem item);

  void onRetryPressed();
}

/// ViewModel (MVVM) экрана списка: хранит состояние экрана,
/// обрабатывает действия пользователя, отвечает за навигацию и сообщения.
class HabitsListWidgetModel
    extends WidgetModel<HabitsListScreen, HabitsListModel>
    implements IHabitsListWidgetModel {
  HabitsListWidgetModel(super.model);

  final _state = ValueNotifier<HabitsListState>(const HabitsListLoading());

  /// Привычки, для которых сейчас сохраняется отметка. Защищает от
  /// двойного нажатия, пока предыдущее не обработано.
  final _pendingHabitIds = <String>{};

  /// Дата берётся при каждом действии, чтобы после полуночи
  /// отметки ставились уже на новый день.
  DateTime get _today => DateTime.now();

  @override
  ValueListenable<HabitsListState> get state => _state;

  @override
  String get todayLabel => formatFullDate(_today);

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    unawaited(_loadHabits());
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  void onRetryPressed() => unawaited(_loadHabits());

  @override
  void onAddHabitPressed() =>
      unawaited(_openAndRefresh(const HabitEditorScreen()));

  @override
  void onHabitPressed(HabitListItem item) =>
      unawaited(_openAndRefresh(HabitDetailsScreen(habit: item.habit)));

  @override
  void onToggleTodayPressed(HabitListItem item) =>
      unawaited(_toggleToday(item));

  /// [showLoader] — показать полноэкранный индикатор. При возврате с других
  /// экранов список обновляется «тихо», без мигания.
  Future<void> _loadHabits({bool showLoader = true}) async {
    if (showLoader) _state.value = const HabitsListLoading();

    final result = await model.loadHabits(today: _today);
    // Пока шла загрузка, экран могли закрыть.
    if (!isMounted) return;

    _state.value = switch (result) {
      Success(:final data) => HabitsListData(data),
      Failed(:final failure) => HabitsListError(failure.message),
    };
  }

  /// Открывает экран и после возврата обновляет список: привычку могли
  /// создать, изменить, отметить или удалить.
  Future<void> _openAndRefresh(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute<Object?>(builder: (_) => screen),
    );
    if (!isMounted) return;
    await _loadHabits(showLoader: false);
  }

  Future<void> _toggleToday(HabitListItem item) async {
    final habitId = item.habit.id;
    if (!_pendingHabitIds.add(habitId)) return;

    try {
      final result = await model.toggleToday(item.habit, today: _today);
      if (!isMounted) return;

      switch (result) {
        case Success(:final data):
          _replaceItem(data);
        case Failed(:final failure):
          _showMessage(failure.message);
      }
    } finally {
      _pendingHabitIds.remove(habitId);
    }
  }

  /// Обновляет одну карточку, не перезагружая весь список.
  void _replaceItem(HabitListItem updatedItem) {
    final currentState = _state.value;
    if (currentState is! HabitsListData) return;

    _state.value = HabitsListData([
      for (final item in currentState.items)
        item.habit.id == updatedItem.habit.id ? updatedItem : item,
    ]);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
