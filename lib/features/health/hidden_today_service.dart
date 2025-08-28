import 'package:shared_preferences/shared_preferences.dart';

/// Сервис "Скрыто на сегодня" (персистит список id задач на конкретную дату).
class HiddenTodayService {
  /// Формат ключа в SharedPreferences: hidden_yyyyMMdd
  String _keyFor(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'hidden_${yyyy}${mm}${dd}';
  }

  /// Загрузить Set скрытых ID на день.
  Future<Set<String>> loadHiddenIds(DateTime day) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_keyFor(day)) ?? const <String>[];
    return list.toSet();
  }

  /// Скрыть конкретный id на день.
  Future<void> hideForDate(DateTime day, String id) async {
    final sp = await SharedPreferences.getInstance();
    final key = _keyFor(day);
    final list = sp.getStringList(key) ?? <String>[];
    if (!list.contains(id)) {
      list.add(id);
      await sp.setStringList(key, list);
    }
  }

  /// Убрать из скрытых конкретный id (опционально, если понадобится).
  Future<void> unhideForDate(DateTime day, String id) async {
    final sp = await SharedPreferences.getInstance();
    final key = _keyFor(day);
    final list = sp.getStringList(key) ?? <String>[];
    if (list.remove(id)) {
      await sp.setStringList(key, list);
    }
  }

  /// Полностью очистить скрытые для дня.
  Future<void> clearForDate(DateTime day) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyFor(day));
  }
}
