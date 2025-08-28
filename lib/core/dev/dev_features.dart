import 'dev_feature_registry.dart';
import 'dev_flags.dart';
import 'dev_settings_service.dart';
import 'package:onebeauty_clean/core/config/app_config.dart';

class DevFeaturesCatalog {
  static bool _registered = false;

  /// Регистрируем все имеющиеся Dev-фичи (вызываем один раз).
  static void ensureRegistered() {
    if (_registered) return;
    _registered = true;

    // Advice: Use API (override)
    DevFeatureRegistry.register(
      DevFeature(
        key: 'advice.useApi',
        group: 'Advice',
        title: 'Use API (override)',
        subtitle: () => 'Config: ${kUseAdviceApi ? 'ON' : 'OFF'}',
        getOverride: () => DevFlags.adviceUseApiOverride,
        setOverride: DevSettingsService.setAdviceUseApiOverride,
        order: 10,
      ),
    );

    // Advice: Show source badge (override)
    DevFeatureRegistry.register(
      DevFeature(
        key: 'advice.showBadge',
        group: 'Advice',
        title: 'Show source badge (override)',
        subtitle: () => 'Config: ${kShowAdviceSourceBadge ? 'ON' : 'OFF'}',
        getOverride: () => DevFlags.adviceShowBadgeOverride,
        setOverride: DevSettingsService.setAdviceShowBadgeOverride,
        order: 20,
      ),
    );

    // Today’s tasks: AI filter (override)
    DevFeatureRegistry.register(
      DevFeature(
        key: 'today.aiFilter',
        group: 'Today’s tasks',
        title: 'Use AI filter (override)',
        subtitle: () => 'Config: ${kUseAiForTodayTasks ? 'ON' : 'OFF'}',
        getOverride: () => DevFlags.aiFilterTodayOverride,
        setOverride: DevSettingsService.setAiFilterTodayOverride,
        order: 10,
      ),
    );

    // 👉 Добавишь новую AI-фичу — просто сделай ещё один DevFeatureRegistry.register(...)
    //    и она появится в Dev-экране автоматически.
  }
}
