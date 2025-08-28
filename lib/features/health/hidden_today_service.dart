import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Храним set скрытых taskId для конкретной даты (только «на сегодня»).
class HiddenTodayService {
  static String _keyForDate(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return 'hidden_today_${d.toIso8601String()}';
    // будет вида hidden_today_2025-08-28T00:00:00.000
  }

  static Future<Set<String>> _loadHiddenSet(DateTime day) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_keyForDate(day));
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<void> _saveHiddenSet(DateTime day, Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyForDate(day), jsonEncode(ids.toList()));
  }

  static Future<bool> isHidden(String taskId, DateTime day) async {
    final set = await _loadHiddenSet(day);
    return set.contains(taskId);
  }

  static Future<void> hide(String taskId, DateTime day) async {
    final set = await _loadHiddenSet(day);
    set.add(taskId);
    await _saveHiddenSet(day, set);
  }

  /// Новый метод: убираем taskId из скрытых на выбранный день.
  static Future<void> unhide(String taskId, DateTime day) async {
    final set = await _loadHiddenSet(day);
    set.remove(taskId);
    await _saveHiddenSet(day, set);
  }

  /// Новый метод: очищаем список скрытых задач за день.
  static Future<void> clearFor(DateTime day) async {
    await _saveHiddenSet(day, <String>{});
  }
}
