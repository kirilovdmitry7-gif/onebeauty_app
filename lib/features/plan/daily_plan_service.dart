import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DailyPlanItem {
  final String id;
  final String title;
  final String category;
  final int level;
  final bool done;

  DailyPlanItem({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.done,
  });

  DailyPlanItem copyWith({bool? done}) => DailyPlanItem(
        id: id,
        title: title,
        category: category,
        level: level,
        done: done ?? this.done,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'level': level,
        'done': done,
      };

  static DailyPlanItem fromJson(Map<String, dynamic> j) => DailyPlanItem(
        id: j['id'] as String,
        title: j['title'] as String,
        category: j['category'] as String,
        level: (j['level'] as num).toInt(),
        done: j['done'] as bool? ?? false,
      );
}

class PlannedTask {
  final String title;
  final String category;
  final int level;

  PlannedTask({
    required this.title,
    required this.category,
    required this.level,
  });
}

class DailyPlanService {
  static const _kPlanPrefix = 'plan_'; // + yyyymmdd
  static const _kLastPlanDate = 'last_plan_date'; // yyyy-mm-dd

  String _keyFor(DateTime day) {
    final d =
        '${day.year.toString().padLeft(4, '0')}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
    return '$_kPlanPrefix$d';
  }

  String _dateStamp(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  // -------- CRUD --------

  Future<List<DailyPlanItem>> load(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(day));
    if (raw == null) return const [];
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(DailyPlanItem.fromJson)
        .toList();
    return list;
  }

  Future<void> save(DateTime day, List<DailyPlanItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(day),
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> toggle(DateTime day, String id, bool value) async {
    final list = await load(day);
    final updated = [
      for (final it in list) it.id == id ? it.copyWith(done: value) : it
    ];
    await save(day, updated);
  }

  // Добавление пакета задач с дедупликацией по нормализованному title.
  Future<void> addMany(DateTime day, List<PlannedTask> tasks) async {
    final existing = await load(day);
    final existSet = existing.map((e) => _norm(e.title)).toSet();

    final toAdd = <DailyPlanItem>[];
    for (final t in tasks) {
      final norm = _norm(t.title);
      if (norm.isEmpty || existSet.contains(norm)) continue;
      existSet.add(norm);
      toAdd.add(
        DailyPlanItem(
          id: 'p_${day.millisecondsSinceEpoch}_${toAdd.length}',
          title: t.title.trim(),
          category: t.category,
          level: t.level,
          done: false,
        ),
      );
    }

    if (toAdd.isEmpty) return;
    final merged = [...existing, ...toAdd];
    await save(day, merged);
  }

  String _norm(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  // -------- Метаданные (дата последней сборки) --------

  Future<String?> getLastPlanDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastPlanDate);
  }

  Future<void> setLastPlanDate(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastPlanDate, _dateStamp(day));
  }
}
