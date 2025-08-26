import 'dart:convert';
import 'dart:io';

/// Синхронизация ARB-файлов:
/// Все ключи из app_en.arb будут добавлены в app_ru.arb и app_es.arb,
/// если их там ещё нет.
void main() {
  final dir = Directory('lib/l10n');
  final baseFile = File('${dir.path}/app_en.arb');
  final targets = [
    File('${dir.path}/app_ru.arb'),
    File('${dir.path}/app_es.arb'),
  ];

  if (!baseFile.existsSync()) {
    print('Не найден app_en.arb');
    exit(1);
  }

  final baseJson = jsonDecode(baseFile.readAsStringSync()) as Map<String, dynamic>;

  for (final target in targets) {
    if (!target.existsSync()) {
      print('Создаю ${target.path}');
      target.writeAsStringSync(jsonEncode({}, toEncodable: (o) => o));
    }

    final targetJson = jsonDecode(target.readAsStringSync()) as Map<String, dynamic>;
    bool changed = false;

    for (final key in baseJson.keys) {
      if (!targetJson.containsKey(key)) {
        targetJson[key] = baseJson[key]; // копируем английский текст как заглушку
        changed = true;
      }
    }

    if (changed) {
      final encoder = JsonEncoder.withIndent('  ');
      target.writeAsStringSync(encoder.convert(targetJson));
      print('Обновлён: ${target.path}');
    } else {
      print('Без изменений: ${target.path}');
    }
  }
}
