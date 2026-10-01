import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/app/di/app_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('создание привычки и отметка за сегодня', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final dependencies = await AppDependencies.create();

    await tester.pumpWidget(HabitTrackerApp(dependencies: dependencies));
    await tester.pumpAndSettle();
    expect(find.text('Пока нет привычек'), findsOneWidget);

    // Открываем редактор и создаём привычку.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Новая привычка'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Пить воду');
    final createButton = find.text('Создать привычку');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Вернулись на список: появилась карточка.
    expect(find.text('Пить воду'), findsOneWidget);
    expect(find.text('Выполнено 0 из 1'), findsOneWidget);

    // Отмечаем выполнение за сегодня.
    await tester.tap(find.byTooltip('Отметить на сегодня'));
    await tester.pumpAndSettle();
    expect(find.text('Все привычки выполнены! 🎉'), findsOneWidget);
  });
}
