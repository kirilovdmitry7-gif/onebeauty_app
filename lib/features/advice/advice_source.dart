import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'ai_advice.dart';

/// Единый интерфейс источника советов
abstract class AdviceSource {
  Future<AiAdvice> getAdvice(AdviceInput input);
}

/// Локальный мок без сервера — для разработки/UX
class MockAdviceSource implements AdviceSource {
  @override
  Future<AiAdvice> getAdvice(AdviceInput input) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final ratio =
        (input.totalToday > 0) ? input.doneToday / input.totalToday : 0.0;

    String tip;
    if (input.totalToday == 0) {
      tip =
          'Нет задач на сегодня — добавь 1–2 простых пункта, чтобы держать ритм.';
    } else if (ratio >= 1.0) {
      tip =
          'Красота! День закрыт на 100%. Поддержи серию — лёгкая растяжка перед сном.';
    } else if (ratio >= 0.6) {
      tip = 'Осталось чуть-чуть. 10–15 минут ходьбы закроют цель по шагам.';
    } else if (ratio > 0.0) {
      tip = 'Начало положено. Выпей стакан воды и сделай 5 минут растяжки.';
    } else {
      tip = 'Стартуем легко: стакан воды сейчас и короткая прогулка днём.';
    }

    return AiAdvice(
      adviceToday: tip,
      tomorrowPlan: const [
        'Вода 3× по 250 мл до 16:00',
        'Растяжка 7 минут после ужина'
      ],
      weeklySummary: input.streak > 0
          ? 'Серия держится уже ${input.streak} дн.'
          : 'Собираем первую серию — начни с воды и сна.',
      // Важно: список не const, т.к. Nudge(...) не const-конструктор
      nudges: [
        Nudge(
            at: '21:15',
            message: 'Пора готовиться ко сну — завтра будет легче.')
      ],
      tone: 'warm',
    );
  }
}

/// Реальный источник через API (POST {baseUrl}/ai/advice)
class ApiAdviceSource implements AdviceSource {
  final String baseUrl; // напр. http://127.0.0.1:8787
  final Map<String, String> headers; // сюда можно передать Bearer-токен

  ApiAdviceSource({
    required this.baseUrl,
    Map<String, String>? headers,
  }) : headers = {
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };

  @override
  Future<AiAdvice> getAdvice(AdviceInput input) async {
    final endpoint =
        baseUrl.endsWith('/') ? '${baseUrl}ai/advice' : '$baseUrl/ai/advice';

    final uri = Uri.parse(endpoint);

    final payload = {
      'tz': input.tz,
      'today': {'done': input.doneToday, 'total': input.totalToday},
      'streak': input.streak,
      // Расширим позже (yesterday/week/profile), контракт уже поддерживает
    };

    final r = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (r.statusCode >= 200 && r.statusCode < 300) {
      final Map<String, dynamic> j = jsonDecode(r.body) as Map<String, dynamic>;
      return AiAdvice.fromJson(j);
    }

    throw Exception('Advice API error: ${r.statusCode} ${r.body}');
  }
}
