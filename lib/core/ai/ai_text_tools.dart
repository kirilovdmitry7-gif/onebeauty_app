import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onebeauty_clean/core/config/app_config.dart';

class AiTextTools {
  static Future<String> getSimilarTitle({
    required String seed,
    String? category,
    int? level,
  }) async {
    final base = kAdviceApiBaseUrl;
    if (base.isEmpty) {
      throw StateError('Advice API base URL is empty');
    }
    final uri = Uri.parse('$base/ai/replace-title');
    final r = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'seed': seed,
            if (category != null) 'category': category,
            if (level != null) 'level': level,
          }),
        )
        .timeout(const Duration(seconds: 6));

    if (r.statusCode != 200) {
      throw StateError('Bad status ${r.statusCode}: ${r.body}');
    }
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final title = (j['title'] as String?)?.trim();
    if (title == null || title.isEmpty) {
      throw StateError('Empty title from API');
    }
    return title;
  }
}
