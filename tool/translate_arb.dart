// A tiny ARB sync/translate helper.
//
// Что делает:
// - Берёт lib/l10n/app_en.arb как источник истины.
// - Для каждого другого app_*.arb (ru, es, ...):
//   * Добавляет недостающие ключи из EN (значение копируется из EN, чтобы UI не падал).
//   * Копирует @-метаданные (placeholders, description) из EN.
//   * Помечает добавленные ключи в метаданных x-translationState="pending".
//   * Сохраняет существующие переводы и лишние ключи (ничего не удаляет).
//
// Запуск:
//   dart run tool/translate_arb.dart
//
// Затем перегенерируй локализации:
//   flutter gen-l10n
//
// Зависимостей нет.

import 'dart:convert';
import 'dart:io';

const String l10nDir = 'lib/l10n';
const String baseFile = 'app_en.arb';

final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

void main(List<String> args) async {
  final basePath = '$l10nDir/$baseFile';
  final baseHandle = File(basePath);
  if (!await baseHandle.exists()) {
    stderr.writeln('❌ Not found: $basePath');
    exit(2);
  }

  final Map<String, dynamic> base = _readJson(basePath);
  stdout.writeln('🌐 Base locale: en ($baseFile)');

  final dir = Directory(l10nDir);
  if (!await dir.exists()) {
    stderr.writeln('❌ Directory not found: $l10nDir');
    exit(2);
  }

  final targetFiles = <File>[];
  await for (final ent in dir.list()) {
    if (ent is! File) continue;
    if (!ent.path.endsWith('.arb')) continue;
    final basename = ent.path.split(Platform.pathSeparator).last;
    if (basename == baseFile) continue; // пропускаем app_en.arb
    targetFiles.add(ent);
  }

  if (targetFiles.isEmpty) {
    stdout.writeln(
        '⚠️  No target ARB files found in $l10nDir (only $baseFile present).');
    return;
  }

  int totalAdded = 0;

  for (final f in targetFiles) {
    final locale = _inferLocaleFromFile(f.path) ?? '??';
    stdout.writeln('\n———\n📝 Processing ${f.path} (locale: $locale)');

    final target = _readJson(f.path);
    final outcome = _mergeArb(base, target, locale);

    final sink = f.openWrite();
    sink.write(_encoder.convert(outcome.map));
    sink.writeln(); // newline at EOF
    await sink.flush();
    await sink.close();

    stdout.writeln('✅ Updated ${f.path}. Added ${outcome.added} key(s).');
    totalAdded += outcome.added;
  }

  stdout.writeln('\n🎉 Done. Total added: $totalAdded.');
  stdout.writeln('👉 Now run:  flutter gen-l10n');
}

/// Читает JSON как Map<String, dynamic>. Ошибка → пустая map.
Map<String, dynamic> _readJson(String path) {
  try {
    final text = File(path).readAsStringSync();
    final obj = jsonDecode(text);
    if (obj is Map<String, dynamic>) return obj;
  } catch (e) {
    stderr.writeln('❌ JSON parse error in $path: $e');
  }
  return <String, dynamic>{};
}

/// Результат слияния.
class MergeOutcome {
  final Map<String, dynamic> map;
  final int added;
  MergeOutcome(this.map, this.added);
}

/// Сливает EN → target, сохраняя переводы и порядок ключей из EN.
MergeOutcome _mergeArb(
  Map<String, dynamic> en,
  Map<String, dynamic> target,
  String targetLocale,
) {
  final out = <String, dynamic>{};
  int added = 0;

  // 1) Идём в порядке ключей EN
  for (final key in en.keys) {
    if (key.startsWith('@')) {
      // МЕТАДАННЫЕ
      final metaEn = en[key];
      final metaTarget = target[key];

      final mergedMeta = <String, dynamic>{};
      if (metaEn is Map) {
        mergedMeta.addAll(Map<String, dynamic>.from(metaEn));
      }
      if (metaTarget is Map) {
        final mt = Map<String, dynamic>.from(metaTarget);
        // Если в target было своё описание — сохраняем его.
        if (mt['description'] != null) {
          mergedMeta['description'] = mt['description'];
        }
        // Сохраняем любые доп. поля (кроме placeholders/description — для них приоритет как выше).
        for (final entry in mt.entries) {
          final mk = entry.key;
          if (mk == 'placeholders' || mk == 'description') continue;
          mergedMeta[mk] = entry.value;
        }
      }
      out[key] = mergedMeta;
      continue;
    }

    // Обычное сообщение
    if (target.containsKey(key)) {
      // Есть перевод — берём его
      out[key] = target[key];
    } else {
      // Нет перевода — копируем EN (чтобы UI не ломался) и помечаем "pending"
      out[key] = en[key];
      added++;

      final metaKey = '@$key';
      final metaEn = en[metaKey];
      final newMeta = <String, dynamic>{};
      if (metaEn is Map) {
        newMeta.addAll(Map<String, dynamic>.from(metaEn));
      }
      newMeta['x-translationState'] = 'pending';
      newMeta['x-note'] =
          'auto-copied from en on ${DateTime.now().toIso8601String().split("T").first}';
      out[metaKey] = newMeta;
    }
  }

  // 2) Добавляем ключи, которые есть только в target (ничего не теряем)
  for (final key in target.keys) {
    if (!out.containsKey(key)) {
      out[key] = target[key];
    }
  }

  return MergeOutcome(out, added);
}

/// Из пути вида lib/l10n/app_ru.arb → ru
String? _inferLocaleFromFile(String path) {
  final name = path.split(Platform.pathSeparator).last; // app_ru.arb
  final match = RegExp(r'app_([a-zA-Z_-]+)\.arb$').firstMatch(name);
  return match?.group(1);
}
