import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/formatters.dart';
import 'package:habit_tracker/features/habits/presentation/common/habit_avatar.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_state.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/widgets/week_progress.dart';

/// Карточка привычки: иконка, название, серия, отметка за сегодня и неделя.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleToday,
  });

  final HabitListItem item;
  final VoidCallback onTap;
  final VoidCallback onToggleToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = item.habit;
    final habitColor = Color(habit.colorValue);
    final streak = item.stats.currentStreak;
    final isDone = item.isCompletedToday;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  HabitAvatar(emoji: habit.emoji, colorValue: habit.colorValue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          streak > 0
                              ? '🔥 Серия: ${pluralizeDays(streak)}'
                              : 'Серия пока не начата',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isDone ? 'Снять отметку' : 'Отметить на сегодня',
                    iconSize: 36,
                    onPressed: onToggleToday,
                    icon: Icon(
                      isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isDone ? habitColor : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              WeekProgress(days: item.lastWeek, color: habitColor),
            ],
          ),
        ),
      ),
    );
  }
}
