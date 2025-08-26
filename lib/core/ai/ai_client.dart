import 'dart:convert';
import 'package:http/http.dart' as http;

/// Очень тонкий клиент к нашему прокси на Render.
/// Никаких ключей здесь нет — прокси знает их из переменных окружения.
class AiClient {
  // Публичный URL сервиса на Render:
  static const String _defaultBase = 'https://onebeauty-ai-proxy.onrender.com';

  final String baseUrl;

  const AiClient({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBase;

  /// Простой пинг для диагностики
  Future<String> ping() async {
    final uri = Uri.parse('$baseUrl/check-openai');
    final r = await http.get(uri);
    if (r.statusCode >= 200 && r.statusCode < 300) {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      if (data['ok'] == true) {
        return (data['reply'] as String?) ?? 'ok';
      } else {
        throw Exception('AI ping failed: ${data['message'] ?? 'unknown'}');
      }
    }
    throw Exception('AI ping HTTP ${r.statusCode}: ${r.body}');
  }

  /// Универсальный чат-вызов к прокси (используется в генераторе задач)
  Future<String> chat({
    String system = 'You are a helpful assistant.',
    required String user,
    String? locale,
    String? model, // по умолчанию у прокси стоит gpt-4o-mini
  }) async {
    final uri = Uri.parse('$baseUrl/v1/ai/chat');

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': system},
      {'role': 'user', 'content': user},
    ];

    final body = jsonEncode({
      'messages': messages,
      if (model != null) 'model': model,
      if (locale != null) 'locale': locale,
    });

    final r = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (r.statusCode >= 200 && r.statusCode < 300) {
      try {
        final data = jsonDecode(r.body);
        if (data is Map && data['content'] is String) {
          return data['content'] as String;
        }
        return r.body;
      } catch (_) {
        return r.body;
      }
    }

    // Прокси вернул ошибку
    try {
      final data = jsonDecode(r.body);
      final msg = (data is Map)
          ? (data['detail'] ?? data['message'] ?? r.body)
          : r.body;
      throw Exception('AI chat HTTP ${r.statusCode}: $msg');
    } catch (_) {
      throw Exception('AI chat HTTP ${r.statusCode}: ${r.body}');
    }
  }
}
