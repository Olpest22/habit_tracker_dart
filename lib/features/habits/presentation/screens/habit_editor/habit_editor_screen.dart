import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/presentation/common/habit_avatar.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_editor/habit_editor_wm.dart';

/// View экрана создания и редактирования привычки.
class HabitEditorScreen extends ElementaryWidget<IHabitEditorWidgetModel> {
  const HabitEditorScreen({
    super.key,
    this.habit,
    WidgetModelFactory wmFactory = habitEditorWidgetModelFactory,
  }) : super(wmFactory);

  /// Привычка для редактирования; null — создание новой.
  final Habit? habit;

  @override
  Widget build(IHabitEditorWidgetModel wm) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wm.isEditing ? 'Редактирование' : 'Новая привычка'),
        actions: [
          if (wm.isEditing)
            IconButton(
              tooltip: 'Удалить привычку',
              icon: const Icon(Icons.delete_outline),
              onPressed: wm.onDeletePressed,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HabitPreview(
                    emoji: wm.selectedEmoji,
                    colorValue: wm.selectedColor,
                    title: wm.titleController,
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder<String?>(
                    valueListenable: wm.titleError,
                    builder: (context, error, _) => TextField(
                      controller: wm.titleController,
                      autofocus: !wm.isEditing,
                      maxLength: wm.maxTitleLength,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => wm.onSavePressed(),
                      decoration: InputDecoration(
                        labelText: 'Название',
                        hintText: 'Например, «Пить воду»',
                        errorText: error,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Иконка'),
                  ValueListenableBuilder<String>(
                    valueListenable: wm.selectedEmoji,
                    builder: (context, selectedEmoji, _) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final emoji in wm.availableEmojis)
                          _ChoiceCircle(
                            isSelected: emoji == selectedEmoji,
                            semanticLabel: 'Иконка $emoji',
                            onTap: () => wm.onEmojiSelected(emoji),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Цвет'),
                  ValueListenableBuilder<int>(
                    valueListenable: wm.selectedColor,
                    builder: (context, selectedColor, _) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final colorValue in wm.availableColors)
                          _ChoiceCircle(
                            isSelected: colorValue == selectedColor,
                            semanticLabel: 'Цвет',
                            fillColor: Color(colorValue),
                            onTap: () => wm.onColorSelected(colorValue),
                            child: colorValue == selectedColor
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ValueListenableBuilder<bool>(
                    valueListenable: wm.isSaving,
                    builder: (context, isSaving, _) => FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: isSaving ? null : wm.onSavePressed,
                      icon: isSaving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        wm.isEditing ? 'Сохранить' : 'Создать привычку',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Живой предпросмотр: иконка и название меняются по мере ввода.
class _HabitPreview extends StatelessWidget {
  const _HabitPreview({
    required this.emoji,
    required this.colorValue,
    required this.title,
  });

  final ValueListenable<String> emoji;
  final ValueListenable<int> colorValue;
  final TextEditingController title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([emoji, colorValue, title]),
      builder: (context, _) {
        final titleText = title.text.trim();
        return Column(
          children: [
            HabitAvatar(
              emoji: emoji.value,
              colorValue: colorValue.value,
              size: 88,
            ),
            const SizedBox(height: 12),
            Text(
              titleText.isEmpty ? 'Название привычки' : titleText,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: titleText.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

/// Круглая кнопка выбора иконки или цвета.
class _ChoiceCircle extends StatelessWidget {
  const _ChoiceCircle({
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
    this.fillColor,
    this.child,
  });

  final bool isSelected;
  final String semanticLabel;
  final VoidCallback onTap;
  final Color? fillColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor ??
                (isSelected ? colors.secondaryContainer : Colors.transparent),
            border: Border.all(
              color: isSelected ? colors.primary : Colors.transparent,
              width: 3,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
