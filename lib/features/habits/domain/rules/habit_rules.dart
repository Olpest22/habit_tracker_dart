/// Бизнес-правила для привычек. Используются в use case'ах,
/// поэтому проверка работает одинаково на любом экране.
abstract final class HabitRules {
  static const maxTitleLength = 40;

  /// Возвращает текст ошибки или null, если название корректно.
  static String? validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return 'Введите название привычки';
    if (trimmed.length > maxTitleLength) {
      return 'Название не длиннее $maxTitleLength символов';
    }
    return null;
  }
}
