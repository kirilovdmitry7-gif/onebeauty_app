import 'dart:math';

/// Источник выбора задач на СЕГОДНЯ.
/// Логика:
/// - Вода почти всегда, мягкий старт для небольшого стрика.
/// - Ротация по дням (стабильная в рамках дня) + лёгкая псевдо-случайность.
/// - При росте стрика добавляем нагрузку (шаги), иногда — "сон".
class AiTodayTasksSource {
  // Полный каталог ID задач (должны совпадать с ключами в HealthTasksService)
  static const List<String> _catalog = [
    'water',
    'steps',
    'stretch',
    'mind',
    'sleep',
  ];

  /// Вернёт множество id задач, которые стоит показать СЕГОДНЯ.
  /// [salt] — дополнительная “соль” для сидов (для debug-reroll).
  Future<Set<String>> pick({
    required int streak,
    required DateTime now,
    int salt = 0,
  }) async {
    // Стабильный seed на день + соль
    final daySeed = _daySeed(now, salt: salt);
    final rand = Random(daySeed);

    // Базовая цель: начинаем мягко и постепенно увеличиваем объём
    final int target = _targetCountForStreak(streak);

    // Обязательные/предпочтительные кандидаты
    final selected = <String>{};

    // Вода почти всегда
    selected.add('water');

    // Лёгкая подвижность и ментальная гигиена — чередуем по дням
    if (now.weekday % 2 == 0) {
      selected.add('stretch');
    } else {
      selected.add('mind');
    }

    // Шаги подключаем после первых дней стрика и тоже через день
    if (streak >= 2 && now.weekday % 2 == 1) {
      selected.add('steps');
    }

    // Сон добавляем иногда (примерно раз в 3–4 дня), особенно при среднем стрике
    if (streak >= 4 && rand.nextInt(4) == 0) {
      selected.add('sleep');
    }

    // Добираем до цели из оставшегося пула — псевдослучайно, но стабильно в день
    final pool = List<String>.from(_catalog)..removeWhere(selected.contains);

    while (selected.length < target && pool.isNotEmpty) {
      final i = rand.nextInt(pool.length);
      selected.add(pool.removeAt(i));
    }

    // Перестраховка — не больше 4 задач в день (можно менять)
    while (selected.length > 4) {
      selected.remove(selected.last);
    }

    return selected;
  }

  int _targetCountForStreak(int streak) {
    if (streak <= 1) return 3; // очень мягко
    if (streak <= 4) return 4; // базовый объём
    return 4; // держим планку
  }

  int _daySeed(DateTime now, {int salt = 0}) {
    // YYYY * 1000 + dayOfYear → стабильно на каждую дату
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays + 1;
    // соль добавляем большим простым множителем, чтобы лучше “разбрасывало”
    return now.year * 1000 + dayOfYear + salt * 10007;
  }
}
