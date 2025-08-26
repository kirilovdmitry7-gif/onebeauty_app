import 'dart:convert';
import 'package:onebeauty_clean/core/ai/ai_client.dart';
import 'package:onebeauty_clean/features/plan/daily_plan_service.dart';
import 'package:onebeauty_clean/features/profile/user_profile_service.dart';

/// Единый интерфейс генерации задач
abstract class AiTaskGenerator {
  Future<List<DailyPlanItem>> generate({
    required String locale,
    required int level, // 1..3
    required Set<String> enabledCats, // water, activity, mind, care, productivity
    required DateTime forDay,
    required List<String> recentTitles, // чтобы избегать повторов
    required UserProfile profile,
    int count = 5,
  });
}

/// Простой мок – на случай офлайна ИИ (оставим как fallback)
class MockAiTaskGenerator implements AiTaskGenerator {
  @override
  Future<List<DailyPlanItem>> generate({
    required String locale,
    required int level,
    required Set<String> enabledCats,
    required DateTime forDay,
    required List<String> recentTitles,
    required UserProfile profile,
    int count = 5,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cats = enabledCats.isEmpty
        ? const ['water', 'activity', 'mind', 'care', 'productivity']
        : enabledCats.toList();

    final List<DailyPlanItem> out = [];
    for (int i = 0; i < count; i++) {
      final c = cats[i % cats.length];
      final id = 'ai_${now}_$i';
      final title = switch (c) {
        'water' => locale.startsWith('ru') ? 'Стакан воды' : 'Drink a glass of water',
        'activity' => locale.startsWith('ru') ? '10 минут прогулки' : '10-minute walk',
        'mind' => locale.startsWith('ru') ? '1 мин дыхания' : '1-min breathing',
        'care' => locale.startsWith('ru') ? 'Растяжка шеи' : 'Neck stretch',
        _ => locale.startsWith('ru') ? 'Мини-задача' : 'Mini task',
      };
      out.add(DailyPlanItem(
        id: id,
        title: title,
        category: c,
        level: level,
        done: false,
      ));
    }
    return out;
  }
}

/// Реальная генерация через локальный прокси OpenAI
class ApiAiTaskGenerator implements AiTaskGenerator {
  final AiClient _client;
  ApiAiTaskGenerator(this._client);

  @override
  Future<List<DailyPlanItem>> generate({
    required String locale,
    required int level,
    required Set<String> enabledCats,
    required DateTime forDay,
    required List<String> recentTitles,
    required UserProfile profile,
    int count = 5,
  }) async {
    final safe = {
      'age': profile.age,
      'gender': profile.gender,
      'fitnessLevel': profile.fitnessLevel,
      'goals': profile.goals,
    };

    final sys = '''
You are a wellness coach. Return ONLY valid minified JSON with an array "items".
Each item: { "title": string, "category": "water|activity|mind|care|productivity", "level": 1|2|3 }.
No explanations. Language: $locale.
'''.trim();

    final user = jsonEncode({
      'date': forDay.toIso8601String(),
      'locale': locale,
      'level': level,
      'enabledCats': enabledCats.toList(),
      'recentTitles': recentTitles,
      'profile': safe,
      'count': count,
    });

    final raw = await _client.chat(system: sys, user: user);

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(_extractJson(raw));
    } catch (_) {
      return MockAiTaskGenerator().generate(
        locale: locale,
        level: level,
        enabledCats: enabledCats,
        forDay: forDay,
        recentTitles: recentTitles,
        profile: profile,
        count: count,
      );
    }

    final list = (parsed['items'] as List?) ?? const [];
    final now = DateTime.now().millisecondsSinceEpoch;

    final out = <DailyPlanItem>[];
    for (int i = 0; i < list.length; i++) {
      final m = list[i];
      if (m is! Map) continue;
      final title = _asString(m['title']);
      final cat = _asString(m['category']);
      final lvl = _asInt(m['level']) ?? level;

      if (title == null || title.isEmpty) continue;
      if (cat == null || !_isAllowedCategory(cat)) continue;

      final id = 'ai_${now}_$i';
      out.add(DailyPlanItem(
        id: id,
        title: title,
        category: cat, // <-- non-null после проверки
        level: lvl.clamp(1, 3),
        done: false,
      ));
    }

    if (out.isEmpty) {
      return MockAiTaskGenerator().generate(
        locale: locale,
        level: level,
        enabledCats: enabledCats,
        forDay: forDay,
        recentTitles: recentTitles,
        profile: profile,
        count: count,
      );
    }
    return out;
  }

  String _extractJson(String s) {
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start >= 0 && end > start) return s.substring(start, end + 1);
    return s;
  }

  String? _asString(dynamic v) => v is String ? v : null;
  int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  bool _isAllowedCategory(String c) { // <- принимает String, не String?
    const allowed = {'water', 'activity', 'mind', 'care', 'productivity'};
    return allowed.contains(c);
  }
}
