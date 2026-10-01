import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/formatters.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_stats.dart';
import 'package:habit_tracker/features/habits/presentation/common/day_mark.dart';
import 'package:habit_tracker/features/habits/presentation/common/habit_avatar.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_details/habit_details_model.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_details/habit_details_wm.dart';

/// View экрана подробностей: статистика и история за 30 дней.
class HabitDetailsScreen extends ElementaryWidget<IHabitDetailsWidgetModel> {
  const HabitDetailsScreen({
    super.key,
    required this.habit,
    WidgetModelFactory wmFactory = habitDetailsWidgetModelFactory,
  }) : super(wmFactory);

  final Habit habit;

  /// Ширина, с которой статистика и история выводятся в две колонки.
  static const _wideLayoutBreakpoint = 720.0;

  @override
  Widget build(IHabitDetailsWidgetModel wm) {
    return ValueListenableBuilder<HabitDetailsViewData>(
      valueListenable: wm.viewData,
      builder: (context, data, _) {
        final header = _HabitHeader(habit: data.habit);
        final stats = _StatsGrid(stats: data.stats);
        final history = _HistoryCard(
          days: data.recentDays,
          colorValue: data.habit.colorValue,
          onDayPressed: wm.onDayPressed,
        );
        final todayButton = _TodayButton(
          isDone: data.today.isCompleted,
          onPressed: () => wm.onDayPressed(data.today),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(data.habit.title),
            actions: [
              IconButton(
                tooltip: 'Изменить',
                icon: const Icon(Icons.edit_outlined),
                onPressed: wm.onEditPressed,
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= _wideLayoutBreakpoint;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    header,
                                    const SizedBox(height: 16),
                                    stats,
                                    const SizedBox(height: 16),
                                    todayButton,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: history),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              header,
                              const SizedBox(height: 16),
                              todayButton,
                              const SizedBox(height: 16),
                              stats,
                              const SizedBox(height: 16),
                              history,
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HabitHeader extends StatelessWidget {
  const _HabitHeader({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = habit.createdAt;

    return Column(
      children: [
        HabitAvatar(emoji: habit.emoji, colorValue: habit.colorValue, size: 80),
        const SizedBox(height: 12),
        Text(
          habit.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Отслеживается с ${formatDayMonth(createdAt)} ${createdAt.year}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.isDone, required this.onPressed});

  final bool isDone;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(minimumSize: const Size.fromHeight(52));

    return isDone
        ? FilledButton.tonalIcon(
            style: style,
            onPressed: onPressed,
            icon: const Icon(Icons.undo),
            label: const Text('Снять отметку за сегодня'),
          )
        : FilledButton.icon(
            style: style,
            onPressed: onPressed,
            icon: const Icon(Icons.check),
            label: const Text('Отметить сегодня'),
          );
  }
}

/// Четыре показателя статистики в сетке 2×2.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatTile(
        emoji: '🔥',
        label: 'Текущая серия',
        value: pluralizeDays(stats.currentStreak),
      ),
      _StatTile(
        emoji: '🏆',
        label: 'Лучшая серия',
        value: pluralizeDays(stats.bestStreak),
      ),
      _StatTile(
        emoji: '📈',
        label: 'Выполнение за 30 дней',
        value: '${(stats.completionRate * 100).round()}%',
      ),
      _StatTile(
        emoji: '✅',
        label: 'Всего отметок',
        value: '${stats.totalCompletions}',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// История за 30 дней. Нажатие на день ставит или снимает отметку.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.days,
    required this.colorValue,
    required this.onDayPressed,
  });

  final List<DayMark> days;
  final int colorValue;
  final ValueChanged<DayMark> onDayPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Последние ${days.length} дней',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Нажмите на день, чтобы поставить или снять отметку',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final day in days)
                  _HistoryCell(
                    day: day,
                    color: Color(colorValue),
                    onTap: () => onDayPressed(day),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCell extends StatelessWidget {
  const _HistoryCell({
    required this.day,
    required this.color,
    required this.onTap,
  });

  final DayMark day;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = day.isCompleted ? 'выполнено' : 'не выполнено';

    return Tooltip(
      message: '${formatDayMonth(day.date)}: $status',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: day.isCompleted
                ? color
                : theme.colorScheme.outlineVariant.withAlpha(70),
            borderRadius: BorderRadius.circular(8),
            border: day.isToday
                ? Border.all(color: theme.colorScheme.onSurface, width: 2)
                : null,
          ),
          child: Text(
            '${day.date.day}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: day.isCompleted
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
