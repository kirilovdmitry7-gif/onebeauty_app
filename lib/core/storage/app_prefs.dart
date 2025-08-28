import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kHiddenTasksPrefix = 'hiddenTasks_'; // per-day key prefix

  static String _keyForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$_kHiddenTasksPrefix${d.year}-$mm-$dd';
  }

  static Future<Set<String>> getHiddenTaskIdsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    final list = prefs.getStringList(key) ?? const [];
    return list.toSet();
  }

  static Future<void> hideTaskForToday(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(DateTime.now());
    final list = prefs.getStringList(key) ?? <String>[];
    if (!list.contains(taskId)) list.add(taskId);
    await prefs.setStringList(key, list);
  }

  static Future<bool> isTaskHiddenToday(String taskId) async {
    final set = await getHiddenTaskIdsForDate(DateTime.now());
    return set.contains(taskId);
  }

  static Future<void> unhideAllToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForDate(DateTime.now()));
  }
}
