import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/formatters.dart';
import 'package:habit_tracker/features/habits/presentation/common/day_mark.dart';

/// Полоска из 7 дней: выполненные дни закрашены цветом привычки.
class WeekProgress extends StatelessWidget {
  const WeekProgress({super.key, required this.days, required this.color});

  final List<DayMark> days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final day in days) _DayDot(day: day, color: color),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day, required this.color});

  final DayMark day;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatWeekdayShort(day.date),
          style: theme.textTheme.labelSmall?.copyWith(
            color: day.isToday
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: day.isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: day.isCompleted
                ? color
                : theme.colorScheme.outlineVariant.withAlpha(90),
            border: day.isToday ? Border.all(color: color, width: 2) : null,
          ),
          child: day.isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ],
    );
  }
}
