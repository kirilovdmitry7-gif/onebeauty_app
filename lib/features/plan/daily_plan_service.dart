import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Модель пункта плана на день (то, что генерит ИИ)
class DailyPlanItem {
  final String id;        // стабильный id (например, хэш от title)
  final String title;     // текст задачи
  final String category;  // water | activity | mind | care | productivity
  final int level;        // 1..3
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
  }) {
    return DailyPlanItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      level: level ?? this.level,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'level': level,
        'done': done,
      };

  static DailyPlanItem fromJson(Map<String, dynamic> m) => DailyPlanItem(
        id: (m['id'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        category: (m['category'] ?? '').toString(),
        level: int.tryParse((m['level'] ?? '1').toString()) ?? 1,
        done: m['done'] == true,
      );
}

class DailyPlanService {
  static String _keyForDay(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return 'daily_plan_${y}${m}${d}';
  }

  Future<List<DailyPlanItem>> load(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDay(day);
    final raw = prefs.getStringList(key) ?? <String>[];
    return raw
        .map((s) => jsonDecode(s))
        .whereType<Map<String, dynamic>>()
        .map(DailyPlanItem.fromJson)
        .toList(growable: false);
  }

  Future<void> toggle(DateTime day, String id, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDay(day);
    final list = prefs.getStringList(key) ?? <String>[];
    final items = list
        .map((s) => jsonDecode(s))
        .whereType<Map<String, dynamic>>()
        .map(DailyPlanItem.fromJson)
        .toList();

    final idx = items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(done: value);
      final out = items.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(key, out);
    }
  }

  /// Добавить много элементов разом (используем для «Добавить в план»).
  Future<void> addMany(DateTime day, List<DailyPlanItem> tasks) async {
    if (tasks.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForDay(day);
    final list = prefs.getStringList(key) ?? <String>[];

    final current = list
        .map((s) => jsonDecode(s))
        .whereType<Map<String, dynamic>>()
        .map(DailyPlanItem.fromJson)
        .toList();

    // Не дублируем по id
    final ids = current.map((e) => e.id).toSet();
    final merged = [
      ...current,
      ...tasks.where((t) => !ids.contains(t.id)),
    ];

    final out = merged.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, out);
  }
}
