// lib/features/plan/daily_plan_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyPlanItem {
  final String id;
  final String title;
  final String category;
  final int level;
  final bool done;

  const DailyPlanItem({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    this.done = false,
  });

  DailyPlanItem copyWith({
    String? id,
    String? title,
    String? category,
    int? level,
    bool? done,
  }) =>
      DailyPlanItem(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        level: level ?? this.level,
        done: done ?? this.done,
      );

  factory DailyPlanItem.fromJson(Map<String, dynamic> json) => DailyPlanItem(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String? ?? 'general',
        level: (json['level'] as num?)?.toInt() ?? 1,
        done: json['done'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'level': level,
        'done': done,
      };
}

class PlannedTask {
  final String title;
  final String category;
  final int level;

  const PlannedTask({
    required this.title,
    required this.category,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'level': level,
      };
}

class DailyPlanService {
  String _k(DateTime d) => 'plan_${_ymd(d)}';

  String _ymd(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<List<DailyPlanItem>> load(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k(day));
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map>().map((e) {
      return DailyPlanItem.fromJson((e as Map).cast<String, dynamic>());
    }).toList();
    return list;
  }

  Future<void> _save(DateTime day, List<DailyPlanItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_k(day), raw);
  }

  Future<void> toggle(DateTime day, String id, bool value) async {
    final items = await load(day);
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(done: value);
    await _save(day, items);
  }

  Future<void> addMany(DateTime day, List<PlannedTask> tasks) async {
    final items = await load(day);
    final now = DateTime.now().millisecondsSinceEpoch;
    int c = 0;
    for (final t in tasks) {
      items.add(DailyPlanItem(
        id: 'p_${now}_${c++}',
        title: t.title,
        category: t.category,
        level: t.level,
        done: false,
      ));
    }
    await _save(day, items);
  }

  /// Добавить один пункт. Возвращает сгенерированный id.
  Future<String> add(DateTime day, PlannedTask t) async {
    final items = await load(day);
    final id = 'p_${DateTime.now().microsecondsSinceEpoch}';
    items.add(DailyPlanItem(
      id: id,
      title: t.title,
      category: t.category,
      level: t.level,
      done: false,
    ));
    await _save(day, items);
    return id;
  }

  /// Удалить пункт по id (для свайпа влево).
  Future<void> remove(DateTime day, String id) async {
    final items = await load(day);
    items.removeWhere((e) => e.id == id);
    await _save(day, items);
  }
}
