import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/app/di/app_dependencies.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/result/result.dart';
import 'package:habit_tracker/features/habits/domain/rules/habit_rules.dart';
import 'package:habit_tracker/features/habits/presentation/common/habit_appearance.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_editor/habit_editor_model.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_editor/habit_editor_result.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_editor/habit_editor_screen.dart';

HabitEditorWidgetModel habitEditorWidgetModelFactory(BuildContext context) {
  final dependencies = DependenciesScope.of(context);
  return HabitEditorWidgetModel(
    HabitEditorModel(
      createHabit: dependencies.createHabit,
      updateHabit: dependencies.updateHabit,
      deleteHabit: dependencies.deleteHabit,
    ),
  );
}

abstract interface class IHabitEditorWidgetModel implements IWidgetModel {
  /// true — редактирование существующей привычки, false — создание.
  bool get isEditing;

  TextEditingController get titleController;

  int get maxTitleLength;

  List<String> get availableEmojis;

  List<int> get availableColors;

  /// Ошибка под полем названия (приходит из бизнес-правил domain).
  ValueListenable<String?> get titleError;

  ValueListenable<String> get selectedEmoji;

  ValueListenable<int> get selectedColor;

  ValueListenable<bool> get isSaving;

  void onEmojiSelected(String emoji);

  void onColorSelected(int colorValue);

  void onSavePressed();

  void onDeletePressed();
}

/// ViewModel экрана создания и редактирования привычки.
class HabitEditorWidgetModel
    extends WidgetModel<HabitEditorScreen, HabitEditorModel>
    implements IHabitEditorWidgetModel {
  HabitEditorWidgetModel(super.model);

  late final TextEditingController _titleController;
  late final ValueNotifier<String> _selectedEmoji;
  late final ValueNotifier<int> _selectedColor;
  final _titleError = ValueNotifier<String?>(null);
  final _isSaving = ValueNotifier<bool>(false);

  @override
  bool get isEditing => widget.habit != null;

  @override
  TextEditingController get titleController => _titleController;

  @override
  int get maxTitleLength => HabitRules.maxTitleLength;

  @override
  List<String> get availableEmojis => HabitAppearance.emojis;

  @override
  List<int> get availableColors => HabitAppearance.colors;

  @override
  ValueListenable<String?> get titleError => _titleError;

  @override
  ValueListenable<String> get selectedEmoji => _selectedEmoji;

  @override
  ValueListenable<int> get selectedColor => _selectedColor;

  @override
  ValueListenable<bool> get isSaving => _isSaving;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    // Поля заполняются из привычки, переданной в виджет (режим редактирования).
    final habit = widget.habit;
    _titleController = TextEditingController(text: habit?.title ?? '')
      ..addListener(_clearTitleError);
    _selectedEmoji = ValueNotifier(habit?.emoji ?? HabitAppearance.defaultEmoji);
    _selectedColor =
        ValueNotifier(habit?.colorValue ?? HabitAppearance.defaultColor);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _selectedEmoji.dispose();
    _selectedColor.dispose();
    _titleError.dispose();
    _isSaving.dispose();
    super.dispose();
  }

  @override
  void onEmojiSelected(String emoji) => _selectedEmoji.value = emoji;

  @override
  void onColorSelected(int colorValue) => _selectedColor.value = colorValue;

  @override
  void onSavePressed() => unawaited(_save());

  @override
  void onDeletePressed() => unawaited(_confirmAndDelete());

  /// Ошибка исчезает, как только пользователь начинает исправлять название.
  void _clearTitleError() {
    if (_titleError.value != null) _titleError.value = null;
  }

  Future<void> _save() async {
    // Защита от повторного нажатия во время сохранения.
    if (_isSaving.value) return;
    _isSaving.value = true;

    final result = await model.saveHabit(
      original: widget.habit,
      title: _titleController.text,
      emoji: _selectedEmoji.value,
      colorValue: _selectedColor.value,
    );
    if (!isMounted) return;
    _isSaving.value = false;

    switch (result) {
      case Success(:final data):
        Navigator.of(context).pop(HabitSaved(data));
      // Нарушено бизнес-правило — показываем ошибку прямо под полем.
      case Failed(failure: ValidationFailure(:final message)):
        _titleError.value = message;
      case Failed(:final failure):
        _showMessage(failure.message);
    }
  }

  Future<void> _confirmAndDelete() async {
    final habit = widget.habit;
    if (habit == null) return;

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Удалить привычку?'),
          content: Text(
            '«${habit.title}» и вся история отметок будут удалены '
            'без возможности восстановления.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
    if (isConfirmed != true || !isMounted) return;

    final result = await model.deleteHabit(habit);
    if (!isMounted) return;

    switch (result) {
      case Success():
        Navigator.of(context).pop(const HabitDeleted());
      case Failed(:final failure):
        _showMessage(failure.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
