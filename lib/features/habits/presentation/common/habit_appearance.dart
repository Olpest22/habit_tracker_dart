/// Наборы иконок и цветов, из которых пользователь выбирает оформление.
abstract final class HabitAppearance {
  static const emojis = [
    '💧', '🏃', '📚', '🧘', '🍎', '😴', '🦷', '🎸',
    '✍️', '🧹', '💊', '🚶', '🥗', '🧠', '🌱', '☀️',
  ];

  static const colors = [
    0xFF43A047, // зелёный
    0xFF1E88E5, // синий
    0xFFFB8C00, // оранжевый
    0xFFD81B60, // розовый
    0xFF8E24AA, // фиолетовый
    0xFF00897B, // бирюзовый
    0xFFE53935, // красный
    0xFF6D4C41, // коричневый
  ];

  static const defaultEmoji = '💧';
  static const defaultColor = 0xFF1E88E5;
}
