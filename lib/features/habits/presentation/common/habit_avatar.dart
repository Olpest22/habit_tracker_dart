import 'package:flutter/material.dart';

/// Круглая иконка привычки: эмодзи на фоне её цвета.
class HabitAvatar extends StatelessWidget {
  const HabitAvatar({
    super.key,
    required this.emoji,
    required this.colorValue,
    this.size = 48,
  });

  final String emoji;
  final int colorValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(colorValue).withAlpha(50),
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
