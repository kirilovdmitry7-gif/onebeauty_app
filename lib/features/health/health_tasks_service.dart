import 'package:shared_preferences/shared_preferences.dart';

class HealthTask {
  final String id;
  final bool done;

  const HealthTask({
    required this.id,
    this.done = false,
  });

  HealthTask copyWith({bool? done}) =>
      HealthTask(id: id, done: done ?? this.done);
}

class HealthTasksService {
  static const _keyPrefix = 'health_tasks_v1_';

  // Базовые задачи (только id; тексты берём из локализации)
  static const List<HealthTask> _defaults = [
    HealthTask(id: 'water'),
    HealthTask(id: 'steps'),
    HealthTask(id: 'sleep'),
    HealthTask(id: 'stretch'),
    HealthTask(id: 'mind'),
  ];

  // ===== СЛОТЫ НА ДЕНЬ (галочки за сегодня) =====
  String _keyForDay(DateTime day) {
    final y = day.year;
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$_keyPrefix$y$m$d';
  }

  Future<List<HealthTask>> load(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_keyForDay(day));
    final doneSet = stored == null ? <String>{} : stored.toSet();
    return _defaults
        .map((t) => t.copyWith(done: doneSet.contains(t.id)))
        .toList(growable: false);
  }

  Future<void> toggle(DateTime day, String taskId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDay(day);
    final doneList = prefs.getStringList(key) ?? <String>[];
    final doneSet = doneList.toSet();

    if (value) {
      doneSet.add(taskId);
    } else {
      doneSet.remove(taskId);
    }
    await prefs.setStringList(key, doneSet.toList());
  }

  Future<void> resetAll(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForDay(day));
  }

  // ===== СТРИК (серия дней подряд) =====
  static const _streakKey = 'health_streak_v1';
  static const _lastDayKey = 'health_last_day_v1';

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> updateStreakIfNeeded(DateTime day, bool allDone) async {
    if (!allDone) return;

    final prefs = await SharedPreferences.getInstance();
    final lastDay = prefs.getString(_lastDayKey);
    final todayKey = _keyForDay(day);

    // если уже засчитали сегодня — ничего не делаем
    if (lastDay == todayKey) return;

    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastDay != null) {
      final lastDateIso = lastDay; // хранится нашим же _keyForDay (YYYYMMDD)
      // вычислим «вчера» в том же формате
      final yesterday = DateTime(day.year, day.month, day.day - 1);
      final yesterdayKey = _keyForDay(yesterday);

      if (lastDateIso == yesterdayKey) {
        streak += 1; // серия продолжается
      } else {
        streak = 1; // обнулилась, начинаем заново
      }
    } else {
      streak = 1; // первый успешный день
    }

    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastDayKey, todayKey);
  }
}
