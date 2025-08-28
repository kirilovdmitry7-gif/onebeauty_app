// lib/features/advice/advice_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_advice.dart';

abstract class AdviceSource {
  Future<AiAdvice> getAdvice(AdviceInput input);
}

/// Мок-источник: генерирует совет + короткое объяснение "почему".
class MockAdviceSource implements AdviceSource {
  @override
  Future<AiAdvice> getAdvice(AdviceInput input) async {
    final now = DateTime.now();
    final h = now.hour;

    String partOfDay;
    if (h < 11) {
      partOfDay = 'morning';
    } else if (h < 17) {
      partOfDay = 'afternoon';
    } else {
      partOfDay = 'evening';
    }

    final progress =
        (input.totalToday > 0) ? (input.doneToday / input.totalToday) : 0.0;

    final advice = switch (partOfDay) {
      'morning' =>
        'Start small: a glass of water now and a 5-min stretch after breakfast.',
      'afternoon' =>
        'Short break: 10 brisk minutes or a few stairs — then hydrate.',
      _ => 'Wind down: warm tea, light walk, and no screens 30 min before bed.',
    };

    final why = switch (partOfDay) {
      'morning' =>
        'Morning hydration + light mobility wake up your body and improve focus.',
      'afternoon' =>
        'A quick pulse-raiser counters post-lunch dip; water supports energy.',
      _ =>
        'Evening routine helps your sleep quality — key for recovery and mood.',
    };

    final extraWhy = (progress >= 1.0)
        ? ' You already completed today — keep the streak gentle and consistent.'
        : (progress >= 0.5)
            ? ' You’re over halfway — a tiny action now keeps momentum.'
            : ' Tiny actions avoid overwhelm and build momentum.';

    return AiAdvice(
      adviceToday: advice,
      tomorrowPlan: const [
        'Water 3× 250ml before 4pm',
        'Stretch 7 min after dinner',
      ],
      weeklySummary: input.streak > 0
          ? 'Nice run — let’s extend the streak this week.'
          : 'Let’s build your first streak.',
      nudges: const [
        Nudge(at: '10:30', message: 'Stand up and drink a glass of water.'),
        Nudge(at: '21:15', message: 'Prepare for sleep — slow down screens.'),
      ],
      tone: 'warm',
      why: '$why$extraWhy',
    );
  }
}

/// Реальный источник через HTTP API.
/// Ожидает POST { tz, today:{done,total}, streak } на <baseUrl>/ai/advice
/// и читает поля advice_today, tomorrow_plan, weekly_summary, nudges, advice_tone, why|reason.
class ApiAdviceSource implements AdviceSource {
  final String baseUrl;
  final Map<String, String>? headers;

  ApiAdviceSource({required this.baseUrl, this.headers});

  Uri get _adviceUri => Uri.parse('$baseUrl/ai/advice');

  @override
  Future<AiAdvice> getAdvice(AdviceInput input) async {
    final r = await http.post(
      _adviceUri,
      headers: {'Content-Type': 'application/json', ...?headers},
      body: jsonEncode(input.toJson()),
    );

    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Advice API ${r.statusCode}: ${r.body}');
    }

    final obj = jsonDecode(r.body) as Map<String, dynamic>;
    // Парсим как есть; если why отсутствует — карточка просто не покажет блок объяснения.
    return AiAdvice.fromJson(obj);
  }
}
