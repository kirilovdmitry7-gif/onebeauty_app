import 'package:shared_preferences/shared_preferences.dart';

class DevFlags {
  static const _aiEnabledKey = 'dev_ai_enabled';
  static const _showSourceBadgeKey = 'dev_show_source_badge';

  /// Значения по умолчанию: включено в debug для удобства.
  static bool aiEnabled = true;
  static bool showSourceBadge = true;

  /// Загружаем сохранённые флаги (вызвать один раз при старте приложения).
  static Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    aiEnabled = sp.getBool(_aiEnabledKey) ?? aiEnabled;
    showSourceBadge = sp.getBool(_showSourceBadgeKey) ?? showSourceBadge;
  }

  static Future<void> setAiEnabled(bool v) async {
    aiEnabled = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_aiEnabledKey, v);
  }

  static Future<void> setShowSourceBadge(bool v) async {
    showSourceBadge = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_showSourceBadgeKey, v);
  }
}
