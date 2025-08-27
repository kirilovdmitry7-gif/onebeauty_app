import 'dart:convert';
import '../plan/daily_plan_service.dart';
import '../profile/user_profile_service.dart';
import 'package:onebeauty_clean/core/ai/ai_client.dart';

/// Интерфейс генератора задач
abstract class AiTaskGenerator {
  Future<List<PlannedTask>> generate({
    required String locale,
    required int level, // 1..3
    required Set<String> enabledCats,
    required DateTime forDay,
    required List<String> recentTitles,
    required UserProfile profile,
    required int count,
  });
}

/// Реализация через наш прокси OpenAI
class ApiAiTaskGenerator implements AiTaskGenerator {
  final AiClient _client;
  ApiAiTaskGenerator(this._client);

  @override
  Future<List<PlannedTask>> generate({
    required String locale,
    required int level,
    required Set<String> enabledCats,
    required DateTime forDay,
    required List<String> recentTitles,
    required UserProfile profile,
    required int count,
  }) async {
    // Жесткие нормы для шагов (чтобы не было 6–8k и т. п.)
    final stepsTarget = switch (level) {
      <= 1 => 6000,
      2 => 8000,
      _ => 10000,
    };

    final system =
        'You are a concise wellness coach. Return JSON only. No prose.';
    final user = jsonEncode({
      'locale': locale,
      'day': forDay.toIso8601String(),
      'profile': {
        'age': profile.age,
        'fitnessLevel': profile.fitnessLevel,
        'goals': profile.goals,
      },
      'enabledCategories': enabledCats.toList(),
      'recentTitles': recentTitles,
      'constraints': {
        // ⛔️ никаких диапазонов — только конкретика
        'no_ranges': true,
        'steps_target': stepsTarget,
        'max_items': count,
        'title_rules': [
          'Write concrete, single-target actions, no "~", "about", "6-8k" etc.',
          'Prefer numbers with units: "7,000 steps", "20 min stretch", "2L water".',
          'Keep titles short, imperative, human readable.',
        ],
        'level_meaning': {
          '1': 'beginner',
          '2': 'intermediate',
          '3': 'advanced',
        }
      },
      'schema': {
        'type': 'array',
        'items': {
          'type': 'object',
          'required': ['title', 'category', 'level'],
          'properties': {
            'title': {'type': 'string'},
            'category': {
              'type': 'string',
              'enum': enabledCats.toList(),
            },
            'level': {'type': 'integer', 'minimum': 1, 'maximum': 3}
          }
        }
      }
    });

    final raw = await _client.chat(
      system: system,
      user: 'Generate up to $count items matching the JSON schema: $user',
      locale: locale,
    );

    // Парсинг JSON (может прийти с оберткой) + санитайзинг
    final List<dynamic> data = _extractArraySafe(raw);
    final items = <PlannedTask>[];

    for (final e in data) {
      if (e is! Map) continue;
      final title0 = (e['title'] ?? '').toString();
      final category = (e['category'] ?? '').toString();
      final lvl = int.tryParse('${e['level']}') ?? level;

      if (title0.trim().isEmpty || !enabledCats.contains(category)) continue;

      final title = _normalizeTitle(title0, stepsTarget: stepsTarget);
      items.add(PlannedTask(title: title, category: category, level: lvl.clamp(1, 3)));
    }

    // Дедупликация по нормализованному заголовку и обрезка до count
    final seen = <String>{};
    final unique = <PlannedTask>[];
    for (final t in items) {
      final k = _normKey(t.title);
      if (k.isEmpty || seen.contains(k)) continue;
      seen.add(k);
      unique.add(t);
      if (unique.length >= count) break;
    }

    // Фолбэк если модель не дала ничего
    if (unique.isEmpty) {
      return [
        PlannedTask(
            title: 'Drink 2L water', category: 'water', level: level),
        PlannedTask(
            title: 'Walk $stepsTarget steps', category: 'activity', level: level),
        PlannedTask(
            title: '10 min stretch', category: 'care', level: level),
        PlannedTask(
            title: '5 min mindfulness', category: 'mind', level: level),
      ].take(count).toList();
    }
    return unique;
  }

  // --- Вспомогательные ---

  List<dynamic> _extractArraySafe(String raw) {
    try {
      final j = jsonDecode(raw);
      if (j is List) return j;
      if (j is Map && j['items'] is List) return j['items'];
    } catch (_) {}
    // Попытка вытащить JSON массив из текста
    final start = raw.indexOf('[');
    final end = raw.lastIndexOf(']');
    if (start >= 0 && end > start) {
      try {
        return (jsonDecode(raw.substring(start, end + 1)) as List);
      } catch (_) {}
    }
    return const [];
  }

  String _normKey(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Нормализация заголовков:
  /// - убираем диапазоны «6–8k»/«6-8k» → берём конкретное число (среднее)
  /// - приводим «k/тыс.» к числу
  /// - подставляем шаги фиксированным таргетом, если в тексте есть «steps» и диапазон
  String _normalizeTitle(String title, {required int stepsTarget}) {
    var t = title.trim();

    // Унификация разделителей диапазонов
    t = t.replaceAll('–', '-').replaceAll('—', '-');

    // Если упомянуты steps и есть диапазон — жёстко ставим stepsTarget
    final stepsRegex = RegExp(r'(\d+)\s*-\s*(\d+)\s*[kK]?\s*steps');
    if (stepsRegex.hasMatch(t)) {
      return t.replaceAll(stepsRegex, '${(stepsTarget / 1000).toStringAsFixed(0)}k steps')
              .replaceAll('k steps', '000 steps'); // 8k → 8000
    }

    // Общая нормализация диапазонов: «6-8k», «20-30 min»
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*-\s*(\d+)\s*([a-zA-ZкК]+)?'), (m) {
      final a = int.tryParse(m.group(1)!) ?? 0;
      final b = int.tryParse(m.group(2)!) ?? a;
      final unit = (m.group(3) ?? '').trim();
      final v = ((a + b) / 2).round(); // берём среднее
      // k → тысяча
      if (unit.toLowerCase().startsWith('k')) {
        return '${v}k';
      }
      return '$v ${unit.isEmpty ? '' : unit}';
    });

    // Преобразуем «7k steps» → «7000 steps»
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*[kK]\s*steps'), (m) {
      final v = int.tryParse(m.group(1)!) ?? 0;
      return '${v * 1000} steps';
    });

    return t;
  }
}
