import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/app/di/app_dependencies.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/presentation/common/day_mark.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_details/habit_details_model.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_details/habit_details_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_editor/habit_editor_result.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_editor/habit_editor_screen.dart';

HabitDetailsWidgetModel habitDetailsWidgetModelFactory(BuildContext context) {
  final dependencies = DependenciesScope.of(context);
  return HabitDetailsWidgetModel(
    HabitDetailsModel(
      toggleHabitCompletion: dependencies.toggleHabitCompletion,
      calculateHabitStats: dependencies.calculateHabitStats,
    ),
  );
}

abstract interface class IHabitDetailsWidgetModel implements IWidgetModel {
  ValueListenable<HabitDetailsViewData> get viewData;

  /// Поставить или снять отметку за выбранный день.
  void onDayPressed(DayMark day);

  void onEditPressed();
}

/// ViewModel экрана подробностей привычки.
class HabitDetailsWidgetModel
    extends WidgetModel<HabitDetailsScreen, HabitDetailsModel>
    implements IHabitDetailsWidgetModel {
  HabitDetailsWidgetModel(super.model);

  late final ValueNotifier<HabitDetailsViewData> _viewData;
  bool _isToggling = false;

  @override
  ValueListenable<HabitDetailsViewData> get viewData => _viewData;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    // Привычка передаётся в виджет при открытии экрана.
    _viewData = ValueNotifier(_buildViewData(widget.habit));
  }

  @override
  void dispose() {
    _viewData.dispose();
    super.dispose();
  }

  @override
  void onDayPressed(DayMark day) => unawaited(_toggleDay(day));

  @override
  void onEditPressed() => unawaited(_openEditor());

  HabitDetailsViewData _buildViewData(Habit habit) =>
      model.buildViewData(habit, today: DateTime.now());

  Future<void> _toggleDay(DayMark day) async {
    if (_isToggling) return;
    _isToggling = true;

    try {
      final result = await model.toggleDay(_viewData.value.habit, day.date);
      if (!isMounted) return;

      switch (result) {
        case Success(:final data):
          _viewData.value = _buildViewData(data);
        case Failed(:final failure):
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(failure.message)));
      }
    } finally {
      _isToggling = false;
    }
  }

  /// Открывает редактор. После сохранения обновляет экран,
  /// после удаления закрывает его.
  Future<void> _openEditor() async {
    final result = await Navigator.of(context).push<HabitEditorResult>(
      MaterialPageRoute(
        builder: (_) => HabitEditorScreen(habit: _viewData.value.habit),
      ),
    );
    if (!isMounted || result == null) return;

    switch (result) {
      case HabitSaved(:final habit):
        _viewData.value = _buildViewData(habit);
      case HabitDeleted():
        Navigator.of(context).pop();
    }
  }
}
