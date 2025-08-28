import 'package:shared_preferences/shared_preferences.dart';

/// DevFlags — глобальные dev-переключатели.
/// Базовые флаги сохраняем в SharedPreferences.
/// Override-флаги держим в памяти (их заполняет DevSettingsService при загрузке).
class DevFlags {
  // Ключи для базовых флагов.
  static const _aiEnabledKey = 'dev_ai_enabled';
  static const _showSourceBadgeKey = 'dev_show_source_badge';

  /// БАЗОВЫЕ ФЛАГИ (persisted)
  static bool aiEnabled = true;
  static bool showSourceBadge = true;

  /// OVERRIDES (in-memory, nullable)
  /// Эти поля требуется наличием в dev_settings_service.dart и dev_features.dart:
  ///   - adviceUseApiOverride
  ///   - adviceShowBadgeOverride
  ///   - aiFilterTodayOverride
  ///
  /// Если = null, значит переопределение не установлено и используются базовые значения.
  static bool? adviceUseApiOverride;
  static bool? adviceShowBadgeOverride;
  static bool? aiFilterTodayOverride;

  /// Загрузка базовых флагов из SharedPreferences.
  static Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    aiEnabled = sp.getBool(_aiEnabledKey) ?? aiEnabled;
    showSourceBadge = sp.getBool(_showSourceBadgeKey) ?? showSourceBadge;
  }

  /// Сеттеры для базовых флагов (с сохранением).
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
