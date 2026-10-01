import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/features/habits/presentation/common/status_view.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_state.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_wm.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/widgets/habit_card.dart';

/// View (MVVM) главного экрана. Только описывает интерфейс по данным
/// из WidgetModel и передаёт ей действия пользователя — без логики.
class HabitsListScreen extends ElementaryWidget<IHabitsListWidgetModel> {
  const HabitsListScreen({
    super.key,
    WidgetModelFactory wmFactory = habitsListWidgetModelFactory,
  }) : super(wmFactory);

  @override
  Widget build(IHabitsListWidgetModel wm) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои привычки')),
      body: ValueListenableBuilder<HabitsListState>(
        valueListenable: wm.state,
        builder: (context, state, _) => switch (state) {
          HabitsListLoading() =>
            const Center(child: CircularProgressIndicator()),
          HabitsListError(:final message) => StatusView(
              emoji: '⚠️',
              title: 'Не удалось загрузить привычки',
              message: message,
              actionLabel: 'Повторить',
              onAction: wm.onRetryPressed,
            ),
          HabitsListData(:final items) when items.isEmpty => StatusView(
              emoji: '🌱',
              title: 'Пока нет привычек',
              message: 'Добавьте первую привычку и отмечайте её каждый день.',
              actionLabel: 'Добавить привычку',
              actionIcon: Icons.add,
              onAction: wm.onAddHabitPressed,
            ),
          HabitsListData data => _HabitsListContent(
              data: data,
              todayLabel: wm.todayLabel,
              onHabitPressed: wm.onHabitPressed,
              onToggleTodayPressed: wm.onToggleTodayPressed,
            ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: wm.onAddHabitPressed,
        icon: const Icon(Icons.add),
        label: const Text('Привычка'),
      ),
    );
  }
}

class _HabitsListContent extends StatelessWidget {
  const _HabitsListContent({
    required this.data,
    required this.todayLabel,
    required this.onHabitPressed,
    required this.onToggleTodayPressed,
  });

  static const _maxContentWidth = 720.0;

  final HabitsListData data;
  final String todayLabel;
  final ValueChanged<HabitListItem> onHabitPressed;
  final ValueChanged<HabitListItem> onToggleTodayPressed;

  @override
  Widget build(BuildContext context) {
    // Первый элемент — сводка за сегодня, далее карточки привычек.
    // Нижний отступ, чтобы последняя карточка не пряталась под кнопкой.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: data.items.length + 1,
      itemBuilder: (context, index) {
        final Widget child;
        if (index == 0) {
          child = _TodaySummary(
            label: todayLabel,
            completed: data.completedTodayCount,
            total: data.items.length,
          );
        } else {
          final item = data.items[index - 1];
          child = HabitCard(
            key: ValueKey(item.habit.id),
            item: item,
            onTap: () => onHabitPressed(item),
            onToggleToday: () => onToggleTodayPressed(item),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Сводка: сколько привычек выполнено сегодня.
class _TodaySummary extends StatelessWidget {
  const _TodaySummary({
    required this.label,
    required this.completed,
    required this.total,
  });

  final String label;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCardColor = theme.colorScheme.onPrimaryContainer;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(color: onCardColor),
            ),
            const SizedBox(height: 4),
            Text(
              completed == total
                  ? 'Все привычки выполнены! 🎉'
                  : 'Выполнено $completed из $total',
              style: theme.textTheme.bodyMedium?.copyWith(color: onCardColor),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : completed / total,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
