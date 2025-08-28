// AI ARB Translator / Sync
//
// Что делает:
// - Берёт lib/l10n/app_en.arb как базу.
// - Для каждого app_<locale>.arb (ru, es, ...):
//   * Находит недостающие или устаревшие ключи (по сравнению с EN).
//   * Если указан API — отправляет тексты в /ai/translate и подставляет ответы.
//   * Если API не задан/упал — копирует EN (или "", если --copy-empty).
//   * Копирует placeholders/description из EN в метаданные.
//   * Ставит @<key>.x-sourceText = <текущий EN> для отслеживания изменений в будущем.
//   * Помечает x-translationState: "machine" (из API) или "pending" (фоллбэк).
//   * НИЧЕГО не удаляет из целевых ARB.
//
// Запуск (примеры):
//   dart run tool/translate_arb_ai.dart --api-base=http://127.0.0.1:8788 --locales=ru,es
//   dart run tool/translate_arb_ai.dart --copy-empty --locales=ru,es
//
// После — сгенерируйте локализации:
//   flutter gen-l10n
//
// Требуется пакет http (у вас уже добавлен).
//
// Контракт API /ai/translate (пример):
//   POST <apiBase>/ai/translate
//   {
//     "source_lang": "en",
//     "target_lang": "ru",
//     "items": [
//       {"key":"statsTitle","text":"Statistics","placeholders":["name"],"description":"..."},
//       ...
//     ]
//   }
//   => 200 OK
//   {
//     "translations": [
//       {"key":"statsTitle","text":"Статистика"},
//       ...
//     ]
//   }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String kL10nDir = 'lib/l10n';
const String kBaseFile = 'app_en.arb';

// простенький парсер аргументов без package:args
class _Args {
  String? apiBase;
  List<String> locales = const []; // если пусто — берём все app_*.arb
  bool copyEmpty = false;

  static _Args parse(List<String> args) {
    final a = _Args();
    for (final s in args) {
      if (s.startsWith('--api-base=')) {
        a.apiBase = s.substring('--api-base='.length).trim();
        if (a.apiBase!.isEmpty) a.apiBase = null;
      } else if (s.startsWith('--locales=')) {
        final v = s.substring('--locales='.length).trim();
        a.locales = v.isEmpty
            ? []
            : v
                .split(',')
                .map((x) => x.trim())
                .where((x) => x.isNotEmpty)
                .toList();
      } else if (s == '--copy-empty') {
        a.copyEmpty = true;
      }
    }
    return a;
  }
}

void main(List<String> argsRaw) async {
  final args = _Args.parse(argsRaw);

  final basePath = '$kL10nDir/$kBaseFile';
  final baseFile = File(basePath);
  if (!baseFile.existsSync()) {
    stderr.writeln('❌ Not found: $basePath');
    exit(2);
  }
  final Map<String, dynamic> en = _readJson(basePath);
  stdout.writeln('🌐 Base: $kBaseFile (${en.length} entries incl. metadata)');

  // Соберём список целевых ARB
  final dir = Directory(kL10nDir);
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith('/$kBaseFile'))
      .toList();

  // Фильтр по --locales=ru,es если задан
  final filtered = args.locales.isEmpty
      ? files
      : files.where((f) {
          final loc = _inferLocaleFromFile(f.path);
          return loc != null && args.locales.contains(loc);
        }).toList();

  if (filtered.isEmpty) {
    final available =
        files.map((f) => _inferLocaleFromFile(f.path) ?? '?').toList();
    stdout.writeln('⚠️  No target ARB files matched. Available: $available');
    return;
  }

  int totalAddedAll = 0;
  for (final f in filtered) {
    final locale = _inferLocaleFromFile(f.path) ?? '??';
    stdout.writeln('\n———\n📝 Processing ${f.path} (locale: $locale)');

    final target = _readJson(f.path);

    final result = await _mergeWithAi(
      en: en,
      target: target,
      targetLocale: locale,
      apiBase: args.apiBase,
      copyEmpty: args.copyEmpty,
    );

    // Запись
    final encoder = const JsonEncoder.withIndent('  ');
    await f.writeAsString('${encoder.convert(result.map)}\n');
    stdout.writeln(
        '✅ Updated ${f.path}. Added ${result.added} key(s), translated ${result.translated} key(s).');

    totalAddedAll += result.added;
  }

  stdout.writeln('\n🎉 Done. Total added: $totalAddedAll.');
  stdout.writeln('👉 Now run:  flutter gen-l10n');
}

Map<String, dynamic> _readJson(String path) {
  try {
    final txt = File(path).readAsStringSync();
    final obj = jsonDecode(txt);
    if (obj is Map<String, dynamic>) return obj;
  } catch (e) {
    stderr.writeln('❌ JSON parse error in $path: $e');
  }
  return <String, dynamic>{};
}

String? _inferLocaleFromFile(String path) {
  final name = path.split(Platform.pathSeparator).last; // app_ru.arb
  final m = RegExp(r'app_([a-zA-Z_-]+)\.arb$').firstMatch(name);
  return m?.group(1);
}

class _MergeResult {
  final Map<String, dynamic> map;
  final int added; // новых ключей добавлено (не было в target)
  final int translated; // реально переведено через API
  _MergeResult(this.map, this.added, this.translated);
}

