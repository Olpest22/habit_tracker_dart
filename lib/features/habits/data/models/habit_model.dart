import 'package:habit_tracker/core/utils/date_utils.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';

/// Модель привычки для хранения в JSON.
/// Даты отметок хранятся строками «2026-10-01», дата создания — в ISO 8601.
class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorValue,
    required this.createdAt,
    required this.completedDates,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    final rawDates = json['completedDates'] as List<dynamic>? ?? const [];
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      colorValue: (json['color'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      completedDates:
          rawDates.map((date) => date as String).toList(growable: false),
    );
  }

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      emoji: habit.emoji,
      colorValue: habit.colorValue,
      createdAt: habit.createdAt.toIso8601String(),
      completedDates: habit.completedDates.map(toDateKey).toList()..sort(),
    );
  }

  final String id;
  final String title;
  final String emoji;
  final int colorValue;
  final String createdAt;
  final List<String> completedDates;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'color': colorValue,
        'createdAt': createdAt,
        'completedDates': completedDates,
      };

  /// Бросает [FormatException], если даты в хранилище повреждены.
  Habit toEntity() {
    return Habit(
      id: id,
      title: title,
      emoji: emoji,
      colorValue: colorValue,
      createdAt: DateTime.parse(createdAt),
      completedDates: completedDates.map(fromDateKey).toSet(),
    );
  }
}
