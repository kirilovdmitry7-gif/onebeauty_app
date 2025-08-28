import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskOverride {
  final String? title; // отображаемое имя
  final String? category; // произвольная категория
  final int? level; // 1..3

  const TaskOverride({this.title, this.category, this.level});

  TaskOverride copyWith({String? title, String? category, int? level}) =>
      TaskOverride(
        title: title ?? this.title,
        category: category ?? this.category,
        level: level ?? this.level,
      );

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (category != null) 'category': category,
        if (level != null) 'level': level,
      };

  factory TaskOverride.fromJson(Map<String, dynamic> j) => TaskOverride(
        title: j['title'] as String?,
        category: j['category'] as String?,
        level: (j['level'] is int) ? j['level'] as int : null,
      );
}

class TaskOverridesService {
  static String _key(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'task_overrides_${y}${m}${dd}';
  }

  Future<Map<String, TaskOverride>> load(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(day));
    if (raw == null || raw.isEmpty) return <String, TaskOverride>{};
    try {
      final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
      return map.map((k, v) => MapEntry(
            k,
            TaskOverride.fromJson((v as Map).cast<String, dynamic>()),
          ));
    } catch (_) {
      return <String, TaskOverride>{};
    }
  }

  Future<void> save(DateTime day, Map<String, TaskOverride> data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = data.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_key(day), jsonEncode(json));
  }

  Future<void> setOverride(DateTime day, String taskId, TaskOverride ov) async {
    final all = await load(day);
    all[taskId] = ov;
    await save(day, all);
  }

  Future<void> removeOverride(DateTime day, String taskId) async {
    final all = await load(day);
    all.remove(taskId);
    await save(day, all);
  }

  Future<void> clear(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(day));
  }
}
