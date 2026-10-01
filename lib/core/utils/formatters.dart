const _weekdaysShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
const _weekdaysFull = [
  'Понедельник', 'Вторник', 'Среда', 'Четверг',
  'Пятница', 'Суббота', 'Воскресенье',
];
const _monthsGenitive = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

/// «Пн»
String formatWeekdayShort(DateTime date) => _weekdaysShort[date.weekday - 1];

/// «Четверг, 1 октября»
String formatFullDate(DateTime date) =>
    '${_weekdaysFull[date.weekday - 1]}, ${formatDayMonth(date)}';

/// «1 октября»
String formatDayMonth(DateTime date) =>
    '${date.day} ${_monthsGenitive[date.month - 1]}';

/// «1 день», «3 дня», «5 дней».
String pluralizeDays(int count) {
  final lastTwoDigits = count % 100;
  final lastDigit = count % 10;
  final String word;
  if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
    word = 'дней';
  } else if (lastDigit == 1) {
    word = 'день';
  } else if (lastDigit >= 2 && lastDigit <= 4) {
    word = 'дня';
  } else {
    word = 'дней';
  }
  return '$count $word';
}
