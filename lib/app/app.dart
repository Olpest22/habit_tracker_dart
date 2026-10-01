import 'package:flutter/material.dart';
import 'package:habit_tracker/app/di/app_dependencies.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habits_list/habits_list_screen.dart';

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return DependenciesScope(
      dependencies: dependencies,
      child: MaterialApp(
        title: 'Трекер привычек',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        home: const HabitsListScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: brightness,
      ),
    );
  }
}
