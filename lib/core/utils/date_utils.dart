/// Работа с датами без времени.
///
/// Даты хранятся как полночь в UTC: так разница между днями всегда
/// кратна 24 часам и не зависит от перехода на летнее время.
DateTime dateOnly(DateTime date) => DateTime.utc(date.year, date.month, date.day);

int daysBetween(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// «2026-10-01» — формат хранения даты.
String toDateKey(DateTime date) =>
    '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';

/// Обратное преобразование для [toDateKey]. Бросает [FormatException].
DateTime fromDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) throw FormatException('Некорректная дата', key);
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
