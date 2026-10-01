import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_utils.dart';

/// Привычка. Сущность domain-слоя: чистый Dart, без Flutter и хранилища.
class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorValue,
    required this.createdAt,
    this.completedDates = const <DateTime>{},
  });

  final String id;
  final String title;
  final String emoji;

  /// Цвет в формате ARGB. Domain не зависит от Flutter, поэтому
  /// хранит число, а не класс Color.
  final int colorValue;
  final DateTime createdAt;

  /// Дни, в которые привычка выполнена (даты без времени).
  final Set<DateTime> completedDates;

  bool isCompletedOn(DateTime date) => completedDates.contains(dateOnly(date));

  Habit copyWith({
    String? title,
    String? emoji,
    int? colorValue,
    Set<DateTime>? completedDates,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, emoji, colorValue, createdAt, completedDates];
}
