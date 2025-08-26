// tool/translate_arb.dart
//
// Использование:
//   dart run tool/translate_arb.dart ru es
//
// Требуется .env в корне проекта с как минимум:
//   OPENAI_API_KEY=sk-...          (обязательно)
//   OPENAI_ORGANIZATION=org_...    (необязательно)
//   OPENAI_PROJECT=proj_...        (необязательно)
//
// Что делает:
// 1) Читает en-файл (lib/l10n/app_en.arb) как источник истины
// 2) Для каждого языка из аргументов читает lib/l10n/app_<lang>.arb
// 3) Находит ключи, которых нет в целевом .arb
// 4) Просит OpenAI перевести ТОЛЬКО недостающие ключи
// 5) Мерджит и сохраняет, сортируя ключи

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

const String _arbDir = 'lib/l10n';
const String _enFile = 'app_en.arb';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/translate_arb.dart <lang1> <lang2> ...');
    exit(1);
  }

  // 0) Загружаем .env
  final env = DotEnv()..load();
  final apiKey =
      env['OPENAI_API_KEY'] ?? Platform.environment['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Нет OPENAI_API_KEY. Укажи в .env или через переменные окружения.');
    exit(1);
  }
  final openaiOrg =
      env['OPENAI_ORGANIZATION'] ?? Platform.environment['OPENAI_ORGANIZATION'];
  final openaiProj =
      env['OPENAI_PROJECT'] ?? Platform.environment['OPENAI_PROJECT'];

  // 1) Читаем en-источник
  final enPath = '$_arbDir/$_enFile';
  final enMap = await _readArb(enPath);

  for (final lang in args) {
    final targetPath = '$_arbDir/app_$lang.arb';

    final targetMap = await _readArb(targetPath);
    final missing = _diffMissing(enMap, targetMap);

    if (missing.isEmpty) {
      print('[$lang] Нет ключей для перевода — пропускаю');
      continue;
    }

    print('[$lang] Нужно перевести ${missing.length} ключ(ей)');

    // 2) Переводим недостающие значения
    final translations = await _translateBatch(
      apiKey: apiKey,
      org: openaiOrg,
      project: openaiProj,
      sourceLang: 'en',
      targetLang: lang,
      keysToValues: missing,
    );

    // 3) Мерджим и сохраняем
    final merged = Map<String, dynamic>.from(targetMap)..addAll(translations);
    final sorted = Map<String, dynamic>.fromEntries(
      merged.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    await _writeArb(targetPath, sorted);
    print('[$lang] Обновлён: $targetPath');
  }

  print('Готово! Сгенерируй локализации:');
  print('flutter gen-l10n --arb-dir=$_arbDir --output-dir=$_arbDir/gen');
}

Future<Map<String, dynamic>> _readArb(String path) async {
  final file = File(path);
  if (!await file.exists()) return <String, dynamic>{};
  final text = await file.readAsString();
  final data = json.decode(text);
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{};
}

Future<void> _writeArb(String path, Map<String, dynamic> map) async {
  final file = File(path);
  final encoder = const JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(map) + '\n');
}

/// Возвращает карту недостающих ключей: ключ -> EN-значение
Map<String, String> _diffMissing(
  Map<String, dynamic> en,
  Map<String, dynamic> target,
) {
  final out = <String, String>{};
  for (final entry in en.entries) {
    final k = entry.key;
    final v = entry.value;
    if (!_isTranslatableKey(k)) continue;
    if (!target.containsKey(k)) {
      out[k] = v.toString();
    }
  }
  return out;
}

/// Фильтруем служебные ключи .arb
bool _isTranslatableKey(String key) {
  // Игнорируем метаданные и плейсхолдеры с @
  if (key.startsWith('@')) return false;
  // При необходимости сюда можно добавить исключения:
  // if (key == '@@locale' || key == '@@last_modified') return false;
  return true;
}

/// Переводим пачкой. Просим модель вернуть JSON вида { "key": "перевод", ... }
Future<Map<String, String>> _translateBatch({
  required String apiKey,
  String? org,
  String? project,
  required String sourceLang,
  required String targetLang,
  required Map<String, String> keysToValues,
}) async {
  // Формируем инструкцию — просим вернуть ТОЛЬКО JSON без лишнего текста.
  final system = '''
You are a professional app localizer. Translate values from $sourceLang to $targetLang.
Return ONLY a valid JSON object mapping keys to translated strings. 
Do not add any commentary. 
Preserve placeholders like {name}, {count}. Keep emojis and punctuation. Use concise, natural UI wording.
''';

  // Собираем полезную нагрузку как JSON строку
  final payload = jsonEncode(keysToValues);

  final body = jsonEncode({
    'model': 'gpt-4o-mini',
    'messages': [
      {'role': 'system', 'content': system},
      {
        'role': 'user',
        'content':
            'Translate the following JSON map (keys must be kept the same, values translated):\n$payload'
      }
    ],
    'temperature': 0.2,
    'response_format': {'type': 'json_object'},
  });

  final headers = <String, String>{
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };
  if (org != null && org.isNotEmpty) headers['OpenAI-Organization'] = org;
  if (project != null && project.isNotEmpty) headers['OpenAI-Project'] = project;

  final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
  final resp = await http.post(uri, headers: headers, body: body);

  if (resp.statusCode != 200) {
    stderr.writeln('Exception: Ошибка перевода (${resp.statusCode}): ${resp.body}');
    throw Exception('OpenAI error ${resp.statusCode}');
  }

  final jsonResp = jsonDecode(resp.body) as Map<String, dynamic>;
  final content = (jsonResp['choices'] as List).first['message']['content'] as String;

  // Парсим ответ как JSON-объект
  final decoded = jsonDecode(content);
  if (decoded is! Map<String, dynamic>) {
    throw Exception('Unexpected response format from OpenAI');
  }

  // Приводим к Map<String, String>
  return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
}
