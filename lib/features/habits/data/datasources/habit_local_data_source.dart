import 'dart:convert';

import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальное хранилище привычек.
abstract interface class HabitLocalDataSource {
  /// Бросает [CacheException], если данные повреждены.
  Future<List<HabitModel>> loadHabits();

  /// Бросает [CacheException], если записать не удалось.
  Future<void> saveHabits(List<HabitModel> habits);
}

/// Реализация на shared_preferences: весь список хранится одной JSON-строкой.
class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  HabitLocalDataSourceImpl(this._preferences);

  static const _storageKey = 'habits_v1';

  final SharedPreferences _preferences;

  @override
  Future<List<HabitModel>> loadHabits() async {
    final rawJson = _preferences.getString(_storageKey);
    if (rawJson == null) return [];

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => HabitModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const CacheException('Сохранённые данные повреждены.');
    } on TypeError {
      throw const CacheException('Сохранённые данные повреждены.');
    }
  }

  @override
  Future<void> saveHabits(List<HabitModel> habits) async {
    final isSaved = await _preferences.setString(
      _storageKey,
      jsonEncode(habits.map((habit) => habit.toJson()).toList()),
    );
    if (!isSaved) throw const CacheException('Не удалось сохранить данные.');
  }
}