/// Слияние + (опционально) переводы через API.
/// Логика “нужен ли новый перевод”:
///  - Если ключ отсутствует в target → переводим/копируем.
///  - Если @key.x-sourceText в target != текущему EN → перевести заново (EN изменился).
Future<_MergeResult> _mergeWithAi({
  required Map<String, dynamic> en,
  required Map<String, dynamic> target,
  required String targetLocale,
  required String? apiBase,
  required bool copyEmpty,
}) async {
  final out = <String, dynamic>{};
  int added = 0;
  int translated = 0;

  // собираем партию для перевода
  final batch = <Map<String, dynamic>>[];

  for (final key in en.keys) {
    if (key.startsWith('@')) {
      // метаданные перенесём после основного цикла
      continue;
    }

    final enVal = en[key];
    final metaKey = '@$key';
    final metaEn = en[metaKey];

    final hasTarget = target.containsKey(key);
    final targetVal = hasTarget ? target[key] : null;
    final metaTarget = target[metaKey];

    // Определим, нужно ли перезаливать перевод: сравним x-sourceText (что было в target) с текущим EN
    final oldSourceText = (metaTarget is Map<String, dynamic>)
        ? (metaTarget['x-sourceText'] as String?)
        : null;
    final needTranslate = !hasTarget || (oldSourceText != enVal);

    if (needTranslate) {
      added += hasTarget ? 0 : 1;

      if (apiBase != null && apiBase.trim().isNotEmpty) {
        // готовим элемент для батча перевода
        batch.add({
          'key': key,
          'text': enVal,
          'placeholders': _extractPlaceholders(metaEn),
          'description': (metaEn is Map<String, dynamic>)
              ? (metaEn['description'] ?? '')
              : '',
        });

        // временно поставим EN (чтобы не ломать UI до ответа), заменим после ответа
        out[key] = enVal;
      } else {
        // без API: ставим "" или EN
        out[key] = copyEmpty ? '' : enVal;
      }
    } else {
      // перевод актуален — переносим существующий
      out[key] = targetVal;
    }
  }

  // если есть API — сходить перевести
  if (batch.isNotEmpty && apiBase != null && apiBase.trim().isNotEmpty) {
    final chunks = _chunk(batch, 50); // батчим на всякий
    for (final part in chunks) {
      try {
        final resp = await http.post(
          Uri.parse(_join(apiBase, '/ai/translate')),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'source_lang': 'en',
            'target_lang': targetLocale,
            'items': part,
            // сервер пусть сам заботится о подсказке "сохраняй {placeholders}"
          }),
        );
        if (resp.statusCode == 200) {
          final j = jsonDecode(resp.body) as Map<String, dynamic>;
          final list = (j['translations'] as List).cast<Map>();
          for (final t in list) {
            final k = t['key'] as String;
            final v = t['text'] as String? ?? '';
            out[k] = v;
            translated++;
          }
        } else {
          stderr.writeln(
              '⚠️  API translate error ${resp.statusCode}: ${resp.body}');
          // ничего не делаем: out уже содержит EN (временный фоллбэк)
        }
      } catch (e) {
        stderr.writeln('⚠️  API translate exception: $e');
        // ничего не делаем: out уже содержит EN (временный фоллбэк)
      }
    }
  }

  // теперь переносим/обновим метаданные
  for (final key in en.keys) {
    if (!key.startsWith('@')) {
      final metaKey = '@$key';
      final metaEn = en[metaKey];
      final prevMeta = target[metaKey];

      final mergedMeta = <String, dynamic>{};

      // placeholders/description берём из EN
      if (metaEn is Map<String, dynamic>) {
        mergedMeta.addAll(metaEn);
      }

      // если в target было своё описание — оставим его
      if (prevMeta is Map<String, dynamic>) {
        if (prevMeta['description'] != null) {
          mergedMeta['description'] = prevMeta['description'];
        }
        // сохраним кастомные поля
        for (final e in prevMeta.entries) {
          final k = e.key;
          if (k == 'placeholders' || k == 'description') continue;
          mergedMeta[k] = e.value;
        }
      }

      final wasMissing = !target.containsKey(key);
      final oldSourceText = (prevMeta is Map<String, dynamic>)
          ? (prevMeta['x-sourceText'] as String?)
          : null;
      final enVal = en[key];

      final retranslatedNow = wasMissing || (oldSourceText != enVal);

      // отметки статуса и текущий исходный EN
      mergedMeta['x-sourceText'] = enVal;
      if (retranslatedNow) {
        // если реально перевели через API — machine; если нет — pending
        final gotMachine = out.containsKey(key) && out[key] != enVal;
        mergedMeta['x-translationState'] = gotMachine ? 'machine' : 'pending';
        mergedMeta['x-updated'] = DateTime.now().toIso8601String();
      }

      out[metaKey] = mergedMeta;
    }
  }

  // добавим в конец те ключи, которые есть только в target (чтобы ничего не потерять)
  for (final key in target.keys) {
    if (!out.containsKey(key)) {
      out[key] = target[key];
    }
  }

  return _MergeResult(out, added, translated);
}

List<String> _extractPlaceholders(dynamic metaEn) {
  if (metaEn is Map<String, dynamic>) {
    final ph = metaEn['placeholders'];
    if (ph is Map<String, dynamic>) {
      return ph.keys.toList();
    }
  }
  return const [];
}

Iterable<List<T>> _chunk<T>(List<T> list, int size) sync* {
  for (var i = 0; i < list.length; i += size) {
    final end = (i + size < list.length) ? i + size : list.length;
    yield list.sublist(i, end);
  }
}

String _join(String base, String path) {
  if (base.endsWith('/')) base = base.substring(0, base.length - 1);
  if (!path.startsWith('/')) path = '/$path';
  return '$base$path';
}
