import 'package:flutter/material.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/app/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(HabitTrackerApp(dependencies: dependencies));
}
